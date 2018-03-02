use strict;
use warnings FATAL => 'all';
=head1 NAME

  Simple deployment script

=head1 VERSION

  0.01

=head1 SYNOPSIS

  deploytool.pl - script for managing deployed application

  Arguments:
    --config
    --action deploy
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

our $VERSION = 0.01;

# Core modules from at least Perl 5.6
use Getopt::Long qw/GetOptions HelpMessage :config auto_help auto_version ignore_case/;
use Pod::Usage qw/pod2usage/;
use POSIX qw/strftime/;

our (%conf, @MODULES, %OPTIONS);

BEGIN {
  %OPTIONS = (
    skip_check_sql => '',
    skip_backup    => '',
    clean          => '',
    renew_license  => '',
    PREFIX         => '/usr/abills',
    TEMP_DIR       => '/tmp',
    GIT_BRANCH     => 'master',
    SOURCE         => 'git',
    DEBUG          => 0,
    GIT_REPO_HOST  => 'git@abills.net.ua',
    USERNAME       => '',
    PASSWORD       => '',
    update_sql     => '',
  );

  GetOptions(
    'debug|D=i'                     => \$OPTIONS{DEBUG},
    'branch=s'                      => \$OPTIONS{GIT_BRANCH},
    'clean'                         => \$OPTIONS{clean},
    'prefix=s'                      => \$OPTIONS{PREFIX},
    'tempdir=s'                     => \$OPTIONS{TEMP_DIR},
    'source=s'                      => \$OPTIONS{SOURCE},
    'git-repo=s'                    => \$OPTIONS{GIT_REPO_HOST},
    'skip_check_sql|skip-check-sql' => \$OPTIONS{skip_check_sql},
    'skip_backup|skip-backup'       => \$OPTIONS{skip_backup},
    'login=s'                       => \$OPTIONS{USERNAME},
    'password=s'                    => \$OPTIONS{PASSWORD},
    'dl|license'                    => \$OPTIONS{renew_license},
    'sql-update|sql_update'         => \$OPTIONS{update_sql}
  ) or die pod2usage();

  if (!-d $OPTIONS{PREFIX} && !-d "$OPTIONS{PREFIX}/lib") {
    die " --prefix should point to abills sources dir\n";
  }
}
