package App::Deployment::Tomcat;
use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request::Common;

=head1 NAME

  App::Deployment::Tomcat

=head2 SYNOPSIS

  Concrete implementation for managing applications at Apache Tomcat server manager interface

  http://tomcat.apache.org/tomcat-7.0-doc/manager-howto.htm

  This plugin accepts custom arguments
    uri   - string, manager uri
    ssl   - boolean, use https scheme (only needed unless 'uri' is specified)
    realm - custom Basic HTTP authentication realm

  Supported actions are
    deploy
    undeploy
    start
    stop
    check
    server_info

=cut

#**********************************************************
=head2 new(%conf)

  Arguments:
    %conf

  Returns:
    object

=cut
#**********************************************************
sub new {
  my $class = shift;

  my (%conf) = @_;

  die "Options --hostname and --port are mandatory \n" if (!$conf{username} || !$conf{port});

  my $self = {
    %conf
  };

  # Build URI
  my $proto = $self->{ssl}
    ? 'https'
    : 'http';

  # Allow to pass custom uri
  $self->{uri} = $conf{uri} || "$proto://$self->{hostname}:$self->{port}/manager/text";

  bless($self, $class);

  return $self;
}

#**********************************************************
=head2 deploy($application) - dummy for deploy()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub deploy {
  # Should build form with a file as content
  # And upload form via HTML manager interface

  return 0;
}

#**********************************************************
=head2 start($application) - start application at given path

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub start {
  return shift->_simple_request('start', @_);
}

#**********************************************************
=head2 stop($application) - stops application at given path

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub stop {
  return shift->_simple_request('stop', @_);
}

#**********************************************************
=head2 check($application) - dummy for check()

  Arguments:
     $application_path - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub check {
  my ($self, $application) = @_;

  # Get all applications
  my $all_applications_list = $self->_make_request('list');
  print $all_applications_list if ($self->{debug});

  # Find the one we need
  my @match = grep {$_ =~ /\/$application:/} split("\n", $all_applications_list);

  return "FAIL - No such application at server\n" if (!@match);

  my (undef, $status) = split(':', $match[0]);

  if (!$status || $status ne 'running') {
    print "FAIL - application $application is " . ($status || 'undefined status') . "\n";
    return 0;
  }
  else {
    print "OK - application $application is running\n";
    return 1;
  }
}

#**********************************************************
=head2 undeploy($application) - dummy for undeploy()

  Arguments:
     $application - path to application file

  Returns:
    boolean

=cut
#**********************************************************
sub undeploy {
  return shift->_simple_request('undeploy', @_);
}

#**********************************************************
=head2 server_info() - prints server info

  Returns:
    boolean

=cut
#**********************************************************
sub server_info {
  return shift->_simple_request('serverinfo');
}

#**********************************************************
=head2 _simple_request($application)

  Arguments:
    $application -

  Returns:


=cut
#**********************************************************
sub _simple_request {
  my ($self, $method, $application) = @_;

  my %params = ();
  if (defined $application) {
    $params{path} = '/' . _file_name_to_path($application);
  }

  my $result = $self->_make_request($method, %params);

  return 0 if !$result;

  print $result;
  return 1;
}
#**********************************************************
=head2 _make_request($action, %params)

  Arguments:
    $action, %params -

  Returns:


=cut
#**********************************************************
sub _make_request {
  my ($self, $action, %params) = @_;

  my $lwp = LWP::UserAgent->new();
  $lwp->credentials(
    "$self->{hostname}:$self->{port}",
    $self->{realm} || "Tomcat Manager Application",
    $self->{username},
    $self->{password}
  );

  # Build endpoint
  my $uri = "$self->{uri}/$action";

  # Add params if any
  if (scalar %params) {
    $uri .= '?' . _serialize_params(%params);
  }

  print "$uri\n" if ($self->{debug});

  my $response = $lwp->get($uri);

  unless ($response->is_success) {
    print $response->status_line . "\n";
    if ($self->{debug} && $self->{debug} > 1) {
      require Data::Dumper;
      print Data::Dumper::Dumper($response);
    }
    return 0;
  }

  return $response->decoded_content;
}

#**********************************************************
=head2 _serialize_params(%params)

=cut
#**********************************************************
sub _serialize_params {
  my (%params) = @_;

  my @pairs = ();

  while (my ($key, $value) = each(%params)) {
    #TODO: uriencode
    push(@pairs, "$key=$value");
  }

  return join('&', @pairs);
}

#**********************************************************
=head2 _file_name_to_path($name)

=cut
#**********************************************************
sub _file_name_to_path {
  my ($name) = @_;
  $name =~ s/\.[a-z]$//;
  return $name;
}

1;