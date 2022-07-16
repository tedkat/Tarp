package Tarp::Format::File::Users;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Users;

with 'Tarp::Format::File';

sub file   { 'users.csv' }
sub header { qw/user_id login_id integration_id authentication_provider_id password first_name last_name sortable_name short_name email status/ }
sub key    { qw/user_id/ }

sub this_record { "Tarp::Format::Record::Users"; }

__PACKAGE__->meta->make_immutable;

1;
