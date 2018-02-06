package Tarp::Schema::ResultSet::Courses;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'tmpCourses'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
