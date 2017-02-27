###############################################################################################
##
## Tests for Tarp::Utils::Format::Builder::Export Factory
##
###############################################################################################

use Test::More;# tests => 24;
use Test::Deep;
use Try::Tiny;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::Tarp;
use Archive::Zip;

my ( $toCloud, $fail, $failmesg, @data, $account );

BEGIN { use_ok 'Tarp::Utils::Format::Builder::Export'; }
BEGIN { use_ok 'Tarp::Utils::Format::Builder::Import'; }

my $test = Test::Tarp->new( SQL => "$FindBin::Bin/../../_SQL" );



my $toDB = Tarp::Utils::Format::Builder::Import->new(
                                                            schema => $test->schema,
                                                            format => 'accounts',
                                                            ignore_updates => 1,
                                                            ignore_deletes => 1
                                                            ),
                                                            'create Import';
my $zip = Archive::Zip->new;

ok my $toCloud = Tarp::Utils::Format::Builder::Export->new(
                                                                schema => $test->schema,
                                                                format => 'accounts',
                                                                ignore_updates => 1,
                                                                ignore_deletes => 1
                                                            ),
                                                            'create Export';


################################################################################################
##
## Test public method ->gather()
##
##

ok $toCloud->gather, '->gather()';
is scalar(keys %{ $toCloud->data }), 0, '->data has 0 entry';

## test gather($zip)
map { $toDB->load($_) } $test->accounts_data;
$toDB->commit;

ok $toCloud->gather($zip), '->gather() return zip member';
is scalar(keys %{ $toCloud->data }), 1, '->data has 1 entry';
ok exists $toCloud->data->{create}, '->data->{create} is there';
isa_ok $toCloud->data->{create}, 'Archive::Zip::Member', '->data->{create} isa Archive::Zip::Member';

ok $toCloud->gather, '->gather()';
is scalar(keys %{ $toCloud->data }), 0, '->data has 0 entry';

## test gather();
$toCloud->rs->update({ is_dirty => 'C' });

ok $toCloud->gather, '->gather()';
is scalar(keys %{ $toCloud->data }), 1, '->data has 1 entry';

ok exists $toCloud->data->{create}, '->data->{create} is there';
ok exists $toCloud->data->{create}{'accounts.csv'}, 'accounts.csv is create value';
like $toCloud->data->{create}{'accounts.csv'}, qr/^account_id,parent_account_id,name,status/m, 'accounts.csv has header';

ok $toCloud->gather, '->gather()';
is scalar(keys %{ $toCloud->data }), 0, '->data has 0 entry';

done_testing();
