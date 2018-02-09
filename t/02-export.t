use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Tarp;
use Path::Tiny;
use JSON;

use Tarp::Import;

my $SQL = "$FindBin::Bin/../_SQL";

my @ResultSets = qw/Accounts Terms Courses Users Sections Enrollments/;

use_ok( 'Tarp::Export' );

## Test CODE data loading ########################

my $testtarp = Test::Tarp->new( SQL => $SQL );  ## New DB

my $import = Tarp::Import->new(
        Accounts    => sub { $testtarp->accounts_data },
        Terms       => sub { $testtarp->terms_data },
        Courses     => sub { $testtarp->courses_data },
        Users       => sub { $testtarp->users_data },
        Sections    => sub { $testtarp->sections_data },
        Enrollments => sub { $testtarp->enrollments_data },
        schema      => $testtarp->schema
);

$import->creates;

subtest 'db sanity check' => sub {
    is $testtarp->schema->resultset('Accounts')->count, scalar( @{ $testtarp->accounts_data } ), 'Accounts Count';
    is $testtarp->schema->resultset('Terms')->count, scalar( @{ $testtarp->terms_data } ), 'Terms Count';
    is $testtarp->schema->resultset('Courses')->count, scalar( @{ $testtarp->courses_data } ), 'Courses Count';
    is $testtarp->schema->resultset('Users')->count, scalar( @{ $testtarp->users_data } ), 'Users Count';
    is $testtarp->schema->resultset('Sections')->count, scalar( @{ $testtarp->sections_data } ), 'Sections Count';
    is $testtarp->schema->resultset('Enrollments')->count, scalar( @{ $testtarp->enrollments_data } ), 'Enrollments Count';
};

subtest 'export' => sub {
    my $export = Tarp::Export->new( schema => $testtarp->schema );
    subtest 'creates' => sub {
        ok my $zips = $export->creates, 'export creates';
        is scalar(@$zips), 3, 'good count returned';
        for my $z ( @$zips ) {
            is ref($z->{zip}), 'Archive::Zip::Archive', 'zip returned';
            like $z->{string}, qr/^.+$/, sprintf( '"%s" string returned', $z->{string} );
            my @string_members = split /_/, $z->{string};
            is scalar( $z->{zip}->members ), scalar(@string_members), 'zip->members count is expected';
        }
        is($testtarp->schema->resultset($_)->search_rs({is_dirty => 'C'})->count, 0, $_ . ' C count') foreach( @ResultSets ); 
    };

    $testtarp->schema->resultset($_)->update({is_dirty => 'U'}) foreach(@ResultSets); 

    subtest 'updates' => sub {
        ok my $zips = $export->updates, 'export updates';
        is scalar(@$zips), 1, 'good count returned';
        for my $z ( @$zips ) {
            is ref($z->{zip}), 'Archive::Zip::Archive', 'zip returned';
            like  $z->{string}, qr/^.+$/, sprintf( '"%s" string returned', $z->{string} );
            my @string_members = split /_/, $z->{string};
            is scalar( $z->{zip}->members ), scalar(@string_members), 'zip->members count is expected';
        }
        is($testtarp->schema->resultset($_)->search_rs({is_dirty => 'U'})->count, 0, $_ . ' U count') foreach( @ResultSets );
    };

    $testtarp->schema->resultset($_)->update({is_dirty => 'D'}) foreach(@ResultSets);

    subtest 'deletes' => sub {
        ok my $zips = $export->deletes, 'export deletes';
        is scalar(@$zips), 3, 'good count returned';
        for my $z ( @$zips ) {
            is ref($z->{zip}), 'Archive::Zip::Archive', 'zip returned';
            like  $z->{string}, qr/^.+$/, sprintf( '"%s" string returned', $z->{string} );
            my @string_members = split /_/, $z->{string};
            is scalar( $z->{zip}->members ), scalar(@string_members), 'zip->members count is expected';
        }
        is($testtarp->schema->resultset($_)->search_rs({is_dirty => 'D'})->count, 0, $_ . ' D count') foreach( @ResultSets );
        is($testtarp->schema->resultset($_)->count, 0, $_ . ' Deleted') foreach( @ResultSets );
    };    
};

done_testing();

