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
 $r->any( '/api/users/test' )		->to( 'users#test' );
 $r->get( '/square' )				->to( 'ws#square' );
 $r->get( '/btn' )					->to( 'ws#btn' );
 $r->websocket( '/change' )			->to( 'ws#change_color' );
 my $auth = $r->under(  '/'  )		->to('auth#auth');
 $auth->get( '/users' )				->to( 'users#list' ); 
 $auth->any( '/users/add' )			->to( 'users#form' ); 
 $auth->any( '/users/:ID/edit' )	->to( 'users#form' ); 
 $auth->get( '/users/:ID/remove' )	->to( 'users#remove' );
 $auth->post( '/users/search' )		->to( 'users#list' ); 
}

1;
