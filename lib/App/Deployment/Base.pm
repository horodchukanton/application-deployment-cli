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
  my $class = shift;

  my (%conf) = @_;

  my $self = {
    %conf
  };


  bless( $self, $class );

  return $self;
}

#**********************************************************
=head2 get_name() - returns server plugin name

=cut
#**********************************************************
sub get_name {
  my $self = shift;
  return $self->{server};
}

#**********************************************************
=head2 is_reachable() - checks if application server responds

  Returns:
    boolean

=cut
#**********************************************************
sub is_reachable {
  my ($self) = @_;

  return 0;
}

#**********************************************************
=head2 deploy($application_path) - dummy for deploy()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub deploy {
  die "Not implemented\n";
}

#**********************************************************
=head2 start($application_path) - dummy for start()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub start {
  die "Not implemented\n";
}

#**********************************************************
=head2 check($application_path) - dummy for check()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub check {
  die "Not implemented\n";
}

#**********************************************************
=head2 undeploy($application_path) - dummy for undeploy()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub undeploy {
  die "Not implemented\n";
}


1;