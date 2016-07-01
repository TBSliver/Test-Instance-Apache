package Test::Instance::Apache::Config;

use Moo;
use Config::General;
use Test::Instance::Apache::TiedHash;

=head1 NAME

Test::Instance::Apache::Config - Create Apache Config File

=head1 SYNOPSIS

  use FindBin qw/ $Bin /;
  use Test::Instance::Apache::Config;

  $config_manager = Test::Instance::Apache::Config->new(
    filename => "$Bin/conf/httpd.conf",
    config => [
      PidFile => "$Bin/httpd.pid",
      Include => [ "$Bin/mods_enabled/*.load", "$Bin/mods_enabled/*.conf" ],
    ],
  );

  $config_manager->write_config;

=head1 DESCRIPTION

Test::Instance::Apache allows you to spin up a complete Apache instance for
testing. This is useful when developing various plugins for Apache, or if your
application is tightly integrated to the webserver.

=head2 Attributes

These are the attributes available to set on a new object.

=head3 filename

The target filename to write the new config file to.

=cut

has filename => ( is => 'ro', required => 1 );

has _config_general => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return Config::General->new;
  },
);

=head3 config

The arrayref to use to create the configuration file

=cut

has config => (
  is => 'ro',
  default => sub { return [] },
);

has _tied_config => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    return Test::Instance::Apache::TiedHash->new( array => $self->config )->hash;
  },
);

=head2 Methods

=head3 write_config

Write the config hashref to the target filename, using L<Config::General>.

=cut

sub write_config {
  my $self = shift;

  $self->_config_general->save_file( $self->filename, $self->_tied_config );
}

=head1 AUTHOR

Tom Bloor E<lt>t.bloor@shadowcat.co.ukE<gt>

=head1 COPYRIGHT

Copyright 2016 Tom Bloor

=head1 LICENCE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=over

=item * L<Test::Instance::Apache>

=item * L<Test::Instance::Apache::Modules>

=back

=cut

1;
