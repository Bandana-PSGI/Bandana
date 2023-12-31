#!/usr/bin/perl -w

use strict;
use warnings;

use lib 'lib';

use Getopt::Long;
use Data::Dumper;
use Pod::Usage;

use Bandana::Arbiter;

my $opts = {
    host    => 'localhost',
    port    => 8000,
    workers => 1,
};

GetOptions(
    $opts,
    'host|h=s',
    'port|p=i',
    'workers|w=i',
);

my $app = shift @ARGV;

pod2usage( 1 ) unless $app;

sub main {
    my ( $opts, $app ) = @_;

    my $arbiter = Bandana::Arbiter->new( $opts, $app );

    $arbiter->run;
}

main( $opts, $app );

__END__

=head1 NAME

bandana - run PSGI application

=head1 SYNOPSIS

    To run PSGI application use:

        perl bandana.pl [options] application-name

    C<bandana.pl> runs PSGI application

    Options:
        --host|h    - Host to listen on. Default is `localhost`
        --port|p    - Port to listen on. Default is `8000`
        --workers|w - Number of workers to spawn. Default is `1`
    
    application-name must be a script with .psgi extension

    Examples:
        perl bandana.pl -h localhost -p 8000 -w 1 app.psgi

=head1 DESCRIPTION

C<bandana.pl> runs any valid PSGI applications

=head1 AUTHORS

backslash001 <telegin.vlad132@gmail.com>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
