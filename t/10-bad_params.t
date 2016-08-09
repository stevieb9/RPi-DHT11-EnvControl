use strict;
use warnings;

use RPi::DHT11::EnvControl;
use Test::More;

use constant {
    DHT => 4,
    TEMP => 1,
    HUM => 5,
};

my $mod = 'RPi::DHT11::EnvControl';

{ # bad params

    my $env;

    my $ok = eval { $env = $mod->new; 1; };
    ok ! $ok, "new() dies with no spin param";

    $ok = eval { $env = $mod->new(spin => -1); 1; };
    ok ! $ok, "new() dies with a dht < 0";

    $ok = eval { $env = $mod->new(spin => 41); 1; };
    ok ! $ok, "new() dies with a dht > 40";
}

done_testing();
