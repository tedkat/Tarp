package Tarp::Schema::Roles::ResultSet;

use Moose::Role;

sub not_in_sister {
    my $self = shift;
    my %sister_query = map { 'sister.'.$_ => undef } $self->result_source->primary_columns;
    return $self->search_rs( \%sister_query, { join => 'sister' } );
}

sub in_sister {
    my $self = shift;
    my %sister_query = map { 'sister.'.$_ => { '<>' => undef } } $self->result_source->primary_columns;
    return $self->search_rs( \%sister_query, { prefetch => 'sister' } );
}

1;
