package TestApp;
use base Mojolicious;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin('App::Helpers');

  # Router
  my $r = $self->routes;
   
 $r->any('/')->to( 'users#auth_form' );
 $r->any('/login')->to( 'users#auth_form' );
 $r->any('/logout')->to( 'users#delete' ); 
 $r->any('/create')->to( 'users#create' ); 
 $r->any('/api/users')->to( 'users#apilist' );


  my $auth = $r->under( '/' )->to('users#auth');

  # Normal route to controller  
 
 $auth->get('/users')->to( 'users#list' ); 
 $auth->any('/users/add')->to( 'users#form' ); 
 $auth->any('/users/:ID/edit')->to( 'users#form' ); 
 $auth->get('/users/:ID/remove')->to( 'users#remove' );
 $auth->post('/users/search')->to( 'users#list' );


 
 
 # $r->get('/')->to('example#welcome');

}

1;
