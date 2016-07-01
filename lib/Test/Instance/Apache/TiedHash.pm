package Test::Instance::Apache::TiedHash;

use Moo;
use Tie::IxHash;

=head1 NAME

Test::Instance::Apache::TiedHash - Create ordered hashes for Apache configs

=head1 SYNOPSIS

  use Test::Instance::Apache::TiedHash

  my $tiedhash = Test::Instance::Apache::TiedHash->new([
    first_item => 'banana',
    second_item => 'strawberry',
    third_item => 'grenade',
  ]);

  # get the items as an array
  my $array = $tiedhash->array;

  # get the items as an ordered hash
  my $hash = $tiedhash->hash;

=head1 DESCRIPTION

Test::Instance::Apache::TiedHash is a simplified wrapper around L<Tie::IxHash>
for use in Test::Instance::Apache modules and testframeworks based on it. The
main reason for this module is due to a 'limitation' in Config::General in
that it can only accept a hashref for the configuration object, which means
that the ordering is random (or can be set to be sorted alphabetically).

This becomes an issue with Apache, as it reads the configuration files top to
bottom, and certain configuration items require being in a certain order (for
example, loading of perl lib folders before calling code from them).

=head2 Usage

This module can be built in two ways - either with a single argument to
C<new()> or with the named-argument version:

  my $single_arg = Test::Instance::Apache::TiedHash->new( [
    first_item => 'banana',
    second_item => 'strawberry',
    third_item => 'grenade',
  ] );

  my $named_arg = Test::Instance::Apache::TiedHash->new(
    array => [
      first_item => 'banana',
      second_item => 'strawberry',
      third_item => 'grenade',
    ],
  );

There is no functional difference between the two, the latter is only useful if
more functions and features are added to this module in the future.

=cut

around BUILDARGS => sub {
  my ( $orig, $class, @args ) = @_;

  return { array => $args[0] }
    if @args == 1;
       
  return $class->$orig( @args );
};

=head2 Attributes

=head3 array

The arrayref to use to create the tied hash

=cut

has array => (
  is => 'ro',
  required => 1,
  isa => sub { die "modules must be an array!\n" unless ref $_[0] eq 'ARRAY' },
);

=head3 hash

An ordered hashref using L<Tie::IxHash> on the array.
=cut

has hash => (
  is => 'lazy',
  builder => sub {
    my $self = shift;
    tie my %hash, 'Tie::IxHash', @{ $self->array };
    return \%hash;
  },
);

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

=item * L<Test::Instance::Apache::Config>

=item * L<Tie::IxHash>

=back

=cut

1;
