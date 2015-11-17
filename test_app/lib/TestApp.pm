package TestApp;
use base Mojolicious; 
use DBI;  


# This method will run once at server start
sub startup {
  my $self = shift;
 
  $self->plugin('App::Helpers');  
  $self->plugin('App::DBhelpers');   
  $self->db;
        


  # Router
  my $r = $self->routes;
   
 $r->any('/')->to( 'auth#form' );
 $r->any('/login')->to( 'auth#form' );
 $r->any('/logout')->to( 'auth#delete' ); 
 $r->any('/create')->to( 'auth#create' ); 

 $r->any('/api/users')->to( 'users#apilist' );
 $r->any('/api/users/test')->to( 'users#test' );

 $r->any('/square')->to( 'ws#square' );
 $r->any('/btn')->to( 'ws#btn' );
 $r->websocket('/change')->to( 'ws#change_color' );


  my $auth = $r->under( '/' )->to('auth#auth');

 $auth->get('/users')->to( 'users#list' ); 
 $auth->any('/users/add')->to( 'users#form' ); 
 $auth->any('/users/:ID/edit')->to( 'users#form' ); 
 $auth->get('/users/:ID/remove')->to( 'users#remove' );
 $auth->post('/users/search')->to( 'users#list' ); 
}

1;
