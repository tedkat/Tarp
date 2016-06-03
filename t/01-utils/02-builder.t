###############################################################################################
##
## Tests for Tarp::Utils::Builder Factory
##
###############################################################################################

use Test::More tests => 17;
use Test::Deep;
use Try::Tiny;
use Tarp::Schema;

BEGIN { use_ok 'Tarp::Utils::Builder'; }

my $schema = Tarp::Schema->connect( 'dbi:SQLite:dbname=:memory:' );

my ( $fail, $failmesg, $obj );

ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'users' ), 'expected users format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'accounts' ), 'expected accounts format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'terms' ), 'expected terms format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'courses' ), 'expected courses format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'sections' ), 'expected sections format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'enrollments' ), 'expected enrollments format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'groups' ), 'expected groups format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'groups_membership' ), 'expected groups_memebership format';
ok $obj = Tarp::Utils::Builder->new( schema => $schema, format => 'xlists' ), 'expected xlists format';

try { $fail = 1; $failmesg = ''; Tarp::Utils::Builder->new( schema => $schema, format => 'nosuchformat' ); $fail = 0; } catch { $failmesg = $_; };
ok $fail, "expected fail no such format";
like $failmesg, qr/^Invalid data format \(nosuchformat\)/, 'expected fail message';


$obj = Tarp::Utils::Builder->new( schema => $schema, format => 'accounts' );

is ref( $obj->data ), 'ARRAY', '->data';

cmp_deeply( $obj->data, [], '->data is empty ARRAYREF' );

ok $obj->schema->isa( 'DBIx::Class' ), '->schema isa DBIx::Class';

is $obj->util, 'Tarp::Utils::Format::Accounts', '->util';

is $obj->dbic, 'Accounts', '->dbic';
