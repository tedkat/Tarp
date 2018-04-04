#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin.'/../lib';

use Tarp;

my $tarp = Tarp->new( debug => 1, configfile => $FindBin::Bin . '/../config.json' );

$tarp->push_all;

exit 0;
