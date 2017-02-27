###############################################################################################
##
## Tests for Tarp::Utils::Format::Builder::Import Factory
##
###############################################################################################

use Test::More;# tests => 24;
use Test::Deep;
use Try::Tiny;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::Tarp;

my ( $toDB, $fail, $failmesg, @data, $account );

BEGIN { use_ok 'Tarp::Utils::Format::Builder::Import'; }

my $test = Test::Tarp->new( SQL => "$FindBin::Bin/../../_SQL" );

ok my $toDB = Tarp::Utils::Format::Builder::Import->new( schema => $test->schema, format => 'accounts' ), 'create Import';


################################################################################################
##
## Test public method ->load()
##
##

## test failure for load called without arg
try { $fail = 1 ; $failmesg = ''; $toDB->load; $fail = 0; } catch { $failmesg = $_; };
ok $fail, '->load()';
like $failmesg, qr/load must be called with a hashref argument/, '->load die message';

## test failure for load called with bad arg
try { $fail = 1 ; $failmesg = ''; $toDB->load('string'); $fail = 0; } catch { $failmesg = $_; };
ok $fail, '->load(string)';
like $failmesg, qr/load must be called with a hashref argument/, '->load die message';

## test successful load
ok $toDB->load( ($test->accounts_data)[0] ), '->load(' . ($test->accounts_data)[0]->{account_id} . ')';
is scalar(keys %{ $toDB->data }), 1, '->data has 1 entry';
ok( $toDB->load( $_ ), '->load(' . $_->{account_id} . ')' )  foreach ( ($test->accounts_data)[1..3] );
is scalar(keys %{ $toDB->data }), 4, '->data has 4 entries';

##
##
## Test private method ->_in_dataset() ###################
##
##

$account = $toDB->util->new( %{ ($test->accounts_data)[0] } );
isnt $toDB->_in_dataset($account), undef, '_in_dataset format for first entry is as expected';
$account = $toDB->util->new( %{ ($test->accounts_data)[3] } );
isnt $toDB->_in_dataset($account), undef, '_in_dataset format for last entry is as expected';
$account = $toDB->util->new( account_id => 999, name => 'NO THERE', status => 'active' );
is $toDB->_in_dataset($account), undef, '_in_dataset return not found as expected';


################################################################################################
##
## Test public method ->commit()
##
##

## Test expected setup
$toDB = Tarp::Utils::Format::Builder::Import->new( schema => $test->schema, format => 'accounts' );
cmp_deeply( $toDB->data, {}, ' ->data is clear ' );
try { $fail = 1; $failmesg = ''; $toDB->commit; $fail = 0;  } catch { $failmesg = $_; };
ok !$fail, '->commit nothing to commit works';
diag( $failmesg ) if ( $failmesg );
cmp_deeply( $toDB->data, {}, ' ->data is clear ' );

## Test successful load
$toDB->load( $_ ) foreach ( $test->accounts_data );
try { $fail = 1; $failmesg = ''; $toDB->commit; $fail = 0;  } catch { $failmesg = $_; };
ok !$fail, '->commit 4 entries';
diag( $failmesg ) if ( $failmesg );


## Test expected setup
cmp_deeply( $toDB->data, {}, ' ->data is clear ' );
is $test->schema->resultset('Accounts')->count, 4, 'local db has 4 accounts';
is $test->schema->resultset('Accounts')->search( { is_dirty => 'C' } )->count, 4, 'local db has 4 is_dirty = "C"';

##
##
## Test private methods ->_update_row_if_changed() ######################
##
##

map { $toDB->load($_) } $test->accounts_data;

## Test expected current state
$account = $toDB->rs->search( { account_id => 4 } )->first;
is $account->is_dirty, 'C', 'db data for account_id = 4 is_dirty C is expected';

## Test With update
my $oldaccount = $account->format;
$account->name('Updated'); $account->update; ## Do not do in production!!!!!!
$account = $toDB->rs->search( { account_id => 4 } )->first;
##                            key, $olddata
$toDB->_update_row_if_changed( $oldaccount, $account );
$account = $toDB->rs->search( { account_id => 4 } )->first;
is $account->is_dirty, 'U', 'db data for account_id = 4 is_dirty U is expected';
is $account->name, $toDB->data->{4}->name, 'db data matches in ->data';

## Test No update
$account->is_dirty(''); $account->update;
$account = $toDB->rs->search( { account_id => 4 } )->first;
$toDB->_update_row_if_changed( $account->format, $account );
is $account->is_dirty, '', 'db data for account_id = 4 is_dirty "" is expected no update';

##
##
## Test private method ->_delete_row() ######################
##
##

## Test expected current state
$account = $toDB->rs->search( { account_id => 4 } )->first;
ok $account, 'account_id 4 found in db';
ok $account->is_dirty ne 'D', 'db account_id 4 is_dirty != "D"';

## Test delete
$toDB->_delete_row( $account );
$account = $toDB->rs->search( { account_id => 4 } )->first;
ok $account, 'account_id 4 found in db';
is $account->is_dirty, 'D', 'db account_id 4 is_dirty = "D"';

##
##
## Test private method ->_create_row() ######################
##
##

## Test expected current state
$account = $toDB->rs->search( { account_id => 5 } )->first;
ok !$account, 'account_id 5 not found in db';

## Test create
$account = $toDB->util->new( %{ ($test->accounts_data)[3] }, brandnew => 'DATA' ); ## with extra sauce
$account->account_id( 5 );
$account->name('BRAND NEW');
$toDB->_create_row( $account );
$account = $toDB->rs->search( { account_id => 5 } )->first;
ok $account, 'account_id 5 found in db';
is $account->name, 'BRAND NEW', 'db account_id 5 name is "BRAND NEW"';
is $account->is_dirty, 'C', 'db account_id 5 is_dirty = "C"';

done_testing();
