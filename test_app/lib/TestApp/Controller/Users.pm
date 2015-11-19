package TestApp::Controller::Users;
use base 'Mojolicious::Controller';    
use feature qw(switch say);
 
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
  $self->render(users => $users);
}

 
sub form {
my $self = shift;    
my $submit = $self->param( 'submit' );
my $id = $self->param( 'ID' );
my $param = $self->req->params->to_hash;
my $val_fields;
my $validator  = Mojolicious::Validator->new;
my $validation = $validator->validation;

if ( $id && ! defined $submit )  {
  my $query = "SELECT name, email, pass, sex, money, created FROM users WHERE ID = ?" ;
  my $users = $self->select_row( $query, $id ); 
  $self->render( user => $users, valid => $val_fields );
 }
elsif ( $submit ) {
  my $upload = $self->req->upload( 'uploadImage' );
  my $filename = $upload->filename;  
  $validation->input( $param );
  $validation->required( 'email' )->like( qr/^([a-z0-9_-]+\.*)*@[a-z0-9_-]+\.[a-z]{2,6}$/i );
  $validation->required( 'password' )->like( qr/^[a-zA-Z0-9]{6,}$/i );
  $validation->required( 'created' )->like( qr/^(\d{4}-\d{2}-\d{2}\s{1}\d{2}:\d{2}:\d{2})$/i );
  $validation->required( $filename )->like( qr/\.(?:jpe?g|png)$/i );
  for ( @{$validation->passed}) {
    $val_fields->{$_} = 1;
  }
  $upload->move_to( "public/img/$filename" ) if $val_fields->{uploadImage};
  $param->{uploadImage} = $filename || '';
    
  my $valid;
  if ( !$id ) {
    ( $valid = 0, $val_fields->{email} = 0 ) if is_exist_email( $self, $param->{email} );
  }
  else {
    $valid = $validation->is_valid( keys %$param );
  }
     
  if ( $valid ) { 
    my $query = "insert into users (name, email, pass, sex, money, created, photo) values ( ?, ?, MD5(?), ?, ?, ?, ? ) 
                on dublicate key update name = ? , email = ? , pass = MD5(?) , sex = ? , money = ? , created = ?, photo = ?";                    
    my $res = $self->execute_qw( $query, @param ); 
  	my $message;
    if ($res) {
        $message  = $id ? 'The user was edited!' : 'The user was added!'; 
  } 
    else {
        $message = 'Something wrong!'; 
    }
    $self->flash(message =>  $message);
    $self->redirect_to( 'show_users'); 
  } 
  else{
     $self->render( user => $param, valid => $val_fields );
  }
} 
else {  
  $self->render( user => $param, valid => $val_fields );
  }
}


sub  remove {
  my $self = shift;
  my $id = $self->param( 'ID' );
  my $query = "delete from users WHERE id = ?";
  $self->execute_qw( $auery, $id );
  $self->flash( message => 'The user was removed!' );
  $self->redirect_to( '/users' ); 
 }

 

sub is_exist_email {
  my ( $self, $email ) = @_;
  my $query = "select * from users where email = ? "; 
  my $res = $self->select_row( $query, $email );
  return  $res;
}



1;
