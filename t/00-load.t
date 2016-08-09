use strict;
use warnings;

use Test::More;

BEGIN { use_ok('RPi::DHT11::EnvControl') };

my $mod = 'RPi::DHT11::EnvControl';

can_ok $mod, 'temp';
can_ok $mod, 'humidity';
can_ok $mod, 'control';
can_ok $mod, 'cleanup';

done_testing();
