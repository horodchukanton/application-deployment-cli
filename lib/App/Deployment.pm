package App::Deployment;
use strict;
use warnings FATAL => 'all';

=head1 NAME

  App::Deployment

=head2 SYNOPSIS

  This package is an Adapter for application server classes that are located under App::Deployment::* namespace

  For simplicity we use AUTOLOAD to keep interface clear and integral.
  This gives ability to change concrete implementation later saving backward compatibility

=cut

use File::Spec;

# Transparent passing function call to underlying plugin
AUTOLOAD {
  our $AUTOLOAD;

  my $func_name = $AUTOLOAD;
  $func_name =~ s/.*:://;
  my ($self, @args) = @_;
  die "Call of undefined function $func_name " if (!$self->{Host}->can($func_name));

  return $self->{Host}->$func_name(@args);
}

#**********************************************************
=head2 new(%conf)

  Arguments:
    %conf


  Returns:
    object

=cut
#**********************************************************
sub new{
  my $class = shift;
  my (%conf) = @_;
  die "'server' option is mandatory" unless $conf{server};

  my $self = { %conf };
  bless( $self, $class );

  # Load plugin
  eval {
    require File::Spec->catfile('App', 'Deployment', "$self->{server}.pm");
    "App::Deployment::$self->{server}"->import();
    $self->{Host} = "App::Deployment::$self->{server}"->new(%conf);
  };
  if ($@){
    die "Failed to instantiate server plugin ($self->{server}).\n; $@";
  }

  return $self;
};

#**********************************************************
=head2 get_name()

  Returns:
    name of underlying server

=cut
#**********************************************************
sub get_name {
  my ($self) = @_;

  return $self->{server};
}

#**********************************************************
=head2 is_reachable() - checks if application server is reachable

  Arguments:
     -

  Returns:


=cut
#**********************************************************
sub is_reachable {
  my ($self) = @_;

  require Net::Ping;
  Net::Ping->import();

  my $p = Net::Ping->new('icmp', 2);

  # Will connect to port we use for management
  $p->port_number($self->{port});
  $p->open($self->{hostname});
  return $p->service_check();
}

#**********************************************************
=head2 have_method($method) - checks application server for implemented method

  Arguments:
    $method - string, method name

  Returns:
    boolean

=cut
#**********************************************************
sub have_method {
  my ($self, $method) = @_;
  return $self->{Host}->can($method);
}

# Added empty DESTROY because of AUTOLOAD usage
DESTROY {};

1;