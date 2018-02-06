package Tarp::Format::Record::Terms;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus OptionalDateStr /;

with 'Tarp::Format::Record';

has term_id  => ( is => 'rw', required => 1, isa => 'Str' );
has name     => ( is => 'rw', required => 1, isa => 'Str' );
has status   => ( is => 'rw', required => 1, isa => BasicStatus );

has start_date => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );
has end_date   => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );

sub columns { qw/term_id name status start_date end_date/ }
sub key { return $_[0]->term_id; }

__PACKAGE__->meta->make_immutable;

1;
