#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

use App::Deployment;

my App::Deployment $deployer = new_ok('App::Deployment', [
    server   => 'Tomcat',
    hostname => '127.0.0.1',
    port     => '8080',
    username => 'tomcat',
    password => 'tomcat'
  ]);

ok($deployer->get_name() eq 'Tomcat', "Deployer instatiated");

done_testing();

