package TestApp::Controller::Users;
use base 'Mojolicious::Controller';   
use feature qw(say switch);
use Mojo::JSON qw(decode_json encode_json); 
 
 
sub list {
  my $self = shift ;  
  my $query;
  my $searching_string = $self->param( 'search_str' );
  if ( $searching_string ) {
    $query =  "SELECT * FROM users WHERE MATCH (name, email) AGAINST ( ? )" ;
  }
  else {
    $query =  "SELECT * FROM users" ;
  }  
  my $users = $self->select_rows( $query, $searching_string );
  $self->render( msg => 'Users  list', k => $users, searching_string => $searching_string );
}

 
sub form {
  my ( $self ) = @_;   
  my $link;
  if ( $self->param( 'ID' ) && ! defined $self->param( 'submit' ) )  {
    my $query = "SELECT * FROM users WHERE ID = ?" ;
    my $users->{0} = $self->select_row( $query, $self->param( 'ID' ) );
    $users->{email}{valid} = 1; 
    $users->{date}{valid} = check_date ( $users->{0}{created} );
    $link = "/users/" . $self->param( 'ID' ) . "/edit";
    $self->render( msg => 'Editing user', btn_text => 'Save', fields => $users, link => $link );
 }
  elsif ( $self->param( 'submit' ) ) {
  	my @param;

    $param[0] = $self->param( 'name' );
  	$param[1] = $self->param( 'email' );
  	$param[2] = $self->param( 'password' );    
    $param[3] = $self->param( 'sex' );
  	$param[4] = $self->param( 'money' ) || 0;
  	$param[5] = $self->param( 'created' ); 
    $param->{email}{valid} = check_email ($param->{0}{email});
    $param->{password}{valid} = check_password ( $param->{0}{password} );
    $param->{date}{valid} = check_date ( $param->{0}{created} );

    my $upload = $self->req->upload( 'uploadImage' );
    my $filename = $upload->filename;  
    if ( $filename =~/\.(?:jpe?g|png)$/i ) {
      my $i;
      while (-e "public/img/$filename" ) {
        $i++;
        $filename = $` . "-00$i" . $&; 
      }
       $upload->move_to( "public/img/$filename" );
       $param[6] = $filename || '';
    }

   my $valid = check_email_password( @param[1,2,5] ); 
    if ( !$self->param( 'ID' ) ) {
    ( $valid = 0, $param->{email}{valid} = 0 ) if is_exist_email( $self, $param[1] );
    }
     
if ( $valid ) {
  	my $query;
    my $id = $self->param( 'ID' );

    if ( $id ) {
       $query =  "UPDATE users SET name = ? , email = ? , pass = MD5(?) , sex = ? , money = ? , created = ?, photo = ?  WHERE id = $id"; 
  } 
    else {
        $query = "INSERT INTO users (name, email, pass, sex, money, created, photo )
                      VALUES ( ?, ?, MD5(?), ?, ?, ?, ? ) ";                      
  }

  	my $res = $self->execute_qw($query, @param); 
	 	 
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
   $self->render( msg => 'Add new user',  btn_text => 'Add user', fields => my $param, link => $link);
  }

}


sub check_email_password {
	my ( $email, $password, $date ) = @_; 
	( check_email( $email ) && check_password( $password ) && check_date( $date ) ) ? return 1 :	return 0;
	
} 

sub check_email {
  my $email = shift;
  ( $email =~/^([a-z0-9_-]+\.*)*@[a-z0-9_-]+\.[a-z]{2,6}$/i ) ? return 1 : return 0;

}

sub check_password {
  my $password = shift;
  ( $password =~/^[a-zA-Z0-9]{6,}$/i ) ? return 1 : return 0;
}

sub check_date {
  my $date = shift;
  ( $date =~/^(\d{4}-\d{2}-\d{2}\s{1}\d{2}:\d{2}:\d{2})$/i ) ? return 1 : return 0;
}


sub is_exist_email {
  my ( $self, $email ) = @_;
  my $query = "select * from users where email = ? "; 
  my $res = $self->select_row( $query, $email );
  return  $res;
}


sub  remove {
	my $self = shift;
	my $id = $self->param( 'ID' );
  $self->delete_user( $id );
  $self->flash( message => 'The user was removed!' );
	$self->redirect_to( 'users' ); 

 }




1;
