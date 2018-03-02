#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use_ok('App::Deployment' => []);

my $deployment = new_ok('App::Deployment', [
    server => 'Tomcat'
  ]);

ok($deployment->get_server() eq 'Tomcat');

done_testing();

