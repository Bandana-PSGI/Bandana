#!/usr/bin/env perl

use strict;
use warnings;

use Socket qw/ AF_INET SOCK_STREAM pack_sockaddr_in inet_aton /;

use Data::Dumper;

use lib 'lib';

use Server::WSGI;

sub view {
    my ( $environ ) = @_;

    return "<h1>Hello from $environ->{PATH_INFO}</h1>";
}

sub application {
    my ( $start_response, $environ ) = @_;

    my $response = $start_response->( '200 OK', { 'Content-Type' => 'text/html' } );

    $response .= view( $environ );

    return [$response];
}

my $server = Server::WSGI->new( $ARGV[0] );

$server->{application} = \&application;

$server->run();

$server->close_connection();
