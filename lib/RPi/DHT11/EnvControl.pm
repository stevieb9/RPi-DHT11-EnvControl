package RPi::DHT11::EnvControl; 
use strict;
use warnings;

our $VERSION = '0.07';

use Carp qw(croak);

require XSLoader;
XSLoader::load('RPi::DHT11::EnvControl', $VERSION);

$SIG{INT} = sub {};

sub new {
    my $class = shift;
    my %args = @_;

    if (! defined $args{spin} || $args{spin} < 0 || $args{spin} > 40){
        croak "\nnew() requires at minimum the 'spin' param, 0 - 40\n";
    }

    $args{tpin} = defined $args{tpin} 
        ? $args{tpin} 
        : -1;

    $args{hpin} = defined $args{hpin} 
        ? $args{hpin}
        : -1;

    my $self = bless {%args}, $class;

    sanity();

    return $self;
}
sub debug {
    return shift->{debug};
}
sub temp {
    my ($self, $want) = @_;
    my $temp = c_temp($self->_pin('spin'));

    if (defined $want && $want =~ /f/i){
        $temp = $temp * 9 / 5 + 32;
    }
    return int($temp + 0.5);
}
sub humidity {
    my $self = shift;
    return c_humidity($self->_pin('spin'));
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
        $self->_pin('spin'),
        $self->_pin('tpin'),
        $self->_pin('hpin')
    );
}
sub DESTROY {
    my $self = shift;
    if ($self->debug){
        $self->cleanup;
    }
}
sub _pin {
    # retrieve the various pins
    my ($self, $pin) = @_;
    return $self->{spin} if $pin eq 'spin';
    return $self->{tpin} if $pin eq 'tpin';
    return $self->{hpin} if $pin eq 'hpin';
}
sub _check_pin {
    my ($self, $pin) = @_;
    for ('tpin', 'hpin'){
        return 1 if $self->_pin($_) == $pin;
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

    use RPi::DHT11::EnvControl;

    use constant {
        DHT_PIN => 4,
        TEMP_PIN => 1,
        HUMIDITY_PIN => 5,
        ON => 1,
        OFF => 0,
    };

    my $temp_high = 72;
    my $humidity_low = 25;

    my $env = RPi::DHT11::EnvControl->new(
        spin => DHT_PIN,
        tpin => TEMP_PIN,
        hpin => HUMIDITY_PIN,
    );

    my $temp = $env->temp;
    my $humidity = $env->humidity;

    print "temp: $temp, humidity: $humidity\n";

    # action something if results are out of range

    if ($temp > $temp_high){
        if (! $env->status(TEMP_PIN)){
            $env->control(TEMP_PIN, ON);
            print "turning on exhaust fan\n";
        }
    }
    else {
        if ($env->status(TEMP_PIN)){
            $env->control(TEMP_PIN, OFF);
            print "exhaust fan turned off\n";
        } 
    }

    # humidity
        
    if ($humidity < $humidity_low){
        ...
    }

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
installed, and uses WiringPi's GPIO pin numbering scheme (see C<gpio readall>
at the command line).

=head1 METHODS

=head2 new()

Parameters:

=head3 spin

Mandatory. Pin number for the DHT11 sensor's DATA pin (values are 0-40).

=head3 tpin

Optional. Pin number of a device to enable/disable. C<status()> and
C<control()> won't do anything if this is not set.

=head3 hpin

Optional. Pin number of a device to enable/disable. C<status()> and
C<control()> won't do anything if this is not set.

=head3 debug

Optional. If set to true (1), we'll reset all the pins to default (mode INPUT,
state LOW) when the object goes out of scope.

=head2 temp($f)

Fetches the current temperature (in Celcius).

Returns an integer of the temperature, in celcius by default.

Parameters:

=head3 $f

Send in the string char C<'f'> to receive the temp in Farenheit.

Send in

=head2 humidity

Fetches the current humidity.

Returns the humidity as either an integer of the current humidity level.

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

    float c_temp(int spin);

Called by the C<temp()> method.

=head2 c_humidity

    float c_humidity(int spin);

Called by the C<humidity()> method.

=head2 c_status

    bool c_status(int pin);

Called by the C<status()> method.

=head2 c_control

    bool c_control(int pin, int state);

Called by the C<control()> method.

=head2 c_cleanup

    int c_cleanup(int spin, int tpin, int hpin);

Called by the C<cleanup()> method, and is always called upon C<DESTROY()>,
unless C<debug> is set in C<new()>.

=head2 read_env()

    EnvData read_env(int spin);

Not available to Perl.

Polls the pin in a loop until valid data is fetched, then  returns an C<EnvData>
struct containing the temp and humidity float values.

If for any reason the poll of the DHT11 sensor fails (eg: the CRC is incorrect
for the data), both C<temp> and C<humidity> C<-1>.

=head2 noboard_test()

    bool noboard_test();

Checks whether the C<RDE_NOBOARD_TEST> environment variable is set to a true
value. Returns true if so, and false if not. This bool is used for testing
purposes only.

Not available to Perl.

=head2 sanity()

    void sanity();

If we're on a system that isn't a Raspberry Pi, things break. We call this in
C<new()>, and if sanity checks fail, we exit (unless in RDE_NOBOARD_TEST
environment variable is set to true).

Called only from the C<new()> method.

=head1 ENVIRONMENT VARIABLES

There are a couple of env vars to help prototype and run unit tests when not on
a RPi board.

=head2 RDE_HAS_BOARD

Set to C<1> to tell the unit test runner that we're on a Pi.

=head2 RDE_NOBOARD_TEST

Set to C<1> to tell the system we're not on a Pi. Most methods/functions will
return default (ie. non-live) data when in this mode.

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
