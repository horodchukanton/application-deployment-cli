package App::Deployment::Tomcat;
use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use File::Temp;

=head1 NAME

  App::Deployment::Tomcat

=head2 SYNOPSIS

  Concrete implementation for managing applications at Apache Tomcat server manager interface

  http://tomcat.apache.org/tomcat-7.0-doc/manager-howto.htm

  This plugin accepts custom arguments
    uri     - string, manager uri
    ssl     - boolean, use https scheme (only needed unless 'uri' is specified)
    upload  - string, file to upload as application
    realm   - custom Basic HTTP authentication realm

  Supported actions are
    deploy
    undeploy
    start
    stop
    check
    server_info

  User that runs start, stop, check, deploy, undeploy should have 'manager-script' role
  If you want to upload *.war files to server, you should also add 'manager-gui' reole

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
  $self->{base_uri} = $conf{uri} || "$proto://$self->{hostname}:$self->{port}/";
  $self->{uri} = $self->{base_uri} . "manager/text";

  # Create agent
  my $lwp = LWP::UserAgent->new();

  $lwp->credentials(
    "$self->{hostname}:$self->{port}",
    $self->{realm} || "Tomcat Manager Application",
    $self->{username},
    $self->{password}
  );

  $lwp->cookie_jar({ file => "$ENV{HOME}/.deployment.cookies.txt" });

  $self->{lwp} = $lwp;

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
  my ($self, $application) = shift;

  if ($self->{upload}){
    # Should build form with a file as content
    # and upload form via HTML manager interface
    my HTTP::Response $response = $self->_upload(
      $self->{base_uri} . '/manager/html/upload',
      $self->{upload}
    );

    if (!$response->is_success){
      return {
        ok     => 0,
        status => $response->status_line
      }
    }
    else {
      my $result = $response->decoded_content();
      print $result;
      exit;
    }
  }

  my $app_name = _file_name_to_path($application || $self->{upload});
  return $self->_simple_request('deploy', $app_name);
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

  my $app = _file_name_to_path($application);

  # Find the one we need
  my @match = grep {$_ =~ /\/$app:/} split("\n", $all_applications_list);

  if (!@match) {
    return {
      ok     => 0,
      status => "FAIL - No such application at server\n"
    };
  }

  my ($ok, $reply);
  my (undef, $status) = split(':', $match[0]);
  if (!$status || $status ne 'running') {
    $reply = "FAIL - application $app is " . ($status || 'undefined status') . "\n";
    $ok = 0;
  }
  else {
    $reply = "OK - application $app is running\n";
    $ok = 1;
  }

  return {
    ok     => $ok,
    status => $reply
  }
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
    $application

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

  if (!$result) {
    return {
      ok     => 1,
      status => 'Empty response'
    };
  }

  # Return fail immediately
  return $result if (ref $result eq 'HASH');

  print $result;

  return {
    ok     => scalar($result =~ /^OK/),
    status => $result
  };
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

  # Build endpoint
  my $uri = "$self->{uri}/$action";

  # Add params if any
  if (scalar %params) {
    $uri .= '?' . _serialize_params(%params);
  }

  print "$uri\n" if ($self->{debug});

  my LWP::UserAgent $lwp = $self->{lwp};
  my HTTP::Response $response = $lwp->get($uri);

  unless ($response->is_success) {
    if ($self->{debug} && $self->{debug} > 1) {
      require Data::Dumper;
      print Data::Dumper::Dumper($response);
    }

    return {
      ok     => 0,
      status => 'FAIL - ' . $response->status_line
    };
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
=head2 _upload($manager_path, $file_path) - uploads file to Server

  # This is quite dirty way to upload a file. Better use FTP or SFTP


  Arguments:
    $file_path -
    
  Returns:

    
=cut
#**********************************************************
sub _upload {
  my ($self, $manager_path, $file_path) = @_;

  my LWP::UserAgent $lwp = $self->{lwp};

  # At first need to get NONCE to build request URL.
  # We can do this using any request

  my HTTP::Response $info_response = $lwp->get($self->{base_uri} . 'manager/html');
  return {
    ok     => 0,
    status => $info_response->status_line,
  } unless ($info_response->is_success);

  my ($csrf_nonce) = $info_response->decoded_content() =~ /CSRF_NONCE=([0-9A-Z]+)/;
  die "No CSRF in response" unless $csrf_nonce;

  my $upload_request = HTTP::Request::Common::POST(
    $manager_path . '?org.apache.catalina.filters.CSRF_NONCE=' . $csrf_nonce,
    Content_Type => 'multipart/form-data',
    Content      => [ deployWar => [ $file_path ], submit => 'Deploy' ]
  );

  my HTTP::Response $response = $lwp->request($upload_request);

  return $response;
}
#**********************************************************
=head2 _file_name_to_path($name)

=cut
#**********************************************************
sub _file_name_to_path {
  my ($name) = @_;
  $name =~ s/\.[a-z]*$//;
  return $name;
}

DESTROY {
  # clear temprorary files
#  unlink "$ENV{HOME}/.deployment.cookies.txt";
}

1;