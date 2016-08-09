package RPi::DHT11::EnvControl;

use strict;
use warnings;

our $VERSION = '0.04';

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ('all' => [qw(temp humidity cleanup status control)]);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

require XSLoader;
XSLoader::load('RPi::DHT11::EnvControl', $VERSION);

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

This module requires the L<http://wiringpi.com/|wiringPi> library to be
installed.

=head1 EXPORT_OK

The C<:all> tag can be used to include all of the following, or they can be
imported individually: C<temp>, C<humidity>, C<control> and C<cleanup>.

=head1 FUNCTIONS

=head2 temp($dht_pin)

Fetches the current temperature (in Farenheit).

C<$dht_pin> is the pin number that is connected to the DHT11 sensor's data pin.

Returns the temperature as either an integer or a floating point number. If any
errors were encountered during the polling of the sensor, the return will be
C<0.0>.

C definition:
    
    float temp(int dht_pin);

=head2 humidity($dht_pin)

Fetches the current humidity.

Parameters:

=head3 C<$dht_pin> 

The pin number that is connected to the DHT11 sensor's data pin.

Returns the humidity as either an integer or a floating point number. If any
errors were encountered during the polling of the sensor, the return will be
C<0.0>.

C definition:
    
    float humidity(int dht_pin);

=head2 status($pin)

Parameters:

=head3 $pin

The GPIO pin number to check.

Returns the current status (bool) whether the specified pin is on (1, HIGH) or
off (0, LOW).

C definition:

    bool status(int pin);

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

C definition:

    bool control(int pin, int state);

=head2 cleanup($dht_pin, $temp_pin, $humidity_pin)

Returns all pins to their default status (mode = INPUT, state = LOW).

Parameters:

=head3 $dht_pin

The pin connected to the DHT11 sensor's data pin. Mandatory.

=head3 $temp_pin

Pin connected to the temperature action pin. Send in C<-1> if it was not used.

=head3 $humidity_pin

Pin connected to the humidity action pin. Send in C<-1> if it was not used.

=head1 C TYPEDEFS

=head2 EnvData

Stores the temperature and humidity float values.

    typedef struct env_data {
        float temp;
        float humidity;
    } EnvData;

=head1 C PRIVATE DEFINITIONS

=head2 read_env()

    EnvData read_env(int dht_pin);

Polls the pin a single time and returns an C<EnvData> struct containing the
temp and humidity float values.

If for any reason the poll of the DHT11 sensor fails (eg: the CRC is incorrect
for the data), both C<temp> and C<humidity> floats will be set to C<0.0>.

=head2 noboard_test()

    bool noboard_test();

Checks whether the C<RDE_NOBOARD_TEST> environment variable is set to a true
value. Returns true if so, and false if not. This bool is used for testing
purposes only.

=head2 sanity()

    void sanity();

If we're on a system that isn't a Raspberry Pi, things break. Every function
calls this one, and if sanity checks fail, we exit (unless in RDE_NOBOARD_TEST
environment variable is set to true).

=head1 SEE ALSO

- L<http://wiringpi.com/|wiringPi>

=head1 AUTHOR

Steve Bertrand, E<lt>steveb@cpan.org<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.
