package Tarp::Utils::Builder;
use Moose;
use namespace::autoclean;

use Module::Load;

my %format = (
        users             => { util => 'Tarp::Utils::Format::Users',           dbic => 'Users'           },
        accounts          => { util => 'Tarp::Utils::Format::Accounts',        dbic => 'Accounts'        },
        terms             => { util => 'Tarp::Utils::Format::Terms',           dbic => 'Terms'           },
        courses           => { util => 'Tarp::Utils::Format::Courses',         dbic => 'Courses'         },
        sections          => { util => 'Tarp::Utils::Format::Sections',        dbic => 'Sections'        },
        enrollments       => { util => 'Tarp::Utils::Format::Enrollments',     dbic => 'Enrollments'     },
        groups            => { util => 'Tarp::Utils::Format::Groups',          dbic => 'Groups'          },
        groups_membership => { util => 'Tarp::Utils::Format::GroupMembership', dbic => 'GroupMembership' },
        xlists            => { util => 'Tarp::Utils::Format::Xlists',          dbic => 'Xlists'          },
);

has 'schema' => ( is => 'ro', isa => 'DBIx::Class', required => 1 );
has 'format' => ( is => 'ro', isa => 'Str',         required => 1 );

has 'data'    => ( is => 'ro', isa => 'ArrayRef', 'default' => sub { []; }, lazy => 1, init_arg => undef );
has 'util'    => ( is => 'ro', isa => 'Str',      'builder' => '_util',     lazy => 1, init_arg => undef );
has 'dbic'    => ( is => 'ro', isa => 'Str',      'builder' => '_dbic',     lazy => 1, init_arg => undef );

sub _util  { $format{ $_[0]->format() }{util}; }
sub _dbic  { $format{ $_[0]->format() }{dbic}; }

sub rs { $_[0]->schema->resultset( $_[0]->dbic ); }

sub BUILD {
    my $self = shift;
    die sprintf( 'Invalid data format (%s)', $self->format ) unless ( exists $format{ $self->format } );
    load $self->util;
}

__PACKAGE__->meta->make_immutable;

1;

