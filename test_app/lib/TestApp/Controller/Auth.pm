package TestApp::Controller::Auth;
use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5 md5_hex);
use strict; 
 

sub auth {
my ( $self ) = @_ ;
$self->stash(user => $self->session( 'login' ) ); 
$self->logged;  
}


sub create {
  my ( $self ) = @_ ; 
  my $login  = $self->param( 'login' ); 
  my $password = md5_hex( $self->param( 'password' ) ); 
  
  if ( exists_user( $self, $login, $password ) ) {
    $self->session ( login => $login );
    $self->redirect_to( '/users' );
  }
  else {
    $self->flash( error => 'Wrong password or user!' );
    $self->redirect_to( '/login' );
  }
}


sub delete {
  my ( $self ) = @_ ; 
  $self->session ( login => '' ); 
  $self->redirect_to( '/login' );
}


sub form {
  my ( $self ) = @_; 
  $self->stash( user => '' ); 
  $self->logged ? $self->redirect_to( '/users' ) :  $self->render( msg => 'Login form' ); 
}


sub exists_user {
  my ( $self, @params)  = @_; 
  my $query = "SELECT * FROM users WHERE email = ? AND pass = ? ";
  my $res = $self->select_row( $query, @params ); 
  $res ? 1 : 0;
}

  

1;
