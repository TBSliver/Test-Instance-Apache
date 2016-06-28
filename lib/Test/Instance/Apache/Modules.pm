package Test::Instance::Apache::Modules;

use Moo;
use IO::All;

has modules => (
  is => 'ro',
  required => 1,
  isa => sub { die "modules must be an array!\n" unless ref $_[0] eq 'ARRAY' },
);

has server_root => (
  is => 'ro',
  required => 1,
);

has _available_mods_folder => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return $self->make_server_dir( 'mods-available' );
  },
);

has _enabled_mods_folder => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return $self->make_server_dir( 'mods-enabled' );
  },
);

has include_modules => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    my @include;
    foreach ( qw/ load conf / ) {
      push @include, sprintf( '%s/*.%s', $self->_enabled_mods_folder, $_ );
    }
    return \@include;
  },
);

sub load_modules {
  my $self = shift;

  io->dir( '/etc/apache2/mods-available' )->copy( $self->_available_mods_folder );

  for my $module ( @{ $self->modules } ) {
    for my $suffix ( qw/ conf load / ) {
      my $source_filename = File::Spec->catfile(
        $self->_available_mods_folder,
        sprintf( '%s.%s', $module, $suffix )
      );
      my $target_filename = File::Spec->catfile(
        $self->_enabled_mods_folder,
        sprintf( '%s.%s', $module, $suffix )
      );
      if ( -f $source_filename ) {
        # if the file does not exist, just ignore it as not all mods have config files
        symlink( $source_filename, $target_filename );
      } 
    }
  }
}

sub make_server_dir {
  my ( $self, @dirnames ) = @_;
  my $dir = File::Spec->catdir( $self->server_root, @dirnames );
  mkdir $dir;
  return $dir;
}

1;
