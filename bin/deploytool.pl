use strict;
use warnings FATAL => 'all';
=head1 NAME

  Simple deployment script

=head1 VERSION

  0.01

=head1 SYNOPSIS

  deploytool.pl - script for managing deployed application.

  Arguments:
    --config, path to a config file in .bashrc style (key=value\n)
    --action deploy|check|undeploy|start
    --application hello-world.war
    --hostname
    --user
    --password

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
    server      => 'Tomcat',
    username    => 'tomcat',
    password    => 'tomcat',
    auth        => 'basic',
    hostname    => '127.0.0.1',
    port        => '8080',

    debug       => 1,
  );

  GetOptions(
    'config=s'   => \$OPTIONS{config},
    'action=s'   => \$OPTIONS{action},
    'server=s'   => \$OPTIONS{server},
    'username=s' => \$OPTIONS{username},
    'password=s' => \$OPTIONS{password},
    'auth=s'     => \$OPTIONS{auth},
    'hostname=s' => \$OPTIONS{hostname},
    'port=i'     => \$OPTIONS{port},
    'debug=i'    => \$OPTIONS{debug},
  ) or die pod2usage();
}

# Should read config if given
if ($OPTIONS{config}) {
  die "File does not exists $OPTIONS{config} \n" unless (-f $OPTIONS{config});

  open (my $config_fh, '<', $OPTIONS{config}) or die "Can't open file $OPTIONS{config} : $!";

  while (my $entry = <$config_fh>) {
    chomp $entry;
    my ($key, $value) = split('=', $entry, 2);

    # TODO: should I validate values here?
    $OPTIONS{$key} = $value;
  }
}

# Then will check if have all mandatory arguments
my @mandatory_args = qw/server username password hostname port action/;
foreach my $arg (@mandatory_args) {
  die "Option --$arg is required \n" unless ($OPTIONS{$arg});
};

# Now when we have all info can create module instance
require App::Deployment;
App::Deployment->import();
my $deployer = App::Deployment->new(%OPTIONS);

# Check if we got approriate action
die "Unknown action $OPTIONS{action}" unless $deployer->have_method($OPTIONS{action});


exit 0;