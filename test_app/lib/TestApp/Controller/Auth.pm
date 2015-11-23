package TestApp::Controller::Auth;
use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5_hex);
use strict;

sub login {
my $self = shift;
$self->stash( login => $self->session( 'login' ) );
$self->logged;
}

sub create {
  my $self = shift;
  my $login  = $self->param( 'login' );
  my $password = md5_hex( $self->param( 'password' ) );
  if ( exists_user( $self, $login, $password ) ) {
    $self->session ( login => $login );
    $self->redirect_to( 'show_users' );
  }
  else {
    $self->flash( error => 'Wrong password or user!' );
    $self->redirect_to( 'login' );
  }
}

sub delete {
  my $self = shift;
  $self->session ( login => '' );
  $self->redirect_to( 'login' );
}

sub form {
  my $self = shift;
  $self->stash( user => '' );
  $self->logged ? $self->redirect_to( 'show_users' ) : $self->render( msg => 'Login form' );
}

sub exists_user {
  my ( $self, @params) = @_;
  my $query = "SELECT * FROM users WHERE email = ? AND pass = ?";
  my $res = $self->select_row( $query, @params );
}


1;
