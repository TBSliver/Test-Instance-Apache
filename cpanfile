requires 'Moo';
requires 'File::Which';
requires 'IPC::System::Simple';
requires 'namespace::clean';
requires 'Net::EmptyPort';
requires 'IO::All';
requires 'File::Copy::Recursive';
requires 'List::Util' => '1.29';

on 'configure' => sub {
  requires 'File::Which';
};

on 'test' => sub {
  requires 'Test::More';
  requires 'Test::WWW::Mechanize';
  requires 'IO::All';
  requires 'Test::Exception';
};
