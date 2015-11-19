package TestApp;
use base Mojolicious;
use DBI;


# This method will run once at server start
sub startup {
 my $self = shift;
 
 $self->plugin('App::Helpers');
 $self->plugin('App::DBhelpers');
 $self->db;
 my $r = $self->routes;
 $r->get( '/' )						->to( 'auth#form' );
 $r->get( '/login' )				->to( 'auth#form' );
 $r->get( '/logout' )				->to( 'auth#delete' );
 $r->any( '/create' )				->to( 'auth#create' );
 $r->any( '/api/users' )			->to( 'users#apilist' );
 $r->any( '/test' )					->to( 'users#test' );
 $r->get( '/square' )				->to( 'ws#square' );
 $r->get( '/btn' )					->to( 'ws#btn' );
 $r->websocket( '/change' )			->to( 'ws#change_color' );
 my $auth = $r->under( '/' )		->to('auth#auth');
 $auth->get( '/users' )				->to( 'users#list' )	->name( 'show_users' );
 $auth->any( '/users/add' )			->to( 'users#form' )	->name( 'add_user' );
 $auth->any( '/users/:ID/edit' )	->to( 'users#form' )	->name( 'edit_user' );
 $auth->get( '/users/:ID/remove' )	->to( 'users#remove' )	->name( 'remove_user' );
 $auth->post( '/users/search' )		->to( 'users#list' )	->name( 'search_user' );
}

1;
