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

ok($deployer->deploy(), 'deploy');
ok($deployer->start(), 'start');
ok($deployer->check(), 'check_application');
ok($deployer->undeploy(), 'undeploy');

done_testing();

