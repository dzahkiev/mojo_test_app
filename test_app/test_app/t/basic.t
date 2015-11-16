use base Mojolicious -strict;

use Test::More;
use Test::Mojolicious;

my $t = Test::Mojo->new('TestApp');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

done_testing();
