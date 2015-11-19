package App::DBhelpers;
use base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;
  my $dbh;


$app->helper( db => sub { 
  my $self = shift; 
  $dbh = DBI->connect( "DBI:mysql:dbname=test;host=localhost;port=3306" ) or die "Couldn't connect!" ;
});


$app->helper( select_rows => sub { 
  my ( $self, $query, $params ) = @_; 
  my $sth = $dbh->prepare( $query );
  $params ? $sth->execute( $params ) : $sth->execute(); 
  my @data;
  while ( my $ref = $sth->fetchrow_hashref ) {
  push @data, $ref; 
  }
  return \@data;
});
 

$app->helper( select_row => sub { 
  my ( $self, $query, @params) = @_;
  my $sth = $dbh->prepare( $query );
  $sth->execute( @params ); 
  return $sth->fetchrow_hashref;
});



$app->helper( execute_qw => sub { 
  my ( $self, $query, @params) = @_;
  my $sth = $dbh->prepare( $query );
  my $res = $sth->execute( @params ); 
  return $res;
});


}

1;