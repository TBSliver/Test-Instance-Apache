package Test::Instance::Apache::Config;

use Moo;
use Config::General;

has filename => ( is => 'ro', required => 1 );

has _config_general => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return Config::General->new;
  },
);

has config => (
  is => 'ro',
  default => sub { return {} },
);

has _base_config => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return {
      %{$self->config},
    }
  },
);

sub write_config {
  my $self = shift;

  $self->_config_general->save_file( $self->filename, $self->_base_config );
}

1;
