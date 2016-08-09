package RPi::DHT11::EnvControl; 
use strict;
use warnings;

our $VERSION = '0.04';

use Carp qw(croak);

require XSLoader;
XSLoader::load('RPi::DHT11::EnvControl', $VERSION);

$SIG{INT} = sub {};

sub new {
    my $class = shift;
    my %args = @_;

    if (! defined $args{dht_pin} || $args{dht_pin} < 0 || $args{dht_pin} > 40){
        croak "\nnew() requires at minimum the 'dht_pin' param, 0 - 40\n";
    }

    $args{tpin} = defined $args{tpin} 
        ? $args{tpin} 
        : -1;

    $args{h_pin} = defined $args{hpin} 
        ? $args{hpin}
        : -1;

    return bless {%args}, $class;
}
sub temp {
    my $self = shift;
    return c_temp($self->_pin('dht'));
}
sub humidity {
    my $self = shift;
    return c_humidity($self->_pin('hum'));
}
sub status {
    my ($self, $pin) = @_;
    croak "pin $pin is not in use for temp or humidity\n"
      if ! $self->_check_pin($pin);
    return c_status($pin);
}
sub control {
    my ($self, $pin, $state) = @_;
    croak "pin $pin is not in use for temp or humidity\n"
      if ! $self->_check_pin($pin);
    return c_control($pin, $state);
}
sub cleanup {
    my $self = shift;
    return c_cleanup(
        $self->_pin('dht'),
        $self->_pin('tmp'),
        $self->_pin('hum')
    );
}
sub DESTROY {
    my $self = shift;
    $self->cleanup;
}
sub _pin {
    # retrieve the various pins
    my ($self, $pin) = @_;
    return $self->{dht_pin} if $pin eq 'dht';
    return $self->{tpin} if $pin eq 'tmp';
    return $self->{hpin} if $pin eq 'hum';
}
sub _check_pin {
    my ($self, $pin) = @_;
    for ('tmp', 'hum'){
        return 1 if $self->_pin($_);
    }
    return 0; 
}

1;
__END__

=head1 NAME

RPi::DHT11::EnvControl - Monitor environment temperature/humidity, and act
when limits are reached

=head1 SYNOPSIS

Basic usage example. You'd want to daemonize the script, or run it periodically
in C<cron> or the like.

    use RPi::DHT11::EnvControl qw(:all);

    use constant {
        SENSOR_PIN => 4,
        FAN_PIN => 1,
        HUMIDIFIER_PIN => 6,
    };

    my $high_temp = 79.8;
    my $low_humidity = 22.5;

    my $temp = temp(SENSOR_PIN);

    if ($temp > $high_temp){
        my $status = control(FAN_PIN);
        print "exhaust fan turned on\n" if $status;
    }

    if ($humidity < $low_humidity){
        my $status = control(HUMIDIFIER_PIN);
        print "humidifier turned on\n" if $status;
    }

    my $fan_status = status(FAN_PIN) ? 'ON' : 'OFF';
    my $humidifier_status = status(HUMIDIFIER_PIN) ? 'ON' : 'OFF';

    print "Exhaust fan is $fan_status, humidifier is $humidifier_status\n";

    cleanup(SENSOR_PIN, FAN_PIN, HUMIDIFIER_PIN);

=head1 DESCRIPTION

This module is an interface to the DHT11 temperature/humidity sensor when
connected to a Raspberry Pi's GPIO pins. This is but one small piece of my
indoor grow operation environment control system.

Due to the near-realtime access requirements of reading the input pin of the
sensor, the core of this module is written in XS (C).

It allows you to set temperature and humidity limits, then act when the limits
are reached. For example, if the temperature gets too high, we can enable a
120/240v relay to turn on an exhaust fan for a time, or enable/disable a
warning LED.

The Perl aspect makes it easy to send emails etc.

This module requires the L<wiringPi|http://wiringpi.com/> library to be
installed.

=head1 METHODS

=head2 new

Parameters:

=head3 dht_pin

Mandatory. Pin number for the DHT11 sensor's DATA pin (values are 0-40).

=head3 tpin

Optional. Pin number of a device to enable/disable. C<status()> and
C<control()> won't do anything if this is not set.

=head3 hpin

Optional. Pin number of a device to enable/disable. C<status()> and
C<control()> won't do anything if this is not set.

=head2 temp

Fetches the current temperature (in Farenheit).

Returns the temperature as either an integer or a floating point number. If any
errors were encountered during the polling of the sensor, the return will be
C<0.0>.

=head2 humidity

Fetches the current humidity.

Returns the humidity as either an integer or a floating point number. If any
errors were encountered during the polling of the sensor, the return will be
C<0.0>.

=head2 status($pin)

Parameters:

=head3 $pin

The GPIO pin number to check.

Returns the current status (bool) whether the specified pin is on (1, HIGH) or
off (0, LOW).

=head2 control($pin, $state)

Enables the enabling and/or disabling of devices connected to specified
Raspberry Pi GPIO pins.

Parameters:

=head3 C<$pin>

The GPIO pin number to act on.

=head3 C<$state>

Bool, turns the pin on (HIGH) or off (LOW).

Returns false (could be zero, undef or empty string) if the pin is in 'off'
state, and true (1) otherwise.

=head2 cleanup

Returns all pins to their default status (mode = INPUT, state = LOW).

=head1 C TYPEDEFS

=head2 EnvData

Stores the temperature and humidity float values.

    typedef struct env_data {
        float temp;
        float humidity;
    } EnvData;

=head1 C FUNCTIONS

=head2 c_temp

    float c_temp(int dht_pin);

Called by the C<temp()> method.

=head2 c_humidity

    float c_humidity(int dht_pin);

Called by the C<humidity()> method.

=head2 c_status

    bool c_status(int pin);

Called by the C<status()> method.

=head2 c_control

    bool c_control(int pin, int state);

Called by the C<control()> method.

=head2 c_cleanup

    int c_cleanup(int dht_pin, int tpin, int hpin);

Called by the C<cleanup()> method, and is always called upon C<DESTROY()>.

=head2 read_env()

    EnvData read_env(int dht_pin);

Not available to Perl.

Polls the pin a single time and returns an C<EnvData> struct containing the
temp and humidity float values.

If for any reason the poll of the DHT11 sensor fails (eg: the CRC is incorrect
for the data), both C<temp> and C<humidity> floats will be set to C<0.0>.

=head2 noboard_test()

    bool noboard_test();

Checks whether the C<RDE_NOBOARD_TEST> environment variable is set to a true
value. Returns true if so, and false if not. This bool is used for testing
purposes only.

Not available to Perl.

=head2 sanity()

    void sanity();

If we're on a system that isn't a Raspberry Pi, things break. Every function
calls this one, and if sanity checks fail, we exit (unless in RDE_NOBOARD_TEST
environment variable is set to true).

Not available to Perl.

=head1 SEE ALSO

- L<wiringPi|http://wiringpi.com/>

=head1 AUTHOR

Steve Bertrand, E<lt>steveb@cpan.org<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.
