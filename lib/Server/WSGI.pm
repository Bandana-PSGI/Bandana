package Server::WSGI;

use strict;
use warnings;
use Socket qw/ AF_INET SOCK_STREAM pack_sockaddr_in inet_aton /;
use HTTP::Request;

use Data::Dumper;

use constant {
    TRUE  => 1,
    FALSE => 0,
};

sub new {
    my ( $class, $port, $host ) = @_;

    my $self = {
        host => $host || 'localhost',
        port => $port || 8001,
    };

    socket( $self->{server_socket}, AF_INET, SOCK_STREAM, 0 ) or die "Socket: $!";

    bind( $self->{server_socket}, pack_sockaddr_in( $self->{port}, inet_aton( $self->{host} ) ) ) or die "Bind: $!";

    listen( $self->{server_socket}, 1 );

    return bless $self, $class;
}

sub run {
    my ( $self ) = @_;

    print( "Running server on $self->{host} : $self->{port} \n" );

    while ( TRUE ) {
        accept( my $conn, $self->{server_socket} ) or die "Accept: $!";

        my $request = '';

        recv( $conn, $request, 1024, 0 );

        $request = $self->parse_http( $request );

        my $environ = $self->to_environ( $request );

        my $response = $self->{application}->( \&Server::WSGI::start_response, $environ );

        for my $data ( @$response ) {
            print $conn $data;
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

sub start_response {
    my ( $status, $headers ) = @_;

    $status = "HTTP/1.1 $status\r\n";

    my $headers_line = '';

    while ( my ( $key, $value ) = each %$headers ) {
        $headers_line .= $key . ': ' . $value . "\r\n";
    }

    return $status . $headers_line . "\r\n";
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
