use strict;
use warnings;

use RPi::DHT11::EnvControl qw(:all);
use Test::More;

use constant {
    HIGH => 1,
    LOW => 0,
    DHT => 4,
    TEMP => 1,
    HUM => 5,
};

if (! $ENV{RDE_HAS_BOARD}){
    $ENV{RDE_NOBOARD_TEST} = 1;
    my $state = status(TEMP);
    is $state, '', "status() ok with noboard";
}
else {
    control(TEMP, LOW);
    
    my $state = status(TEMP);
    is $state, '', "status() ok on LOW";
    ok ! $state, "status() with state == LOW ok";

    control(TEMP, HIGH);

    $state = status(TEMP);
    is $state, 1, "status() ok on HIGH";
}

done_testing();

