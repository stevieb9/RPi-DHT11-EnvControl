use warnings;
use strict;

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
