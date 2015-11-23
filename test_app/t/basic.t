#use base Mojolicious -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('TestApp');

$t->get_ok('/')->status_is(200);

$t->get_ok('/api/users.json')
->status_is(200)
->content_type_like(qr/json/)
->json_has(  { status => 'ok' } );

$t->get_ok( '/api/users.json?search_str=NewUser' )
->status_is(200)
->json_is( { name => 'NewUser' } );

done_testing();
