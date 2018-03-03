#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use App::Deployment;
my $deployer = App::Deployment->new(
  server   => 'Tomcat',
  hostname => '127.0.0.1',
  port     => '8080',
  username => 'tomcat',
  password => 'tomcat'
);

ok($deployer->deploy('examples'), 'deploy');
ok($deployer->stop('examples'), 'Stopped application');
ok(!$deployer->check('examples'), 'Application stopped');
ok($deployer->start('examples'), 'Started application');
ok($deployer->check('examples'), 'Application is running');
#ok($deployer->undeploy('examples'), 'undeploy');

done_testing();

