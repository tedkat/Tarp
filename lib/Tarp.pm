package Tarp;

use Moose;
use namespace::autoclean;
use JSON;
use Path::Tiny;

use CanvasCloud;
use Tarp::Schema;
use Tarp::Import;
use Tarp::Export;


#Public
has configfile => ( is => 'ro', required => 1 );
has schema => ( is => 'ro', writer => '_schema' );

#Private
has config => ( is => 'ro', writer => '_config', init_arg => undef );
has CanvasCloud => ( is => 'ro', builder => '_CanvasCloud', init_arg => undef, lazy => 1 );

sub _CanvasCloud {
    my $self = shift;
    return CanvasCloud->new( config => $self->config->{CanvasCloud} );
}

sub BUILD {
    my $self = shift;
    $self->_config( decode_json( path( $self->configfile )->slurp_utf8 ) );
    $self->_schema( Tarp::Schema->connect( $self->config->{database} ) ) unless ( $self->schema );
}

sub push_changes {
    my $self = shift;
    my $import = shift || Tarp::Import->new( schema => $self->schema, map { $_ => $_.'.csv' } qw/Accounts Terms Courses Users Sections Enrollments/ );
    ## check for Tarp::Import Object for safty dance
    die 'push_changes( "Tarp::Import" ) need Tarp::Import object!' unless ( ref( $import ) eq 'Tarp::Import' );

    my ( $export, $zips );

    $export = Tarp::Export->new( schema => $self->schema );

    for my $change_type ( qw/updates deletes creates/ ) {
        $import->$change_type;
        $zips = $export->$change_type;

        if ( ref($zips) eq 'ARRAY' && @$zips ) {
            for my $zip ( @$zips ) {
                my $response = $self->CanvasCloud->api('sisimports', scheme => $self->config->{CanvasCloud}{scheme})->sendzip( $zip );
                my $id = $response->{id} || die 'sisimports response is unexpected!!! '. to_json($response) . ' !!!';
                my $keep_going = 1;
                while ( $keep_going ) {
                    sleep 5;
                    $response = $self->CanvasCloud->api('sisimports', scheme => $self->config->{CanvasCloud}{scheme})->status( $id );
                    $keep_going = 0 if ( (!exists $response->{workflow_state}) || $response->{workflow_state} ne 'importing' );
                }
                ## TODO: emit finished responses for further processing
            }
        }
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;