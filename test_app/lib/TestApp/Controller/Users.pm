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
    $validation->optional( $filename )->like( qr/\.(?:jpe?g|png)$/i );
    for ( @{$validation->passed}) {
      $val_fields->{$_} = 1;
    }
    my $valid;
    if ( !$id ) {
      ( $valid = 0, $val_fields->{email} = 0 ) if is_exist_email( $self, $param->{email} );
    }
    else {
      $valid = ! scalar @{$validation->failed};
    }
       
    if ( $valid ) {
      my $query = "insert into users (name, email, pass, sex, money, created) values ( ?, ?, MD5(?), ?, ?, ? ) on duplicate key update name = ?, email = ?, pass = ?, sex = ?, money = ?, created = ?";
      my @values = @$param{name, email, password, sex, money, created};
      my $res = $self->execute_qw( $query, @values, @values);
    	my $message;
      if ($res) {
        $message  = $id ? 'The user was edited!' : 'The user was added!';
        my $query = "select id from users where email = ?";
        my $id = $self->select_row( $query, $param->{email} );
        $filename =~ s/.+\.(jpe?g|png)$/$id->{id}\.$1/i; 
        my $query = "update users set photo = ? where id = ?";
        $self->execute_qw( $query, $filename, $id->{id} );
        $upload->move_to( "public/img/$filename") ;
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
  $self->execute_qw( $query, $id );
  $self->flash( message => 'The user was removed!' );
  $self->redirect_to( 'show_users' ); 
 }



sub is_exist_email {
  my ( $self, $email ) = @_;
  my $query = "select * from users where email = ? ";
  my $res = $self->select_row( $query, $email );
  return  $res;
}



1;
