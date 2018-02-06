package Tarp::Schema::Roles::Result;

use Moose::Role;
use JSON;

requires qw/this_record result_source/;

sub filter_hash {
    my $self = shift;
    my $hash = shift;
    if ( exists $hash->{c_role} ) {
        $hash->{role} = $hash->{c_role};
        delete $hash->{c_role};
    }
    return $hash;
}

sub filter_columns {
    my $self = shift;
    for my $c ( @_ ) {
        $c = 'role' if ( $c eq 'c_role');
    }
    return @_;
}

sub to_hash { return { map { $_ => $_[0]->$_ } $_[0]->result_source->columns }; }

sub to_pruned_hash {
    my $self = shift;
    return { map { $_ => $self->$_ } grep { !/(extra|is_dirty)/ } $self->filter_columns( $self->result_source->columns ) }; }

sub record {
    my $self = shift;
    my $record = $self->this_record->new( $self->to_pruned_hash->%* );
    $record->extra( $self->extra );
    return $record;
}

1;
