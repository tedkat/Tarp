package Tarp::Utils::Format::Enrollments;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ EnrollmentStatus /;

with 'Tarp::Utils::Format';

has user_id            => ( is => 'rw', required => 1, isa => 'Str' );
has status             => ( is => 'rw', required => 1, isa => EnrollmentStatus );

has course_id          => ( is => 'rw', isa => 'Str', default => '', lazy => 1 ); ## ONE OF THESE ARE required
has section_id         => ( is => 'rw', isa => 'Str', default => '', lazy => 1 ); ## ONE OF THESE ARE required

has role               => ( is => 'rw', isa => 'Str', default => '', lazy => 1 ); ## ONE OF THESE ARE required
has role_id            => ( is => 'rw', isa => 'Str', default => '', lazy => 1 ); ## ONE OF THESE ARE required

has root_account       => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has associated_user_id => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );

sub file   { return 'enrollments.csv'; }
sub header { return qw/course_id section_id status user_id root_account associated_user_id role role_id/; }

sub BUILD {
    my $self = shift;
    die "course_id or section_id must be set!" if ( $self->course_id eq '' and $self->section_id eq '' );
    die "role or role_id must me set!"         if ( $self->role      eq '' and $self->role_id    eq '' );
}

__PACKAGE__->meta->make_immutable;

1;