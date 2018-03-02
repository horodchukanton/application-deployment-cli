#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use App::Deployment;
my $deployer = App::Deployment->new(
  server   => 'Tomcat',
  hostname => '127.0.0.1:8080',
  user     => 'tomcat',
  password => 'tomcat'
);

SKIP : {
  skip ('Server is not reachable', 1) if (!$deployer->is_reachable);
  ok($deployer->authenticate(), 'Authenticated');
  ok($deployer->server_info(), 'Got server info');
}

done_testing();

