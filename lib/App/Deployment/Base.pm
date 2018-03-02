package App::Deployment::Base;
use strict;
use warnings FATAL => 'all';

=head1 NAME

  Base - 

=head2 SYNOPSIS

  This package  

=cut

#**********************************************************
=head2 new(%conf) - constructor for App::Deployment::Base

=cut
#**********************************************************
sub new {
  use Data::Dumper;

  my $class = shift;

  my (%conf) = @_;

  my $self = {
    Name => $conf{server}
  };


  bless( $self, $class );

  return $self;
}

1;