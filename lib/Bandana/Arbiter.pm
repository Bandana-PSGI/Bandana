package Bandana::Arbiter;

use strict;
use warnings;

use File::Spec;
use Socket;
use Data::Dumper;

use Bandana::Server;

sub new {
    my ( $class, $opts, $app ) = @_;

    my $self = {
        host    => $opts->{host},
        port    => $opts->{port},
        workers => $opts->{workers},
    };

    bless $self, $class;

    $self->{app} = $self->get_app( $app );

    return $self;
}

sub get_app {
    my ( $self, $app ) = @_;

    if ( ref $app ) {
        if ( ref $app eq 'CODE' ) {
            return $app;
        }
        elsif ( eval { $app->can( 'to_app' ) } ) {
            return $app->to_app;
        }
        else {
            die 'Failed to get PSGI application from object or ref ' . ref $app; 
        }
    }
    elsif ( !defined $app or $app eq '' ) {
        $app = 'app.psgi';
    }

    if ( -f $app ) {
        return $self->load_psgi( $app );
    }

    die 'Failed to get PSGI application';
}

sub load_psgi {
    my ( $self, $psgi_app ) = @_;

    my $file = $psgi_app =~ /^[a-zA-Z0-9\_\:]+$/ ? $self->class_to_file( $psgi_app ) : File::Spec->rel2abs( $psgi_app );
    my $app  = $self->_load( $file );

    die "Error while loading $file: $@" if $@;

    return $app;
}

sub class_to_file {
    my ( $self, $class ) = @_;

    $class =~ s/\:\:/\//g;

    return $class . '.pm';
}

sub _load {
    my ( $self, $_file ) = @_;

    my $_package = $_file;

    $_package =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;

    local $0    = $_file;
    local @ARGV = ();

    return eval sprintf <<'END_EVAL', $_package;
package Bandana::Arbitor::%s;
{
    my $app = do $_file;

    if ( !$app && ( my $error = $@ || $! )) { die $error; }
    return $app;
}
END_EVAL
}

sub run {
    my ( $self ) = @_;

    my $server = Bandana::Server->new(
        $self->{host},
        $self->{port},
    );

    $server->run( $self->{app} );

    $server->close_connection;
}

1;
