package App::Deployment;
use strict;
use warnings FATAL => 'all';

=head1 NAME

  App::Deployment

=head2 SYNOPSIS

  This package

=cut

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

  my $self = { %conf };

  bless( $self, $class );

  die "'server' option is mandatory" unless $self->{server};

  eval {
    require "App/Deployment/$self->{server}.pm";
    "App::Deployment::$self->{server}"->import();

    $self->{Host} = "App::Deployment::$self->{server}"->new(%conf);
  };
  if ($@){
    die "Unknown server given ($self->{server}).\n $@";
  }

  return $self;
};


#**********************************************************
=head2 get_server() - returns server plugin name

  Arguments:
     -

  Returns:


=cut
#**********************************************************
sub get_server {
  my $self = shift;

  return $self->{Host}->{Name};
}


1;