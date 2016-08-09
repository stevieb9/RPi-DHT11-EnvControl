use warnings;
use strict;

use feature 'say';

use RPi::DHT11::EnvControl qw(:all);

use constant {
    DHT => 4,
    TEMP => 1,
    HUM => 6,
};

say temp(DHT, TEMP);
say humidity(DHT, HUM);
