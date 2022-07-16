package Tarp::Schema;

use Moose;

extends 'DBIx::Class::Schema';

our $VERSION = 2;

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
