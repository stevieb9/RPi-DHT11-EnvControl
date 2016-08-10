use warnings;
use strict;

use RPi::DHT11::EnvControl;

use constant {
    DHT_PIN => 4,
    TEMP_PIN => 1,
    HUMIDITY_PIN => 5,
    ON => 1,
    OFF => 0,
};

my $temp_high = 79.5;
my $humidity_low = 22.5

my $env = RPi::DHT11::EnvControl->new(
    spin => DHT_PIN,
    tpin => TEMP_PIN,
    hpin => HUMIDITY_PIN,
);

my $temp = $env->temp;
my $humidity = $env->humidity;

print "temp: $temp, humidity: $humidity\n";

# turn on/off devices, whether they be LEDs or appliances
# connected to 120/240v relays on the TEMP_PIN/HUMIDITY_PIN

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
