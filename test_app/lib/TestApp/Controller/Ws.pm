package TestApp::Controller::Ws;
use base 'Mojolicious::Controller';    
 
my $client;
my $i = 0;

sub square {
  my ( $self ) = @_ ; 
  $self->render();
}

sub btn {
  my ( $self ) = @_ ; 
  $self->render();
}

sub change_color {
  my $self = shift ;  
  $client->{$i} = $self->tx;
  $i++;

  $self->on( message => sub {
  my ( $self, $msg ) = @_;  
  my @color_char = ( 0..9, 'A'..'F' );
  my $color = '#';
  for ( 1..6 ) {
    $color .= @color_char[ rand scalar @color_char ];
  }
  for ( keys $client ) {
     $client->{$_}->send( $color );
  }
 });
}



1;
