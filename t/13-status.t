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

if (! $ENV{RDE_HAS_BOARD}){
    warn "RDE_HAS_BOARD is not set\n";
    $ENV{RDE_NOBOARD_TEST} = 1;

    my $env = env();

    my $state = $env->status(TEMP);
    is $state, '', "status() ok with noboard";

    my $ok = eval { $env->status(39); 1; };
    ok ! $ok, "croak if pin isn't registered";
    ok $@, "error is set for non registered pin";
}
else {
    my $env = env();
    
    $env->control(TEMP, LOW);
    
    my $state = $env->status(TEMP);
    is $state, '', "status() ok on LOW";
    ok ! $state, "status() with state == LOW ok";

    $env->control(TEMP, HIGH);

    $state = $env->status(TEMP);
    is $state, 1, "status() ok on HIGH";
}

sub env {
    my $env = $mod->new(
        spin => DHT,
        tpin => TEMP,
        humidity_pin => HUM,
        debug => 1,
    );
    return $env;
}

done_testing();

