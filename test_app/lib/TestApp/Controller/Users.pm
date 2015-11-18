package TestApp::Controller::Users;
use base 'Mojolicious::Controller';    
 
 
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
my $submit = $self->param( 'submit' );
my $id = $self->param( 'ID' );
my @param;
my @val_fields;
my $valid;
if ( $id && ! defined $submit )  {
  my $query = "SELECT * FROM users WHERE ID = ?" ;
  my $users = $self->select_row( $query, $id );
  $val_fields[0] = 1; 
  $val_fields[2] = 1;
  $link = "/users/$id/edit";
  $self->render( msg => 'Editing user', btn_text => 'Save', fields => $users, valid => \@val_fields, link => $link );
 }
elsif ( $submit ) {
push @param, (  $self->param( 'name' ),  
                $self->param( 'email' ),  
                $self->param( 'password' ),  
                $self->param( 'sex' ),
                $self->param( 'money' ) || 0,
                $self->param( 'created' ) );
  $val_fields[0] = check_email ($param[1]);
  $val_fields[1] = check_password ( $param[2] );
  $val_fields[2] = check_date ( $param[5] );
  my $upload = $self->req->upload( 'uploadImage' );
  my $filename = $upload->filename;  
  if ( $filename =~/\.(?:jpe?g|png)$/i ) {
    my $i;
    while ( -e "public/img/$filename" ) {
      $i++;
      $filename = $` . "-00$i" . $&; 
    }
    $upload->move_to( "public/img/$filename" );
  }
  $param[6] = $filename || '';
  my $valid = check_email_password( @param[1,2,5] ); 
  if ( !$id ) {
  ( $valid = 0, $val_fields[0] = 0 ) if is_exist_email( $self, $param[1] );
}
     
if ( $valid ) { 
  my $query = ($id)  ? "UPDATE users SET name = ? , email = ? , pass = MD5(?) , sex = ? , money = ? , created = ?, photo = ?  where id = $id"
  : "insert into users (name, email, pass, sex, money, created, photo ) values ( ?, ?, MD5(?), ?, ?, ?, ? ) ";                      
  my $res = $self->execute_qw($query, @param); 
	my $message;
  if ($res) {
      $message  = $id ?  'The user was edited!' : 'The user was added!';
  } 
  else {
    $message = 'Something wrong!'; 
  }
  $self->flash(message =>  $message);
  $self->redirect_to( 'users'); 
 } 
 else{
  my $btn_text = $id ?  'Save' : 'Add user';
  my $title = $id ?  'Editing user' : 'Add new user';
  $link = "/users/add" unless $id; 
  $self->render( msg => $title,  btn_text =>  $btn_text, fields => \@param, valid => \@val_fields, link => $link);
 }

} 
else {  
  $self->render( msg => 'Add new user',  btn_text => 'Add user', fields => $$param, valid => \@val_fields, link => $link);
  }
}


sub  remove {
  my $self = shift;
  my $id = $self->param( 'ID' );
  $self->delete_user( $id );
  $self->flash( message => 'The user was removed!' );
  $self->redirect_to( 'users' ); 
 }


sub check_email_password {
	my ( $email, $password, $date ) = @_; 
	( check_email( $email ) && check_password( $password ) && check_date( $date ) ) ? 1 :	0;
} 

sub check_email {
  my $email = shift;
  ( $email =~/^([a-z0-9_-]+\.*)*@[a-z0-9_-]+\.[a-z]{2,6}$/i ) ?  1 :  0;
}

sub check_password {
  my $password = shift;
  ( $password =~/^[a-zA-Z0-9]{6,}$/i ) ?  1 : 0;
}

sub check_date {
  my $date = shift;
  ( $date =~/^(\d{4}-\d{2}-\d{2}\s{1}\d{2}:\d{2}:\d{2})$/i ) ? 1 : 0;
}


sub is_exist_email {
  my ( $self, $email ) = @_;
  my $query = "select * from users where email = ? "; 
  my $res = $self->select_row( $query, $email );
  return  $res;
}



1;
