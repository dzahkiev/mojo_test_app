use base Mojolicious -strict;

use Test::More;
use Test::Mojolicious;

my $t = Test::Mojo->new('TestApp');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
$t->get_ok('/api/users.json')->status_is(200)->json_is( { status => 'ok' } );

done_testing();
