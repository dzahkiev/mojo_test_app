
package App::DBhelpers;
use base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;
  my $dbh;


$app->helper( db => sub { 
     my $self = shift; 
     $dbh = DBI->connect( "DBI:mysql:dbname=test;host=localhost;port=3306" );
});


$app->helper( select_rows => sub { 
  my ( $self, $query, $params ) = @_; 
  my $sth = $dbh->prepare( $query );
  $params ? $sth->execute( $params ) : $sth->execute(); 
  my $i = 0;
  my $data;
  while ( my $ref = $sth->fetchrow_hashref ) {
	  $data->{$i} = $ref;
	  $i++;
  }
  return $data;
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
     my @res = $sth->execute( @params ); 
     return @res;
});


$app->helper( delete_user => sub { 
     my ( $self, $param) = @_;
     my $sth = $dbh->prepare( "DELETE FROM users WHERE id = ?" );
     my $res = $sth->execute( $param ); 
     return $res;
});

 


}

1;