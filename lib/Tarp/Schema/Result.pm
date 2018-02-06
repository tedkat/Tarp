package Tarp::Schema::Result;
use Moose;
use namespace::autoclean;
use JSON;

extends 'DBIx::Class::Core';

sub to_json { to_json(@_) }
sub from_json { from_json(@_) }


__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
