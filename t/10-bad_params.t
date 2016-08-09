use strict;
use warnings;

use Hook::Output::Tiny;
use RPi::DHT11::EnvControl qw(:all);
use Test::More;

use constant {
    DHT => 4,
    TEMP => 1,
    HUM => 5,
};

$ENV{RDE_NOBOARD_TEST} = 1;

my $o = Hook::Output::Tiny->new;

# temp

my $t = eval {temp(); 1};
is $t, undef, "temp() fails with no params";
like $@, qr/usage/i, "temp() err ok with no params";

$t = temp(DHT);
is $t, 0, "temp() ok with param";

# humidity

my $h = eval {humidity(); 1};
is $h, undef, "humidity() fails with no params";
like $@, qr/usage/i, "humidity() err ok with no params";

$h = humidity(DHT);
is $h, 0, "humidity() ok with param";

done_testing();

