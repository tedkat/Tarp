#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin.'/../lib';

use Tarp;
use Tarp::Import;

### 
### Basic SIS calls for inlining declared here
###

my $Accounts = sub {
    die 'Implement $Accounts Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Accounts' => 'FOR REQUIRED FIELDS' }, {} ];
};

my $Terms = sub {
    die 'Implement $Terms Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Terms' => 'FOR REQUIRED FIELDS' }, {} ];
};

my $Courses = sub {
    die 'Implement $Courses Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Courses' => 'FOR REQUIRED FIELDS' }, {} ];
};

my $Users = sub {
    die 'Implement $Users Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Users' => 'FOR REQUIRED FIELDS' }, {} ];
};

my $Sections = sub {
    die 'Implement $Sections Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Sections' => 'FOR REQUIRED FIELDS' }, {} ];
};

my $Enrollments = sub {
    die 'Implement $Enrollments Function'; ## Get you Account Info Here
    ## Send Account Data Back
    return [ { 'LOOKUP Tarp::Record::Enrollments' => 'FOR REQUIRED FIELDS' }, {} ];
};

##
##  Setup the same
##

my $tarp = Tarp->new( configfile => $FindBin::Bin . '/../config.json' );

##
##  Override Tarp::Import reading of files
##

Tarp::Import->new(
                    schema      => $tarp->schema,
                    Accounts    => $Accounts,
                    Terms       => $Terms,
                    Courses     => $Courses,
                    Users       => $Users,
                    Sections    => $Sections,
                    Enrollments => $Enrollments
                 );


$tarp->push_changes;

exit 0;
