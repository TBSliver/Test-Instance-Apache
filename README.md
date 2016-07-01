# NAME

Test::Instance::Apache - Create Apache instance for Testing

# SYNOPSIS

    use FindBin qw/ $Bin /;
    use Test::Instance::Apache;
    use Test::Instance::Apache::TiedHash;

    my $instance = Test::Instance::Apache->new(
      config => [
        VirtualHost => {
          '*' => Test::Instance::Apache::TiedHash->new( [
            DocumentRoot => "$Bin/root",
          ] )->hash,
        },
      ],
      modules => [ qw/ mpm_prefork authz_core mime / ],
    );

    $instance->run;

# DESCRIPTION

Test::Instance::Apache allows you to spin up a complete Apache instance for
testing. This is useful when developing various plugins for Apache, or if your
application is tightly integrated to the webserver.

## Attributes

These are the attributes available on Test::Instance::Apache.

### server\_root

The root folder for creating the Apache instance. This folder is passed to
Apache during instantiation as the server root configuration, and normally
contains all the configuration files for Apache. If not set during object
creation, a new folder will be created using File::Temp.

### conf\_dir

The directory for holding the configuration files. Defaults to
`$server_root/conf`. If set during object creation, then you will need to
create the folder manually.

### log\_dir

The directory for holding all the log files. Defaults to `$server_root/logs`.
If set during object creation, then you will need to create the folder
manually.

### conf\_file\_path

The path to the main configuration file. Defaults to `$conf_dir/httpd.conf`.
This is then used by [Test::Instance::Apache::Config](https://metacpan.org/pod/Test::Instance::Apache::Config) to create the base
configuration file.

### config

Takes an arrayref of values to pass to [Test::Instance::Apache::Config](https://metacpan.org/pod/Test::Instance::Apache::Config). This is
passed to [Config::General](https://metacpan.org/pod/Config::General) internally, so any hashref suitable for that
module will work here.

### modules

Takes an arrayref of modules to load into Apache. These are the same names as
they appear in `a2enmod`, so only the modules which are available on your
local machine can be used.

### pid\_file\_path

Path to the pid file for Apache. Defaults to `$server_root/httpd.pid`.

### listen\_port

Port for Apache master process to listen on. If not set, will use
[Net::EmptyPort::empty\_port](https://metacpan.org/pod/Net::EmptyPort::empty_port) to find an unused high-number port.

### apache\_httpd

Path to the main Apache process. Uses [File::Which::which](https://metacpan.org/pod/File::Which::which) to determine the
path of the binary from your `$PATH`.

### pid

Pid number for the main Apache process. Set during ["run"](#run) and then used during
["DEMOLISH"](#demolish) to kill the correct process.

## Methods

These are the various methods inside this module either for internal or basic
usage.

### run

Sets up all the pre-required folders, writes the config files, loads the
required modules, and then starts Apache itself.

### make\_server\_dir

Used internally to create folders under the server root. Will take an array of
directory names, which are then passed to File::Spec - so if you do the
following:

    $instance->make_server_dir( 'a', 'b', 'c' );

Then a path of `$server_root/a/b/c` will be created.

### get\_pid

Returns the contents of the first line of the pid file. Used internally to set
the pid after startup.

### get\_logs

This will return all the items in the log directory as a hashref of filename
and content. This is useful either during test development, or if you are
testing exceptions on your application. Please note that it does not recurse
subdirectories in the logs folder.

### debug

This is more for use during development of this module - prints out the path of
all the files and folders stored as attributes in this module.

### DEMOLISH

Kills the Apache instance started during run.

# AUTHOR

Tom Bloor &lt;t.bloor@shadowcat.co.uk>

# COPYRIGHT

Copyright 2016 Tom Bloor

# LICENCE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

- [Test::Instance::Apache::Config](https://metacpan.org/pod/Test::Instance::Apache::Config)
- [Test::Instance::Apache::Modules](https://metacpan.org/pod/Test::Instance::Apache::Modules)
- [Test::Instance::Apache::TiedHash](https://metacpan.org/pod/Test::Instance::Apache::TiedHash)
- [Apache::Test](https://metacpan.org/pod/Apache::Test)
