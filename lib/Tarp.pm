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

sub reconcile {
    my $self = shift;
    my $type = shift || '';

    my $csv = Text::CSV->new;

    print STDERR __PACKAGE__, "->reconcile($type)\n" if ( $self->debug );
    
    # GET Canvas Terms
    my %term_map;
    for my $t ( @{ $self->CanvasCloud->api('terms', scheme => $self->config->{CanvasCloud}{scheme})->list->{enrollment_terms} } ) {
        if ( exists $t->{sis_term_id} && defined $t->{sis_term_id} ) {
            $term_map{ $t->{sis_term_id} } = $t;
        }
    }
    
    # Get Current Tarp Terms which are mapped
    my @tarp_terms;
    for my $t ( $self->schema->resultset('Terms')->all ) {
        if ( my $end_dt = DateTime::Format::ISO8601->parse_datetime( $t->end_date ) ) {
            if ( my $start_dt = DateTime::Format::ISO8601->parse_datetime( $t->start_date ) ) {
                if ( DateTime->now <= $end_dt && DateTime->now >= $start_dt && exists $term_map{ $t->term_id } ) {
                    push @tarp_terms, $t->term_id;
                }
            }
        }
    }

    my %Return = ( DIFF => [], NotInTarp => [], NotInDownload => [] );

    for my $tid ( @tarp_terms ) {
        print STDERR __PACKAGE__, "->reconcile: Term->", $term_map{$tid}{name}, "\n" if ( $self->debug );
        my $can_report = $self->CanvasCloud->api('reports', scheme => $self->config->{CanvasCloud}{scheme});
        my $can_result = $can_report->run( 'sis_export_csv', { 'parameters[enrollment_term_id]' => $term_map{$tid}{id}, 'parameters[enrollments]' => 1 } );
        #warn to_json( $can_result, {pretty=>1});
        while ( $can_result->{status} eq 'running' ) {
            sleep 10; 
            $can_result = $can_report->check( 'sis_export_csv', $can_result->{id} );
        }
        if ( exists $can_result->{attachment} && exists $can_result->{attachment}{url} ) {
            my $resp = $can_report->ua->get( $can_result->{attachment}{url} ); ## Download report without using class specific headers
            die $resp->status_line unless ( $resp->is_success );
            my $text = $resp->decoded_content( charset => 'none' );
            my %sections;
            my $io = IO::String->new($text);
            my $csv = Text::CSV->new;
            $csv->column_names( $csv->getline( $io ) );
            while ( my $row = $csv->getline_hr($io) ) {
                if ( $row->{user_id} ne '' && ( $row->{role} eq 'student' || $row->{role} eq 'teacher' ) ) {
                   $sections{ $row->{section_id} }{ $row->{user_id} } = $row;
                }
            }
            for my $s ( keys %sections ) {
                for my $e ( $self->schema->resultset('Enrollments')->search_rs( { section_id => $s } )->all ) {
                    if ( exists $sections{$s}{$e->user_id} ) {
                        if ( $e->status ne $sections{$s}{$e->user_id}{status} ) {
                            push @{ $Return{DIFF} }, $e->to_pruned_hash;
                            print STDERR "X" if ( $self->debug ); ## DIFF
                        }
                    }
                    else {
                        if ( $e->status eq 'active' ) { #ignore deleted status if not in download
                             push @{ $Return{NotInDownload} }, $e->to_pruned_hash;
                             print STDERR 'T' if ( $self->debug ); ## NotInDowload
                        }
                    }
                    delete $sections{$s}{$e->user_id};
                }
                for my $e ( keys %{ $sections{$s} } ) {
                    if ( $sections{$s}{$e}{status} eq 'active' ) {
                        $sections{$s}{$e}{status} = 'deleted';
                        push @{ $Return{NotInTarp} }, $sections{$s}{$e};
                        print STDERR 'D'if ( $self->debug ); ## NotInTarp
                    }
                }
            }
        }
        else {
             print STDERR __PACKAGE__, "->reconcile: download attachment url not presseent in response\n" if ( $self->debug );
             next;
        }
        print STDERR "\n" if ( $self->debug );
    }
    return \%Return;
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
