package Tarp;

use Moose;
use namespace::autoclean;
use JSON;
use Path::Tiny;
use DateTime;
use DateTime::Format::ISO8601;
use IO::String;

use CanvasCloud;
use Tarp::Schema;
use Tarp::Import;
use Tarp::Export;


#Public
has configfile => ( is => 'ro', required => 1 );
has schema => ( is => 'ro', writer => '_schema' );
has debug => ( is => 'rw', default => 0 );

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
    print STDERR __PACKAGE__, "->push_changes\n" if ( $self->debug );
    my $import = shift || Tarp::Import->new( debug => $self->debug, schema => $self->schema, map { $_ => $_.'.csv' } qw/Accounts Terms Courses Users Sections Enrollments/ );
    ## check for Tarp::Import Object for safty dance
    die 'push_changes( "Tarp::Import" ) need Tarp::Import object!' unless ( ref( $import ) eq 'Tarp::Import' );

    my ( $export, $zips, @returns );

    $export = Tarp::Export->new( debug => $self->debug, schema => $self->schema );

    for my $change_type ( qw/updates deletes creates/ ) {
        $import->$change_type;
        push @returns, $self->send_zips( $export->$change_type, 'push_changes:'.$change_type );
    }
    return @returns;
}

sub push_all {
    my $self   = shift;
    print STDERR __PACKAGE__, "->push_all\n" if ( $self->debug );
    my $export = Tarp::Export->new( schema => $self->schema );
    return $self->send_zips( $export->all, 'push_all' );
}

sub send_zips {
    my ( $self, $zips, $type ) = @_;
    my @returns;
    if ( ref($zips) eq 'ARRAY' && @$zips ) {
        for my $zip ( @$zips ) {
            print STDERR __PACKAGE__, "->send_zips($zip->{string}, $type)" if ( $self->debug );
            my $response = $self->CanvasCloud->api('sisimports', scheme => $self->config->{CanvasCloud}{scheme})->sendzip( $zip );
            my $id = $response->{id} || die 'sisimports response is unexpected!!! '. to_json($response) . ' !!!';
            my $keep_going = 1;
            while ( $keep_going ) {
                sleep 5;
                $response = $self->CanvasCloud->api('sisimports', scheme => $self->config->{CanvasCloud}{scheme})->status( $id );
                $keep_going = 0 if (
                                        (!exists $response->{workflow_state})
                                     || ( exists $response->{progress} && $response->{progress} == 100 )
                                     || (  $response->{workflow_state} =~ m/^(imported|failed).*/ )
                                   );
            }
            print STDERR "->done\n" if ( $self->debug );
            push @returns, $response;
            $self->schema->resultset('HistoryLog')->create({
                                                                domainspace        => 'Tarp::send_zips',
                                                                nametag            => $type,
                                                                jsondata           => $response,
                                                          });
            if ( $response->{workflow_state} =~ m/^failed/ ) {
                my $dt = DateTime->now;
                my $file = '/tmp/canvas-' . $dt->ymd('_') . 'T' . $dt->hms('_') . "-$zip->{string}.zip";
                $zip->{zip}->writeToFileNamed($file);
                warn "FAILURE FOUND: ($file)\n", to_json($response, {pretty=>1});
            }
        }
    }
    return @returns;
}

__PACKAGE__->meta->make_immutable;

1;
