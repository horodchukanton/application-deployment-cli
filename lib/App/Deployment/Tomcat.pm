package App::Deployment::Tomcat;
use strict;
use warnings FATAL => 'all';

=head1 NAME

  App::Deployment::Tomcat

=head2 SYNOPSIS

  Concrete implementation for managing applications at Apache Tomcat server

=cut

1;
#**********************************************************
=head2 deploy($application_path) - dummy for deploy()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub deploy {
  return 1;
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
  return 1;
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
  return 1;
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
  return 1;
}
