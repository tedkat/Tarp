###############################################################################################
##
## Author Tests ###############################################################################

use Test::More;

BEGIN {
    ## Skip
    plan skip_all => 'set AUTHOR_TESTING to run tests' unless ( exists $ENV{AUTHOR_TESTING} );

    use_ok 'Tarp::Format';
    ## Formats
    for my $builder ( qw/Accounts Courses Enrollments Sections Terms Users Xlists/ ) {
        use_ok 'Tarp::Format::File::'   . $builder;
        use_ok 'Tarp::Format::Record::' . $builder;
        use_ok 'Tarp::Schema::Result::' . $builder;
        use_ok 'Tarp::Schema::Result::' . "tmp$builder";
        use_ok 'Tarp::Schema::ResultSet::' . $builder;
        use_ok 'Tarp::Schema::ResultSet::' . "tmp$builder";
    }
}

done_testing();
