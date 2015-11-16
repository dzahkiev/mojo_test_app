package TestApp;
use base Mojolicious;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller 
 $r->get('/')->to( 'users#list' );
 $r->get('/users')->to( 'users#list' );
 $r->get('/users/add')->to( 'users#form' );
 $r->post('/users/add')->to( 'users#form' );
 $r->get('/users/:ID/edit')->to( 'users#form' );
 $r->get('/users/:ID/remove')->to( 'users#remove' );
 $r->get('/users/:ID/edit')->to( 'users#form' );
 $r->post('/users/:ID/edit')->to( 'users#form' );

 
 
 # $r->get('/')->to('example#welcome');

}

1;
