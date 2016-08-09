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

my $env = $mod->new(
    dht_pin => DHT,
    temp_pin => TEMP,
    humidity_pin => HUM,
);

if (! $ENV{RDE_HAS_BOARD}){
    $ENV{RDE_NOBOARD_TEST} = 1;
    my $state = $env->status(TEMP);
    is $state, '', "status() ok with noboard";
}
else {
    $env->control(TEMP, LOW);
    
    my $state = $env->status(TEMP);
    is $state, '', "status() ok on LOW";
    ok ! $state, "status() with state == LOW ok";

    $env->control(TEMP, HIGH);

    $state = $env->status(TEMP);
    is $state, 1, "status() ok on HIGH";
}

done_testing();

