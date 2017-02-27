package Tarp::Utils::Format::Terms;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus DateStr /;

with 'Tarp::Utils::Format';

has term_id  => ( is => 'rw', required => 1, isa => 'Str' );
has name     => ( is => 'rw', required => 1, isa => 'Str' );
has status   => ( is => 'rw', required => 1, isa => BasicStatus );

has start_date => ( is => 'rw', isa => DateStr, default => '', lazy => 1, coerce => 1 );
has end_date   => ( is => 'rw', isa => DateStr, default => '', lazy => 1, coerce => 1 );

sub file   { return 'terms.csv'; }
sub header { return qw/term_id name status start_date end_date/; }
sub key {
    my $self = shift;
    return $self->term_id;
}

__PACKAGE__->meta->make_immutable;

1;
