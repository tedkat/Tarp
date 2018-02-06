package Tarp::Format::File::Accounts;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Accounts;

with 'Tarp::Format::File';

sub file   { 'accounts.csv' }
sub header { qw/account_id parent_account_id name status/ }
sub key    { qw/account_id/ }

sub this_record { "Tarp::Format::Record::Accounts" }

__PACKAGE__->meta->make_immutable;

1;
