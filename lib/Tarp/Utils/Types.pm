package Tarp::Utils::Types;

use Type::Library
 -base,
 -declare => qw/Datetime BasicStatus CourseStatus EnrollmentStatus GroupStatus GroupMembershipStatus DateStr/;

use Type::Utils -all;
use Types::Standard -types;

class_type Datetime, { class => 'DateTime' };

declare BasicStatus,
    as Str,
    where { $_ eq 'active' or $_ eq 'deleted' };

declare CourseStatus,
    as Str,
    where { $_ eq 'active' or $_ eq 'deleted' or $_ eq 'completed' };

declare EnrollmentStatus,
    as Str,
    where { $_ eq 'active'  or $_ eq 'deleted' or $_ eq 'completed' or $_ eq 'inactive' };

declare GroupStatus,
    as Str,
    where { $_ eq 'available' or $_ eq 'deleted' or $_ eq 'completed' or $_ eq 'closed' };

declare GroupMembershipStatus,
    as Str,
    where { $_ eq 'accepted'  or $_ eq 'deleted' };
    
declare DateStr,
    as Str,
    where { m/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/ };
    
coerce DateStr,
    from Datetime,
    via { $_->set_time_zone('UTC'); return sprintf('%sT%sZ', $_->ymd, $_->hms); };

1;