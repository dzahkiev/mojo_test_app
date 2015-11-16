
package App::Helpers;
use base 'Mojolicious::Plugin';

  sub register {

      my ($self, $app) = @_;

      $app->helper( logged => sub { 
      		my $self = shift; 
      	  $self->session('login') ? 1 : 0;
      });


 	  $app->helper( user => sub { 
      my ($self, $log) = @_;  
      my ( $host, $port, $dbname ) = ( 'localhost', '3306', 'test' );
      my $dbh = DBI->connect( "DBI:mysql:dbname=$dbname;host=$host;port=$port" );
	   	my $sth = $dbh->prepare( "SELECT * FROM users WHERE email = ? " );
  		$sth->execute($log); 
  		my $res = $sth->fetchrow_hashref; 
	    $sth->finish;  
	    $dbh->disconnect; 
     	return $res;
      });







  }

  1;