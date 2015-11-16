package TestApp::Controller::Users;
use base 'Mojolicious::Controller';
use DBI;
use DBD::mysql;
 

sub list {
  my ( $self ) = @_ ;
  my $dbh = connectBD(); 
  my $sth = $dbh->prepare( "SELECT * FROM users" );
  $sth->execute;
  my $users;
  my $i = 0;
  while ( my $ref = $sth->fetchrow_hashref ) {
	  $users->{$i} = $ref;
	  $i++;
  }
 unconnectBD( $sth, $dbh ); 
 $self->render( msg => 'Users  list', k => $users );

}


sub form {
  my ( $self ) = @_;  
  my $link;
  if ( $self->param( 'ID' ) && ! defined $self->param( 'submit' ) )  {
    my $dbh = &connectBD;
    my $sth = $dbh->prepare( "SELECT * FROM users WHERE ID = ?" );
    $sth->execute( $self->param( 'ID' ) );
    my $users->{0} = $sth->fetchrow_hashref;  
    $users->{email}{valid} = 1; 
    $link = "/users/".$self->param( 'ID' )."/edit";
    $self->render( msg => 'Editing user', btn_text => 'Save', fields => $users, link => $link );
    unconnectBD( $sth, $dbh );
  }

  elsif ( $self->param( 'submit' ) ) {
  	my $param;
  	$param->{0}{email} = $self->param( 'email' );
  	$param->{0}{password} = $self->param( 'password' );
  	$param->{0}{money} = $self->param( 'money' ) ? $self->param( 'money' ) : 0;
  	$param->{0}{sex} = $self->param( 'sex' );
  	$param->{0}{created} = $self->param( 'created' ); 
    $param->{email}{valid} = check_email ($param->{0}{email});
    $param->{password}{valid} = check_password ( $param->{0}{password} );
    $param->{date}{valid} = check_date ( $param->{0}{created} );
    $valid = check_email_password( $param->{0}{email}, $param->{0}{password}, $param->{0}{created} ); 
    if ( !$self->param( 'ID' ) ) {
    ($valid = 0, $param->{email}{valid} = 0 ) if is_exist_email($param->{0}{email});
    }
    
   

  if ( $valid ) {
  	my $dbh = &connectBD;
    my $query;
    my $id = $self->param( 'ID' );
    if ( $id ) {
       $query =  "UPDATE users SET email = ? , pass = MD5(?) , sex = ? , money = ? , created = ?  WHERE id = $id"; 
    } 
    else {
        $query = "INSERT INTO users (email, pass, sex, money, created )
                      VALUES ( ?, MD5(?), ?, ?, ? ) ";                      
   }
  	my $sth = $dbh->prepare( $query );	
	 	my $res = $sth->execute( $param->{0}{email}, $param->{0}{password}, $param->{0}{sex}, $param->{0}{money}, $param->{0}{created} );
		unconnectBD( $sth, $dbh );
    my $message;
    if ($res) {
      $message  = $id ?  'The user is was edited!' : 'The user is was added!';
    }
    else {
      $message = 'Something wrong!'; 
    }
   	$self->flash(message =>  $message);
   	$self->redirect_to( 'users'); 
   }
  else {
    my $btn_text = $self->param( 'ID' ) ?  'Save' : 'Add user';
    my $mess = $self->param( 'ID' ) ?  'Editing user' : 'Add new user';
   	$self->render( msg => $mess, btn_text => $btn_text,  fields => $param, link => $link);
   } 
   
  } 
  else {
   $link = "/users/add";
   $self->render( msg => 'Add new user',  btn_text => 'Add user', fields => $param, link => $link);
  }

}


sub connectBD {
  my ( $host, $port, $dbname ) = ( 'localhost', '3306', 'test' );
  my $dbh = DBI->connect( "DBI:mysql:dbname=$dbname;host=$host;port=$port" );
}

sub unconnectBD {
 my ( $sth, $dbh ) = @_;
 $sth->finish;  
 $dbh->disconnect; 
}

sub check_email_password {
	my ($email, $password, $date) = @_; 
	( check_email($email) && check_password($password) && check_date($date)) ? return 1 :	return 0;
	
} 

sub check_email {
  my $email = shift;
  ($email =~/^([a-z0-9_-]+\.*)*@[a-z0-9_-]+\.[a-z]{2,6}$/i) ? return 1 : return 0;

}

sub check_password {
  my $password = shift;
  ($password =~/^[a-zA-Z0-9]{6,}$/i) ? return 1 : return 0;
}

sub check_date {
  my $date = shift;
  ($date =~/^(\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2})$/i) ? return 1 : return 0;
}


sub is_exist_email {
  my $email = shift;
  my $dbh = connectBD(); 
  my $sth = $dbh->prepare( "SELECT email FROM users WHERE email = ?" );
  $sth->execute($email); 
  my @res = $sth->fetchrow_array;
  unconnectBD( $sth, $dbh ); 
  return scalar @res;
}


sub  remove {
	my $self = shift;
	my $id = $self->param( 'ID' );
  my $dbh = connectBD(); 
 	my $sth = $dbh->prepare("DELETE FROM users WHERE id = ?");
  $sth->execute($id);
  unconnectBD( $sth, $dbh );
  $self->flash( message => 'The user was removed!' );
	$self->redirect_to( 'users'); 
 }




1;
