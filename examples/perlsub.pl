use warnings;
use strict;

use RPi::DHT11::EnvControl;

use constant {
    SENSOR_PIN => 4,
    FAN_PIN => 1,
    HUMIDIFIER_PIN => 6,
};

my $env = RPi::DHT11::EnvControl->new(dht_pin => SENSOR_PIN);

sleep 10;
