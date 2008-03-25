#!/usr/bin/perl
use Test::More tests => 9;
use strict;

BEGIN
{
    require_ok('CGI::Application::Plugin::Flash');
}

{
    package TestApp;
    use base 'CGI::Application';
    use CGI::Application::Plugin::Flash;

    sub session { return bless {}, 'My::Session'; }

    package My::Session;
    our @ISA = 'CGI::Session';

    sub param
    {
        return undef
    };
}

my $app = TestApp->new;

# Make sure that the flash and flash_now methods were exported.
can_ok($app, qw/flash flash_config/);

# Setting flash_config.
ok($app->flash_config(session_key => 'TESTING'), "set flash_config");

# Make sure that we get the same object back on subsequent tries.
my $flash = $app->flash;
is($app->flash, $flash, "got the same object");
is($flash->session_key, 'TESTING', "flash used flash_config");

# Getting flash_config.
my %config = $app->flash_config;
my $config = scalar $app->flash_config;
is(scalar keys %config, 1, "flash_config can return a list");
is_deeply(\%config, { 'session_key' => 'TESTING' }, "  data is right");
is(ref $config, 'HASH', "flash_config in scalar is ref");
is_deeply(\%config, $config, "  matches list data");
