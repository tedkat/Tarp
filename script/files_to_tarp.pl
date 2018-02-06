use FindBin;
use Tarp;

my $tarp = Tarp->new( configfile => $FindBin::Bin . '/../config.json' );

$tarp->push_changes;

exit 0;
