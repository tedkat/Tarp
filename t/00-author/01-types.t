###############################################################################################
##
## Tests for Tarp::Utils::Types
##
###############################################################################################

use Test::More;
use Test::Deep;
use Try::Tiny;
use DateTime;

BEGIN {
    ## Skip
    plan skip_all => 'set AUTHOR_TESTING to run tests' unless ( exists $ENV{AUTHOR_TESTING} );
}

{
    package Test::Tarp::Utils::Types;

    use Moose;
    use namespace::autoclean;

    use Tarp::Utils::Types qw/ :all /;

    has BasicStatus           => ( is => 'ro', isa => BasicStatus,          );
    has CourseStatus          => ( is => 'ro', isa => CourseStatus,         );
    has EnrollmentStatus      => ( is => 'ro', isa => EnrollmentStatus,     );
    has GroupStatus           => ( is => 'ro', isa => GroupStatus,          );
    has GroupMembershipStatus => ( is => 'ro', isa => GroupMembershipStatus );
    has FileORCode            => ( is => 'ro', isa => FileORCode            );
    has DateStr               => ( is => 'ro', isa => DateStr, coerce => 1 );
    has OptionalDateStr       => ( is => 'ro', isa => OptionalDateStr, coerce => 1 );

    __PACKAGE__->meta->make_immutable;

    1;
}


## Type Constraints ########################################################################################################################

## BasicStatus
subtest 'BasicStaus type' => sub {
    for my $status ( qw/active deleted/ ) {
        try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( BasicStatus => $status ); $fail = 0; } catch { $failmesg = $_; };
        ok !$fail, "test new BasicStatus( status => $status )";
        is $failmesg, '', 'no message';
    }
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( BasicStatus => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new BasicStatus( status => 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';

};

## FileORCode
subtest 'FileORCode type' => sub {
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( FileORCode => $0 ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new FileORCode( existing File )";
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( FileORCode => sub {} ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new FileORCode( CODE )";

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( FileORCode => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new FileORCode( nosuchfile 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( FileORCode => {} ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new FileORCode( HASH )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';
};


## CourseStatus
subtest 'CourseStatus type' => sub {
    for my $status ( qw/active deleted completed/ ) {
        try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( CourseStatus => $status ); $fail = 0; } catch { $failmesg = $_; };
        ok !$fail, "test new CourseStatus( status => $status )";
        is $failmesg, '', 'no message';
    }
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( CourseStatus => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new CourseStatus( status => 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';
};

## EnrollmentStatus
subtest 'EnrollmentStatus type' => sub {
    for my $status ( qw/active deleted completed inactive/ ) {
        try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( EnrollmentStatus => $status ); $fail = 0; } catch { $failmesg = $_; };
        ok !$fail, "test new EnrollmentStatus( status => $status )";
        is $failmesg, '', 'no message';
    }
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( EnrollmentStatus => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new EnrollmentStatus( status => 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';
};

## GroupStatus
subtest 'GroupStatus type' => sub {
    for my $status ( qw/available deleted completed closed/ ) {
        try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( GroupStatus => $status ); $fail = 0; } catch { $failmesg = $_; };
        ok !$fail, "test new GroupStatus( status => $status )";
        is $failmesg, '', 'no message';
    }
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( GroupStatus => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new GroupStatus( status => 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';
};

## GroupMembershipStatus
subtest 'GroupMembershipStatus type' => sub {
    for my $status ( qw/accepted deleted/ ) {
        try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( GroupMembershipStatus => $status ); $fail = 0; } catch { $failmesg = $_; };
        ok !$fail, "test new GroupMembershipStatus( status => $status )";
        is $failmesg, '', 'no message';
    }
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( GroupMembershipStatus => 'NOEXISTS' ); $fail = 0; } catch { $failmesg = $_; };
    ok $fail, "test new GroupMembershipStatus( status => 'NOEXISTS' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';
};

## DateStr
subtest 'DateStr type' => sub {
    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( DateStr => '1990-01-01T10:05:05Z' ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new DateStr(  '1990-01-01T10:05:05Z' )";
    is $failmesg, '', 'no message';

    my $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5 );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( DateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new DateStr(  DateTime )";
    is $failmesg, '', 'no message';
    is $obj->DateStr, '1990-01-01T10:05:05Z', 'DateTime to DateStr coerce';

    $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5, time_zone => 'UTC' );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( DateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new DateStr(  DateTime ) as UTC";
    is $failmesg, '', 'no message';
    is $obj->DateStr, '1990-01-01T10:05:05Z', 'DateTime(UTC) to DateStr coerce';

    $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5, time_zone => 'America/Chicago' );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( DateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new DateStr(  DateTime ) as America/Chicago ";
    is $failmesg, '', 'no message';
    is $obj->DateStr, '1990-01-01T16:05:05Z', 'DateTime(America/Chicago) to DateStr coerce as UTC';

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( DateStr => '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ' ); $fail = 0 } catch { $failmesg = $_; };
    ok $fail, "test new DateStr( '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( DateStr => '' ); $fail = 0 } catch { $failmesg = $_; };
    ok $fail, "test new DateStr( '' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message'
};

## OptionalDateStr
subtest 'OptionalDateStr type' => sub {

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( OptionalDateStr => '' ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new OptionalDateStr(  '' )";
    is $failmesg, '', 'no message';

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( OptionalDateStr => '1990-01-01T10:05:05Z' ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new OptionalDateStr(  '1990-01-01T10:05:05Z' )";
    is $failmesg, '', 'no message';

    my $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5 );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( OptionalDateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new OptionalDateStr(  DateTime )";
    is $failmesg, '', 'no message';
    is $obj->OptionalDateStr, '1990-01-01T10:05:05Z', 'DateTime to OptionalDateStr coerce';

    $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5, time_zone => 'UTC' );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( OptionalDateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new OptionalDateStr(  DateTime ) as UTC";
    is $failmesg, '', 'no message';
    is $obj->OptionalDateStr, '1990-01-01T10:05:05Z', 'DateTime(UTC) to OptionalDateStr coerce';

    $date = DateTime->new( year => 1990, month => 1, day => 1, hour => 10, minute => 5, second => 5, time_zone => 'America/Chicago' );
    try { $fail = 1; $failmesg = ''; $obj = Test::Tarp::Utils::Types->new( OptionalDateStr => $date ); $fail = 0; } catch { $failmesg = $_; };
    ok !$fail, "test new OptionalDateStr(  DateTime ) as America/Chicago ";
    is $failmesg, '', 'no message';
    is $obj->OptionalDateStr, '1990-01-01T16:05:05Z', 'DateTime(America/Chicago) to OptionalDateStr coerce as UTC';

    try { $fail = 1; $failmesg = ''; Test::Tarp::Utils::Types->new( OptionalDateStr => '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ' ); $fail = 0 } catch { $failmesg = $_; };
    ok $fail, "test new OptionalDateStr( '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ' )";
    like $failmesg, qr/does not pass the type constraint/, 'fail message';

};

done_testing();
