package App::DB;
use base Mojolicious;
use DBI;
use feature qw (say switch);

sub conn {
  say "hello";
}

1;