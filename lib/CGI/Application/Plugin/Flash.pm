package CGI::Application::Plugin::Flash;
use Carp;
use CGI::Session::Flash;
use strict;

our $VERSION = "0.01";


# Export our flash functions and set up the necessary CGI::Application
# hooks.
sub import
{
    my $package = shift;
    my $caller  = caller;

    # Export the flash methods
    {
        no strict 'refs';
        *{"$caller\::flash"}        = \&flash;
        *{"$caller\::flash_config"} = \&flash_config;
    }

    return 1;
}

# Retrieve the flash object.  This method also provides a convenient simple
# syntax for setting and getting data from the flash.
sub flash
{
    my $self = shift;
    my $flash;

    # Make sure our data store has been initialized.
    $self->{'Plugin::Flash'} ||= { };

    # Create the flash object singleton.
    if (!defined $self->{'Plugin::Flash'}{'Object'})
    {
        croak "Flash requires session support." unless ($self->can("session"));

        $self->{'Plugin::Flash'}{'Object'} =
            CGI::Session::Flash->new($self->session, $self->flash_config);
    }

    $flash = $self->{'Plugin::Flash'}{'Object'};

    # Set or get the values for a specific key.
    if (@_)
    {
        my $key = shift;

        if (@_)
        {
            $flash->set($key => @_);
        }

        return $flash->get($key);
    }
    # Return the flash object.
    else
    {
        return $flash;
    }
}

sub flash_config
{
    my $self = shift;
    my $config;

    # Make sure our data store has been initialized.
    $self->{'Plugin::Flash'} ||= { };
    
    # Set the values of the configuration.
    if (@_)
    {
        croak "Invalid flash configuration.  Specify a list of name and values." 
            if (@_ % 2 == 1);

        $self->{'Plugin::Flash'}{'Config'} = { @_ };
    }

    # Return the config.
    $config = $self->{'Plugin::Flash'}{'Config'};
    return wantarray ? %$config : $config;
}

1;
__END__

=pod

=head1 NAME

CGI::Application::Plugin::Flash - Flash ...

=head1 SYNOPSIS

    use CGI::Application::Plugin::Flash;

    sub cgiapp_init
    {
        my $self = shift;

        $self->flash_config(
            session_key  => 'FLASH',
            auto_cleanup => 1,
        );

        # ...
    }

    sub some_runmode
    {
        my $self = shift;

        # Set a message in the flash
        $self->flash(info => 'Welcome back!');

        # Alternatively
        my $flash = $self->flash;
        $flash->set(info => "Welcome back!");

        # Set a message in the flash that only lasts for the duration of
        # the current request.
        $self->flash->now(test => 'Only available for this request');

        # ...
    }

=head1 DESCRIPTION

This L<CGI::Application> plugin implements a Flash object.  A flash is session
data with a specified life cycle.  When you put something into the flash it
stays then until the end of the next request.  This allows you to use it for
storing messages that can be accessed after a redirect, but then are
automatically cleaned up.

Since the flash data is accessible from the next request a method of persistance
is required.  We use a session for this so the
L<CGI::Application::Plugin::Session> is required.  The flash is stored in the
session using two keys, one for the data and one for the list of keys that are
to be kept. 

=head1 EXPORTED METHODS

The following methods are exported into your L<CGI::Application> base class and
can be used from within your runmodes.

=head2 flash

The flash is implemented as a singleton so the same object will be returned on
subsequent calls.  The first time this is called a new flash object is created
using data from the session.

This method can be called in the following manners:

=over 4

=item $self->flash()

When no arguments are specified the flash object is returned. 
Use this form when you want to use a more advanced feature of the flash.  See
the documentation below for the flash object.

=item $self->flash('KEY')

Retrieve the data from the flash.  See C<get> for more details.

=item $self->flash('KEY' => @data)

Set the data in the flash.  See C<set> for more details.

=back

=head2 flash_config

Call this method to set or get the configuration for the flash.  Setting the
configuration must be done before the first time you call C<flash>, otherwise
the configuration will not take effect.  A good place to put this call is in
your C<cgiapp_init> method.

When setting the configuration values specify a list of key and value pairs.
The possible values are documented in the L<CGI::Session::Flash/new>
documentation.

When called with no parameters, the current configuration will be returned as
either a hashref or a list depending on the context.

=head1 USING FROM A TEMPLATE

This is an example of how you could use the flash in a template to display
some various informational notices.

    [% FOR type IN [ 'error', 'warning', 'info' ] -%]
      [% IF c.flash.has_key(type) -%]
      <div class="flash [% type %]">,
        <strong>[% type %] messages</strong>
        <ul>
        [% FOREACH message in c.flash(type) -%]
          <li>[% message | h %]</li>
        [% END -%]
        </ul>
      </div>
      [% END -%]
    [% END -%]

A simpler example is:

    [% c.flash('key') %]

=head1 FLASH OBJECT

While the basic use of the flash is getting and setting data, which we provide
simple wrapper for, there may be times when you need to access the full power
of the flash object.

Consult the L<CGI::Session::Flash> documentation for details on its usage.

=head1 BUGS

Please report any bugs or feature requests to C<bug-cgi-application-plugin-flash at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CGI-Application-Plugin-Flash>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

The concept and name of this plugin was inspired by the Ruby on Rails
framework.

=head1 SEE ALSO

L<CGI::Application>, L<CGI::Application::Plugin::Session>, L<CGI::Session::Flash>

=head1 AUTHOR

Bradley C Bailey, C<< <cap-flash at brad.memoryleak.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Bradley C Bailey, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
