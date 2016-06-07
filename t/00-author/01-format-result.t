###############################################################################################
##
## Author Tests for Tarp::Utils::Format::* Tarp::Schema::Result::* sync
##
###############################################################################################

use Test::More;# tests => 24;
use Test::Deep;
use Try::Tiny;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::Tarp;

my ( $test, @Builder );

my @Builder = qw/Accounts Courses Enrollments Sections Terms Users Xlists/;

BEGIN {
    ## Skip 
    plan skip_all => 'set TARP_AUTHOR to run tests' unless ( exists $ENV{TARP_AUTHOR} );

    ## Formats
    for my $builder ( @Builder ) {
        use_ok 'Tarp::Utils::Format::'  . $builder;
        use_ok 'Tarp::Schema::Result::' . $builder;
    }
}

$test = Test::Tarp->new( SQL => "$FindBin::Bin/../../_SQL" );

BAIL_OUT( 'Can not create/connect Test Database' ) unless ( $test );

##
##
##
## Test for exactly All attributes in Tarp::Utils::Format:: are accessors for Tarp::Schema::Result::
##
##

subtest 'Attribute Format::X in Accessor Schema::X' => sub {
    for my $builder ( @Builder ) {
       my %result_columns;
       for my $col ( $test->schema->resultset( $builder )->result_source->columns ) {
           my $info = $test->schema->resultset( $builder )->result_source->column_info($col);
           if ( exists $info->{accessor} ) {
               $result_columns{ $info->{accessor} } = 1;
           }
           else {
               $result_columns{ $col } = 1;
           }
       }
       for my $attr ( sort map { $_->name } "Tarp::Utils::Format::$builder"->meta->get_all_attributes ) {
           ok exists $result_columns{ $attr }, "Tarp::Utils::Format::$builder\->$attr Tarp::Schema::Result::$builder\->$attr";
       }
    }
};


##
done_testing();






