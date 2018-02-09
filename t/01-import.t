use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Tarp;
use Path::Tiny;
use JSON;

my $SQL = "$FindBin::Bin/../_SQL";

my @ResultSets = qw/Accounts Terms Courses Users Sections Enrollments/;

use_ok( 'Tarp::Import' );

## Test CODE data loading ########################

subtest 'Code Import' => sub {
    my $testtarp = Test::Tarp->new( SQL => $SQL );  ## New DB
    ok my $import = Tarp::Import->new(
        Accounts    => sub { $testtarp->accounts_data },
        Terms       => sub { $testtarp->terms_data },
        Courses     => sub { $testtarp->courses_data },
        Users       => sub { $testtarp->users_data },
        Sections    => sub { $testtarp->sections_data },
        Enrollments => sub { $testtarp->enrollments_data },
        schema      => $testtarp->schema
    ), "Tarp::Import->new( key => sub { return [] } )";
    is $testtarp->schema->resultset('tmpAccounts')->count, scalar( @{ $testtarp->accounts_data } ), 'tmpAccounts Count';
    is $testtarp->schema->resultset('tmpTerms')->count, scalar( @{ $testtarp->terms_data } ), 'tmpTerms Count';
    is $testtarp->schema->resultset('tmpCourses')->count, scalar( @{ $testtarp->courses_data } ), 'tmpCourses Count';
    is $testtarp->schema->resultset('tmpUsers')->count, scalar( @{ $testtarp->users_data } ), 'tmpUsers Count';
    is $testtarp->schema->resultset('tmpSections')->count, scalar( @{ $testtarp->sections_data } ), 'tmpSections Count';
    is $testtarp->schema->resultset('tmpEnrollments')->count, scalar( @{ $testtarp->enrollments_data } ), 'tmpEnrollments Count';
};

## Test FILE data loading ########################
subtest 'File Import' => sub {
    my $testtarp = Test::Tarp->new( SQL => $SQL ); ## New DB
    my $mapped = {
        Accounts    => $testtarp->accounts_data_file,
        Terms       => $testtarp->terms_data_file,
        Courses     => $testtarp->courses_data_file,
        Users       => $testtarp->users_data_file,
        Sections    => $testtarp->sections_data_file,
        Enrollments => $testtarp->enrollments_data_file,
    };
    ## create new args out of $mapped
    @args = map { $_ => ''.$mapped->{$_} } keys %{ $mapped };
    ok my $import = Tarp::Import->new( @args, schema => $testtarp->schema ), 'Tarp::Import->new( key => "file.csv" )';
    is $testtarp->schema->resultset('tmpAccounts')->count, scalar( @{ $testtarp->accounts_data } ), 'tmpAccounts Count';
    is $testtarp->schema->resultset('tmpTerms')->count, scalar( @{ $testtarp->terms_data } ), 'tmpTerms Count';
    is $testtarp->schema->resultset('tmpCourses')->count, scalar( @{ $testtarp->courses_data } ), 'tmpCourses Count';
    is $testtarp->schema->resultset('tmpUsers')->count, scalar( @{ $testtarp->users_data } ), 'tmpUsers Count';
    is $testtarp->schema->resultset('tmpSections')->count, scalar( @{ $testtarp->sections_data } ), 'tmpSections Count';
    is $testtarp->schema->resultset('tmpEnrollments')->count, scalar( @{ $testtarp->enrollments_data } ), 'tmpEnrollments Count';
};




subtest 'Code Import creates updates deletes' => sub {
    my $testtarp = Test::Tarp->new( SQL => $SQL );  ## New DB

    subtest 'creates' => sub {
        ok my $import = Tarp::Import->new(
            Accounts    => sub { $testtarp->accounts_data },
            Terms       => sub { $testtarp->terms_data },
            Courses     => sub { $testtarp->courses_data },
            Users       => sub { $testtarp->users_data },
            Sections    => sub { $testtarp->sections_data },
            Enrollments => sub { $testtarp->enrollments_data },
            schema      => $testtarp->schema
        ), "Tarp::Import->new( key => sub { return [] } )";
        is $import->creates,
            (
                scalar( @{ $testtarp->accounts_data } )
                + scalar( @{ $testtarp->terms_data } )
                + scalar( @{ $testtarp->courses_data } )
                + scalar( @{ $testtarp->users_data } )
                + scalar( @{ $testtarp->sections_data } )
                + scalar( @{ $testtarp->enrollments_data } )
            ),
            "creates total count";
        is $import->deletes, 0, "deletes total count";
        is $import->updates, 0, "updates total count";
    };

    $testtarp->schema->resultset($_)->update( { is_dirty => '' } ) foreach( @ResultSets );

    subtest 'updates' => sub {
        $testtarp->schema->resultset('Accounts')->update( { name => 'XxXx' } );
        $testtarp->schema->resultset('Terms')->update( { name => 'XxXx' } );
        $testtarp->schema->resultset('Courses')->update( { short_name => 'XxXx' } );
        $testtarp->schema->resultset('Users')->update( { status => 'deleted' } );
        $testtarp->schema->resultset('Sections')->update( { name => 'XxXx' } );
        $testtarp->schema->resultset('Enrollments')->update( { status => 'deleted' } );

        ok my $import = Tarp::Import->new(
            Accounts    => sub { $testtarp->accounts_data },
            Terms       => sub { $testtarp->terms_data },
            Courses     => sub { $testtarp->courses_data },
            Users       => sub { $testtarp->users_data },
            Sections    => sub { $testtarp->sections_data },
            Enrollments => sub { $testtarp->enrollments_data },
            schema      => $testtarp->schema
        ), "Tarp::Import->new( key => sub { return [] } )";
        is $import->creates, 0, "creates total count";
        is $import->updates,
            (
                scalar( @{ $testtarp->accounts_data } )
                + scalar( @{ $testtarp->terms_data } )
                + scalar( @{ $testtarp->courses_data } )
                + scalar( @{ $testtarp->users_data } )
                + scalar( @{ $testtarp->sections_data } )
                + scalar( @{ $testtarp->enrollments_data } )
            ),
            "updates total count";
        is $import->deletes, 0, "deletes total count";
    };
    
    $testtarp->schema->resultset($_)->update( { is_dirty => '' } ) foreach( @ResultSets );

    subtest 'deletes' => sub {

        ok my $import = Tarp::Import->new(
            Accounts    => sub { [] },
            Terms       => sub { [] },
            Courses     => sub { [] },
            Users       => sub { [] },
            Sections    => sub { [] },
            Enrollments => sub { [] },
            schema      => $testtarp->schema
        ), "Tarp::Import->new( key => sub { return [] } )";
        is $import->creates, 0, "creates total count";
        is $import->updates, 3, "updates total count"; ## On user delete update deleted user first
        ## Clean up updated deletes
        $testtarp->schema->resultset($_)->update( { is_dirty => '' } ) foreach( @ResultSets );
        ##
        is $import->deletes,
            (
                scalar( @{ $testtarp->accounts_data } )
                + scalar( @{ $testtarp->terms_data } )
                + scalar( @{ $testtarp->courses_data } )
                + scalar( @{ $testtarp->users_data } )
                + scalar( @{ $testtarp->sections_data } )
                + scalar( @{ $testtarp->enrollments_data } )
            ),
            "deletes total count";
    };
};



done_testing();
