my $app = sub {
    my ( $env ) = @_;

    return [
        '200',
	    [
            'Content-Type'   => 'text/plain',
            'Content-Length' => 2,
        ],
	    [ 'Hello World' ],
    ];
};