#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
=head1 NAME

  Simple deployment script

=head1 VERSION

  0.01

=head1 SYNOPSIS

  deploytool.pl - script for managing deployed application.

  Arguments:
    --config,     path to a config file in 'key=value\n' style
                  all options passed by command line overrides config values

    --action      string, deploy|check|undeploy|start
    --application string, hello-world.war

    --server      string, name of server plugin to use
    --plugin=s    string, allow to pass custom args to plugin (--plugin upload=~/app.war --plugin ssl=1)

    --hostname    server IP or FQDN
    --port        server port
    --user
    --password

    --debug

=head1 PURPOSES

  - Deploy application
  - Start application
  - Check if application works and responses
  - Undeploy application
  - Check if application no longer available

=cut

use v5.16;
our $VERSION = 0.01;

# Core modules from at least Perl 5.6
use Getopt::Long qw/GetOptions HelpMessage :config auto_help auto_version ignore_case/;
use Pod::Usage qw/pod2usage/;
use POSIX qw/strftime/;

our %OPTIONS;

BEGIN {
  %OPTIONS = (
    config      => '',
    action      => '',
    application => '',
    server      => '',
    username    => '',
    password    => '',
#    auth        => '',
    hostname    => '',
    port        => '',

    debug       => 0,
  );

  GetOptions(
    'config=s'      => \$OPTIONS{config},
    'application=s' => \$OPTIONS{application},
    'action=s'      => \$OPTIONS{action},
    'server=s'      => \$OPTIONS{server},
    'username=s'    => \$OPTIONS{username},
    'password=s'    => \$OPTIONS{password},
#    'auth=s'        => \$OPTIONS{auth},
    'hostname=s'    => \$OPTIONS{hostname},
    'port=i'        => \$OPTIONS{port},
    'debug=i'       => \$OPTIONS{debug},
    'plugin=s'      => \%OPTIONS,
  ) or die pod2usage();
}

# Should read config if given
if ($OPTIONS{config}) {
  parse_config($OPTIONS{config});
}

# Then will check if have all mandatory arguments
my @mandatory_args = qw/server username password hostname port action/;
my @missing_args = ();
foreach my $arg (@mandatory_args) {
  push (@missing_args, $arg) unless ($OPTIONS{$arg});
};
die join("\n", map {"Option --$_ is required"} @missing_args) if @missing_args;

# Now when we have all info can create module instance
require App::Deployment;
App::Deployment->import();
my $deployer = App::Deployment->new(%OPTIONS);

# Check if we got approriate action
my $action = $OPTIONS{action};
die "Unknown action '$action' for server $OPTIONS{server}" unless $deployer->have_method($action);

#TODO: logging

# Execute
my $operation_result = $deployer->$action($OPTIONS{application});

if ($operation_result && $operation_result->{status}){
  print $operation_result->{status};
}

exit ($operation_result && $operation_result->{ok})
       ? 0 # success
       : 1; # failure

#**********************************************************
=head2 parse_config($filename) - reads and applies values from config

=cut
#**********************************************************
sub parse_config {
  my ($filename) = @_;

  die "File does not exists $filename \n" unless (-f $filename);

  open (my $config_fh, '<', $filename) or die "Can't open file $filename : $!";

  while (my $entry = <$config_fh>) {
    chomp $entry;
    my ($key, $value) = split('=', $entry, 2);

    # TODO: should I validate values here?
    $OPTIONS{$key} ||= $value;
  }
}

exit 0;