use strict;
use warnings;

use RPi::DHT11::EnvControl;
use Test::More;

use constant {
    HIGH => 1,
    LOW => 0,
    DHT => 4,
    TEMP => 1,
    HUM => 5,
};

my $mod = 'RPi::DHT11::EnvControl';
my $env = $mod->new(spin => DHT, tpin => TEMP, hpin => HUM, debug => 1);

if (! $ENV{RDE_HAS_BOARD}){
    warn "RDE_HAS_BOARD is not set\n";
    $ENV{RDE_NOBOARD_TEST} = 1;
    my $state = $env->control(TEMP, LOW);
    is $state, '', "noboard control() with state == LOW ok";
    ok ! $state, "noboard control() with state == LOW ok";

    $state = $env->control(TEMP, HIGH);
    is $state, 1, "noboard control() with state == HIGH ok";

    my $ok = eval { $state = $env->control(39, HIGH); 1; };
    ok ! $ok, "control() with bad pin dies";
    ok $@, "control() with bad pin error";
}
else {
    my $state = $env->control(TEMP, LOW);
    is $state, '', "control() with state == LOW ok";
    ok ! $state, "control() with state == LOW ok";

    $state = $env->control(TEMP, HIGH);
    is $state, 1, "control() with state == HIGH ok";
    
    $env->control(TEMP, LOW);

    $state = $env->status(TEMP);
    is $state, '', "control() with LOW ok";

    my $ok = eval { $state = $env->control(39, HIGH); 1; };
    ok ! $ok, "control() with bad pin dies";
    ok $@, "control() with bad pin error";
}

done_testing();

