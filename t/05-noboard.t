use strict;
use warnings;

use RPi::DHT11::EnvControl qw(:all);
use Test::More;

use constant {
    DHT => 4,
    TEMP => 1,
    HUM => 5,
};

$ENV{RDE_NOBOARD_TEST} = 1;

my $mod = 'RPi::DHT11::EnvControl';

# temp

my $t = temp(DHT);
is $t, 0, "temp ok with no board";

# humidity

my $h = humidity(DHT);
is $h, 0, "humidity ok with no board";

done_testing();

