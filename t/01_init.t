#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

use App::Deployment;

my App::Deployment $deployer = new_ok('App::Deployment', [
    server => 'Tomcat'
  ]);

ok($deployer->get_name() eq 'Tomcat', "Deployer instatiated");

done_testing();

