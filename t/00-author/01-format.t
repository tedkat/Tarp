###############################################################################################
##
## Tests for Tarp::Format::File::*
##
###############################################################################################

use Test::More;
use Test::Deep;

BEGIN {
    ## Skip
    plan skip_all => 'set AUTHOR_TESTING to run tests' unless ( exists $ENV{AUTHOR_TESTING} );
}

BEGIN { use_ok 'Tarp::Format::File::Accounts'; }
BEGIN { use_ok 'Tarp::Format::File::Courses'; }
BEGIN { use_ok 'Tarp::Format::File::Enrollments'; }
BEGIN { use_ok 'Tarp::Format::File::GroupMembership'; }
BEGIN { use_ok 'Tarp::Format::File::Groups'; }
BEGIN { use_ok 'Tarp::Format::File::Sections'; }
BEGIN { use_ok 'Tarp::Format::File::Terms'; }
BEGIN { use_ok 'Tarp::Format::File::Users'; }
BEGIN { use_ok 'Tarp::Format::File::Xlists'; }


subtest 'Tarp::Format::File::Accounts' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Accounts->new( account_id => 'x', parent_account_id => 'x', name => 'x', status => 'active' ), '::Accounts->new';
    is $obj->file, 'accounts.csv', '::Accounts->file';
    cmp_deeply [ $obj->header], [ qw/account_id parent_account_id name status/ ], '::Accounts->header';
};

subtest 'Tarp::Format::File::Courses' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Courses->new( course_id => 'x', short_name => 'x', long_name => 'x', status => 'active' ), '::Courses->new';
    is $obj->file, 'courses.csv', '::Courses->file';
    cmp_deeply [ $obj->header], [ qw/course_id short_name long_name account_id term_id status start_date end_date/ ], '::Courses->header';
};

subtest 'Tarp::Format::File::Enrollments' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Enrollments->new( course_id => 'x', user_id => 'x', role => 'x', status => 'active' ), '::Enrollments->new';
    is $obj->file, 'enrollments.csv', '::Enrollments->file';
    cmp_deeply [ $obj->header], [ qw/course_id section_id status user_id root_account associated_user_id role role_id/ ], '::Enrollments->header';
};

subtest 'Tarp::Format::File::GroupMembership' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::GroupMembership->new( group_id => 'x', user_id => 'x', status => 'accepted' ), '::GroupMembership->new';
    is $obj->file, 'groups_membership.csv', '::GroupMembership->file';
    cmp_deeply [ $obj->header], [ qw/group_id user_id status/ ], '::GroupMembership->header';
};

subtest 'Tarp::Format::File::Groups' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Groups->new( group_id => 'x', name => 'x', status => 'available' ), '::Groups->new';
    is $obj->file, 'groups.csv', '::Groups->file';
    cmp_deeply [ $obj->header], [ qw/group_id name status account_id/ ], '::Groups->header';
};

subtest 'Tarp::Format::File::Sections' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Sections->new( section_id => 'x', course_id => 'x', name => 'x', status => 'active' ), '::Sections->new';
    is $obj->file, 'sections.csv', '::Sections->file';
    cmp_deeply [ $obj->header], [ qw/section_id course_id name status start_date end_date/ ], '::Sections->header';
};

subtest 'Tarp::Format::File::Terms' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Terms->new( term_id => 'x', name => 'x', status => 'active' ), '::Terms->new';
    is $obj->file, 'terms.csv', '::Terms->file';
    cmp_deeply [ $obj->header], [ qw/term_id name status start_date end_date/ ], '::Terms->header';
};

subtest 'Tarp::Format::File::Users' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Users->new( user_id => 'x', login_id => 'x', status => 'active' ), '::Users->new';
    is $obj->file, 'users.csv', '::Users->file';
    cmp_deeply [ $obj->header], [ qw/user_id login_id authentication_provider_id password first_name last_name sortable_name short_name email status/ ], '::Users->header';
};

subtest 'Tarp::Format::File::Xlists' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Format::File::Xlists->new( xlist_course_id => 'x', section_id => 'x', status => 'active' ), '::Xlists->new';
    is $obj->file, 'xlists.csv', '::Xlists->file';
    cmp_deeply [ $obj->header], [ qw/xlist_course_id section_id status/ ], '::Xlists->header';
};

subtest 'Tarp::Format::File Attrib' => sub {
    plan tests => 2;
    my $obj = Tarp::Format::File::Users->new;
    ok $obj = $obj->record( { user_id => 'x', login_id => 'x', status => 'active', is_pain_in_the_ass => 1 } ), '::Users->new(extra)';
    cmp_deeply $obj->extra, { 'is_pain_in_the_ass' => 1 }, '::Users->extra';
};


done_testing();
