#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use Data::Dumper;

use App::Deployment;
my $deployer = App::Deployment->new(
  server   => 'Tomcat',
  hostname => '127.0.0.1',
  port     => '8080',
  username => 'tomcat',
  password => 'tomcat'
);
my $test_app = 'examples.war';

#ok(simple_request($test_app, 'deploy'), 'Deploy');
ok(check_simple_request($test_app, 'check'), 'Application is running');
ok(check_simple_request($test_app, 'stop'), 'Stopped application');
ok(!check_simple_request($test_app, 'check'), 'Application stopped');
ok(check_simple_request($test_app, 'start'), 'Started application');

#ok($simple_request($test_app, 'indeploy', 'Undeploy');

done_testing();

1;

sub check_simple_request{
  my ($app, $operation) = @_;
  my $res = $deployer->$operation($app);

  return $res->{ok};
}