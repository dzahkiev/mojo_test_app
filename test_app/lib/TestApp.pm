package TestApp;
use base Mojolicious;

sub startup {
 my $self = shift;
 
 $self->plugin('App::Helpers');
 $self->plugin('App::DBhelpers');
 $self->db;
 my $r = $self->routes;
 $r->get( '/' )						->to( 'auth#form' )			->name( 'login' );
 $r->get( '/login' )				->to( 'auth#form' )			->name( 'login' );
 $r->get( '/logout' )				->to( 'auth#delete' )		->name( 'logout' );
 $r->any( '/create' )				->to( 'auth#create' )		->name( 'create_session' );
 $r->any( '/api/users' )			->to( 'users#apilist' )		->name( 'users_api' ); 
 $r->get( '/square' )				->to( 'ws#square' )			->name( 'square' );
 $r->get( '/btn' )					->to( 'ws#btn' )			->name( 'button' );
 $r->websocket( '/change' )			->to( 'ws#change_color' )	->name( 'change_color' );
 my $auth = $r->under( '/' )		->to('auth#auth')			->name( 'auth_user' );
 $auth->get( '/users' )				->to( 'users#list' )		->name( 'show_users' );
 $auth->any( '/users/add' )			->to( 'users#form' )		->name( 'add_user' );
 $auth->any( '/users/:ID/edit' )	->to( 'users#form' )		->name( 'edit_user' );
 $auth->get( '/users/:ID/remove' )	->to( 'users#remove' )		->name( 'remove_user' );
 $auth->post( '/users/search' )		->to( 'users#list' )		->name( 'search_user' );
}

1;
