
package App::Helpers;
use base 'Mojolicious::Plugin';

sub  register {
  my ($self, $app) = @_;
  my $dbh;

  $app->helper( logged => sub {
    my $self = shift; 
    $self->session('login') ? 1 : 0;
  });

  $app->helper( user => sub {
    my ($self, $log) = @_;
    my $query = "SELECT * FROM users WHERE email = ? ";
    my $res =  $self->select_row( $query, $log );
  });

}

1;