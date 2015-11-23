package TestApp::Controller::Users;
use base 'Mojolicious::Controller';

sub list {
  my $self = shift;
  my $query;
  my $searching_string = $self->param( 'search_str' );
  if ( $searching_string ) {
    $query =  "select * from users where match (name, email) against ( ? )";
  }
  else {
    $query =  "select * from users";
  }
  my $users = $self->select_rows( $query, $searching_string );
  $self->respond_to(
    json =>     { json => { status => ok, $users } },
    html => sub { return $self->render(users => $users);}
     );
}

sub form {
  my $self = shift;
  my $id          = $self->param( 'ID' );
  my $params      = $self->req->params->to_hash;
  my $validator   = Mojolicious::Validator->new;
  my $validation  = $validator->validation;

  if ( $self->param( 'submit' ) ) {
    my $upload    = $self->req->upload( 'uploadImage' );
    my $filename  = $upload->filename;
    $params->{img}= $filename;
    $validation->input( $params );

    $validation->required( 'email'    )->like( qr/^([a-z0-9_-]+\.*)*@[a-z0-9_-]+\.[a-z]{2,6}$/i );
    $validation->required( 'password' )->like( qr/^[a-z0-9]{6,}$/i );
    $validation->required( 'name'     )->like( qr/^[a-z]{4,20}$/i );
    $validation->required( 'created'  )->like( qr/^(\d{4}-\d{2}-\d{2}\s{1}\d{2}:\d{2}:\d{2})$/i );
    $validation->optional( 'img'      )->like( qr/\.(?:jpe?g|png)$/i );

    %$val_fields = map { $_ => 1 } @{$validation->passed};
    my $valid    = ! $validation->has_error;
    $valid = $val_fields->{email} = 0 if ( exists_email( $self, $params->{email} ) && !$id );
    if ( $valid ) {
      my $query = "insert into users set name = ?, email = ?, pass = MD5(?), sex = ?, money = ?, created = ?
       on duplicate key update name = values(name), email = values(email), pass = values(pass), sex = values(sex), money = values(money), created = values(created)";
      my @values = @$params{name, email, password, sex, money, created};
      my $res = $self->execute_qw( $query, @values);
      my $message;
      if ( $res ) {
        if ( $validation->is_valid( 'img' ) ) {
          my $query   = "select id from users where email = ?";
          my $img_id  = $self->select_row( $query, $params->{email} )->{id};
          $filename   =~ s/.+\.(jpe?g|png)$/$img_id\.$1/i;
          my $query   = "update users set photo = ? where id = ?";
          $self->execute_qw( $query, $filename, $img_id );
          $upload ->move_to( "public/img/$filename");
        }
        $message = $id ? 'The user was edited!' : 'The user was added!';
      }
      else {
          $message = 'Something wrong!';
      }
      $self->flash( message => $message );
      $self->redirect_to( 'show_users' );
    }
    else{
       return $self->render( user => $params, valid => $val_fields );
    }
  }
  elsif ( $id ) {
    my $query   = "select name, email, pass, sex, money, created from users where id = ?";
    my $user    = $self->select_row( $query, $id );
    return $self->render( user => $user, valid => $val_fields );
  }
  else {
    return $self->render( user => $params, valid => $val_fields );
  }
}

sub remove {
  my $self  = shift;
  my $id    = $self->param( 'ID' );
  my $query = "delete from users where id = ?";
  $self->execute_qw( $query, $id );
  $self->flash( message => 'The user was removed!' );
  $self->redirect_to( 'show_users' );
}

sub exists_email {
  my ( $self, $email ) = @_;
  my $query = "select * from users where email = ?";
  my $res   = $self->select_row( $query, $email );
  return $res;
}


1;
