package Bandana::Server;

use strict;
use warnings;

use Socket qw/
    AF_INET
    SOCK_STREAM
    TCP_CORK
    SOL_SOCKET
    SO_RCVBUF
    SO_REUSEADDR
    pack_sockaddr_in
    inet_aton
/;
use HTTP::Request;
use List::Util qw/ sum /;

use constant {
    TRUE  => 1,
    FALSE => 0,
};

sub new {
    my ( $class, $host, $port ) = @_;

    my $self = {
        host => $host,
        port => $port,
    };

    socket( $self->{server_socket}, AF_INET, SOCK_STREAM, 0 ) or die "Socket: $!";

    setsockopt( $self->{server_socket}, SOL_SOCKET, SO_REUSEADDR, 1 );

    bind( $self->{server_socket}, pack_sockaddr_in( $self->{port}, inet_aton( $self->{host} ) ) ) or die "Bind: $!";

    listen( $self->{server_socket}, 2048 ) or die "Listen: $!";

    return bless $self, $class;
}

sub run {
    my ( $self, $app ) = @_;

    print( "Running server on $self->{host} : $self->{port} \n" );

    while ( TRUE ) {
        accept( my $conn, $self->{server_socket} ) or die "Accept: $!";

        my $chunk_size = sum( unpack( "C*", $conn ) );

        recv( $conn, my $request, $chunk_size, 0 );

        $request = $self->parse_http( $request );

        my $environ = $self->to_environ( $request );

        my $response = &{ $app }( $environ );

        my $status = shift @$response;
        $status    = "HTTP/1.1 $status OK\r\n";

        print "\n$status\n";

        send( $conn, $status, 0 );

        my %headers = @{ shift @$response };

        while ( my ( $key, $value ) = each %headers ) {
            print "$key: $value\n";
            send( $conn, "$key: $value\r\n", 0 );
        }

        send( $conn, "\r\n", 0 );

        print "\n";

        my $body = shift @$response;

        for my $element ( @$body ) {
            print "$element\n";
            send( $conn, $element, 0 );
        }

        close( $conn );
    }
}

sub to_environ {
    my ( $self, $request ) = @_;

    return {
        REQUEST_METHOD => $request->method,
        PATH_INFO      => $request->uri,
        SERVER_POTOCOL => $request->protocol,
        'wsgi.input'   => $request->content,
    };
}

sub parse_http {
    my ( $self, $http ) = @_;

    my $request = HTTP::Request->parse( $http );

    return $request;
}

sub close_connection {
    my ( $self ) = @_;

    close( $self->{server_socket} );
}

1;
