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
    my $state = control(TEMP, LOW);
    is $state, '', "noboard control() with state == LOW ok";
    ok ! $state, "noboard control() with state == LOW ok";

    $state = control(TEMP, HIGH);
    is $state, 1, "noboard control() with state == HIGH ok";

    $state = control(TEMP, -1);
    is $state, 1, "noboard control() with no state param ok";
}
else {
    my $state = control(TEMP, LOW);
    is $state, '', "control() with state == LOW ok";
    ok ! $state, "control() with state == LOW ok";

    $state = control(TEMP, HIGH);
    is $state, '', "control() with state == HIGH ok";
    ok ! $state, "control() with state == LOW ok";

    $state = control(TEMP, -1);
    is $state, 1, "control() with no state param and HIGH ok";

    control(TEMP, LOW);

    $state = control(TEMP, -1);
    is $state, 1, "control() with no state param and LOW ok";
}

done_testing();

