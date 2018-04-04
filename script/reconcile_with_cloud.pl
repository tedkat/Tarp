#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin.'/../lib';

use Tarp;
use Tarp::Export;

my $DEBUG = 0;

my $tarp = Tarp->new( debug => $DEBUG, configfile => $FindBin::Bin . '/../config.json' );
my $export = Tarp::Export->new( schema => $tarp->schema );

my $RECON = $tarp->reconcile;

for my $state ( qw/NotInTarp NotInDownload DIFF/ ) {
    if ( exists $RECON->{$state} && ref( $RECON->{$state} ) eq 'ARRAY' ) {
        if ( @{ $RECON->{$state} } ) {
            my $zip = $export->raw( 'Enrollments', $RECON->{$state} );
            if ( $zip->members ) {
                $zip->writeToFileNamed("$state.zip") if ( $DEBUG );
                $tarp->send_zips( [ { zip => $zip, string => $state } ], 'reconcile' );
            }
        }
    }
    else {
        die "->reconcile state:$state ( returned unexpected Results )!\n";
    }
}

exit 0;
