package TestApp::Controller::Ws;
use base 'Mojolicious::Controller';

my @clients;

sub square {
  my $self = shift;
  $self->render();
}

sub btn {
  my $self = shift;
  $self->render();
}

sub change_color {
  my $self = shift ;
  push @clients, $self->tx;

  $self->on( message => sub {
  my ( $self, $msg ) = @_;
  my @color_char = ( 0..9, 'A'..'F' );
  my $color = '#';
  for ( 1..6 ) {
    $color .= @color_char[ rand scalar @color_char ];
  }
  for my $client ( @clients ) {
     $client->send( $color );
  }
 });
}


1;
