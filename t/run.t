use strict;
use warnings;

use FindBin qw /$Bin /;
use Test::More;
use Test::WWW::Mechanize;
use Test::Instance::Apache;

my $instance = Test::Instance::Apache->new(
  config => {
    #Include "$Bin/conf/test.conf",
    VirtualHost => {
      '*' => {
        DocumentRoot => "$Bin/root",
      },
    },
  },
  modules => [ qw/ mpm_prefork authz_core mime / ],
);

$instance->run;

my $mech = Test::WWW::Mechanize->new;

$mech->get_ok( "http://localhost:${\$instance->listen_port}/index.html" );
$mech->title_is( "Hello Test" );
$mech->text_contains( "Welcome" );

done_testing;
