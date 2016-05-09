###############################################################################################
##
## Tests for Tarp::Utils::Format::*
##
###############################################################################################

use Test::More tests => 20;
use Test::Deep;

BEGIN { use_ok 'Tarp::Utils::Format::Accounts'; }
BEGIN { use_ok 'Tarp::Utils::Format::Courses'; }
BEGIN { use_ok 'Tarp::Utils::Format::Enrollments'; }
BEGIN { use_ok 'Tarp::Utils::Format::GroupMembership'; }
BEGIN { use_ok 'Tarp::Utils::Format::Groups'; }
BEGIN { use_ok 'Tarp::Utils::Format::Sections'; }
BEGIN { use_ok 'Tarp::Utils::Format::Terms'; }
BEGIN { use_ok 'Tarp::Utils::Format::Users'; }
BEGIN { use_ok 'Tarp::Utils::Format::Xlists'; }


subtest 'Tarp::Utils::Format::Accounts' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Accounts->new( account_id => 'x', parent_account_id => 'x', name => 'x', status => 'active' ), '::Accounts->new';
    is $obj->file, 'accounts.csv', '::Accounts->file';
    cmp_deeply [ $obj->header], [ qw/account_id parent_account_id name status/ ], '::Accounts->header';
};

subtest 'Tarp::Utils::Format::Courses' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Courses->new( course_id => 'x', short_name => 'x', long_name => 'x', status => 'active' ), '::Courses->new';
    is $obj->file, 'courses.csv', '::Courses->file';
    cmp_deeply [ $obj->header], [ qw/course_id short_name long_name account_id term_id status/ ], '::Courses->header';
};

subtest 'Tarp::Utils::Format::Enrollments' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Enrollments->new( course_id => 'x', user_id => 'x', role => 'x', status => 'active' ), '::Enrollments->new';
    is $obj->file, 'enrollments.csv', '::Enrollments->file';
    cmp_deeply [ $obj->header], [ qw/course_id section_id status user_id root_account associated_user_id role role_id/ ], '::Enrollments->header';
};

subtest 'Tarp::Utils::Format::GroupMembership' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::GroupMembership->new( group_id => 'x', user_id => 'x', status => 'accepted' ), '::GroupMembership->new';
    is $obj->file, 'groups_membership.csv', '::GroupMembership->file';
    cmp_deeply [ $obj->header], [ qw/group_id user_id status/ ], '::GroupMembership->header';
};

subtest 'Tarp::Utils::Format::Groups' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Groups->new( group_id => 'x', name => 'x', status => 'available' ), '::Groups->new';
    is $obj->file, 'groups.csv', '::Groups->file';
    cmp_deeply [ $obj->header], [ qw/group_id name status account_id/ ], '::Groups->header';
};

subtest 'Tarp::Utils::Format::Sections' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Sections->new( section_id => 'x', course_id => 'x', name => 'x', status => 'active' ), '::Sections->new';
    is $obj->file, 'sections.csv', '::Sections->file';
    cmp_deeply [ $obj->header], [ qw/section_id course_id name status start_date end_date/ ], '::Sections->header';
};

subtest 'Tarp::Utils::Format::Terms' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Terms->new( term_id => 'x', name => 'x', status => 'active' ), '::Terms->new';
    is $obj->file, 'terms.csv', '::Terms->file';
    cmp_deeply [ $obj->header], [ qw/term_id name status start_date end_date/ ], '::Terms->header';
};

subtest 'Tarp::Utils::Format::Users' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Users->new( user_id => 'x', login_id => 'x', status => 'active' ), '::Users->new';
    is $obj->file, 'users.csv', '::Users->file';
    cmp_deeply [ $obj->header], [ qw/user_id login_id authentication_provider_id password first_name last_name short_name email status/ ], '::Users->header';
};

subtest 'Tarp::Utils::Format::Xlists' => sub {
    plan tests => 3;
    ok my $obj = Tarp::Utils::Format::Xlists->new( xlist_course_id => 'x', section_id => 'x', status => 'active' ), '::Xlists->new';
    is $obj->file, 'xlists.csv', '::Xlists->file';
    cmp_deeply [ $obj->header], [ qw/xlist_course_id section_id status/ ], '::Xlists->header';
};

subtest 'Tarp::Utils::Format Attrib' => sub {
    plan tests => 2;
    ok my $obj = Tarp::Utils::Format::Users->new( user_id => 'x', login_id => 'x', status => 'active', is_pain_in_the_ass => 1 ), '::Users->new(extra)';
    cmp_deeply $obj->extra, { 'is_pain_in_the_ass' => 1 }, '::Users->extra';
};

subtest 'Tarp::Utils::Format Role' => sub {
    plan tests => 2;
    my ($obj, $fail, $failmesg);

    ## method ->to_csv; 
    
    $obj = Tarp::Utils::Format::Xlists->new( xlist_course_id => '"x xx x"', section_id => 'x', status => 'active' );
    is $obj->to_csv, '"""x xx x""",x,active', 'Format::->to_csv with escaped " with "';
    $obj = Tarp::Utils::Format::Courses->new( course_id => '1 - - x', short_name => 'x', long_name => 'x', status => 'active' );
    is $obj->to_csv, '"1 - - x",x,x,,,active', 'Format::->to_csv with optional fields';
};

done_testing();
