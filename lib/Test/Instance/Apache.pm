package Test::Instance::Apache;

use Moo;
use File::Temp;
use File::Spec;
use File::Which qw/ which /;
use IPC::System::Simple qw/ capture /;
use Net::EmptyPort qw/ empty_port /;
use IO::All;

use Test::Instance::Apache::Config;
use Test::Instance::Apache::Modules;

use namespace::clean;

our $VERSION = '0.001';

has _temp_dir => (
  is => 'lazy',
  builder => sub {
    return File::Temp->newdir;
  },
);

has server_root => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return $self->_temp_dir->dirname;
  },
);

sub make_server_dir {
  my ( $self, @dirnames ) = @_;
  my $dir = File::Spec->catdir( $self->server_root, @dirnames );
  mkdir $dir;
  return $dir;
}

has conf_dir => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return $self->make_server_dir( 'conf' );
  },
);

has log_dir => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return $self->make_server_dir( 'logs' );
  },
);

has conf_file_path => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return File::Spec->catfile( $self->conf_dir, 'httpd.conf' );
  },
);

has conf_file => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return Test::Instance::Apache::Config->new(
      filename => $self->conf_file_path,
      config => {
        PidFile => $self->pid_file_path,
        Listen  => $self->listen_port,
        Include => $self->_module_manager->include_modules,
        %{$self->config},
      }
    );
  },
);

has config => (
  is => 'ro',
  default => sub { return {} },
);

has modules => (
  is => 'ro',
  required => 1,
  isa => sub { die "modules must be an array!\n" unless ref $_[0] eq 'ARRAY' },
);

has _module_manager => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return Test::Instance::Apache::Modules->new(
      modules => $self->modules,
      server_root => $self->server_root,
    );
  },
);

has pid_file_path => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return File::Spec->catfile( $self->server_root, 'httpd.pid' );
  },
);

has listen_port => (
  is => 'lazy',
  builder => sub {
    return empty_port;
  },
);

has apache_httpd => (
  is => 'lazy',
  builder => sub {
    my $httpd;
    for my $name (qw/ httpd apache apache2 /) {
      $httpd = which( $name );
      return $httpd if defined $httpd;
    }
    die "Apache server program not found - please check your path\n";
  },
);

has pid => ( is => 'rwp' );

sub _httpd_cmd {
  my $self = shift;

  return join ( ' ', $self->apache_httpd,
    '-d', $self->server_root,
    '-f', $self->conf_file_path,
  );
}

sub run {
  my $self = shift;

  $self->conf_file->write_config;
  $self->_module_manager->load_modules;
  $self->log_dir;

  # capture will wait until the standard apache fork has finished
  capture( $self->_httpd_cmd );

  $self->_set_pid( $self->get_pid );
}

sub get_pid {
  my $self = shift;

  my $pid = undef;
  if ( -f $self->pid_file_path ) {
    open( my $fh, '<', $self->pid_file_path );
    $pid = <$fh>; # read first line
    close $fh;
  }

  return $pid;
}

sub get_logs {
  my $self = shift;

  my $logs = {};
  my @files = io->dir( $self->log_dir )->all;
  for my $file ( @files ) {
    $logs->{ $file->filename } = $file->slurp;
  }

  return $logs;
}

sub debug {
  my $self = shift;
  for my $item ( qw/ server_root conf_dir conf_file_path apache_httpd / ) {
    my $string = sprintf( "%16s | [%s]\n", $item, $self->$item );
    print $string;
  }
}

sub DEMOLISH {
  my $self = shift;

  if ( my $pid = $self->pid ) {
    # print "Killing apache with pid " . $pid . "\n";
    kill 'TERM', $pid;
  }
}

1;
