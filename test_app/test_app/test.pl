#!/usr/bin/env perl
use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Hell!!!'); 
  $c->get('/')->to('users#list');
};

app->start;