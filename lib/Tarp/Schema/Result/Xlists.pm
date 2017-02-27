package Tarp::Schema::Result::Xlists;
use Moose;
use namespace::autoclean;

use Tarp::Utils::Format::Xlists;
use JSON;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('c_xlists');

__PACKAGE__->add_columns(
                          xlist_course_id => { data_type => 'text', is_nullable => 0 },
                          section_id      => { data_type => 'text', is_nullable => 0 },
                          status          => { data_type => 'text', is_nullable => 0 },
                          extra           => { data_type => 'text', is_nullable => 0 },
                          is_dirty        => { data_type => 'char', is_nullable => 0, size => 1 }, ## expect C, U, D, or 0|'' for not dirty
                        );

__PACKAGE__->set_primary_key(qw/xlist_course_id section_id/);

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

sub format {
    my $self = shift;
    my $f = Tarp::Utils::Format::Xlists->new( map { $_ => $self->$_ } grep { !/extra/ } map { $_->name } Tarp::Utils::Format::Xlists->meta->get_all_attributes );
    $f->extra( $self->extra );
    return $f;
}

sub json {
    my $self = shift;
    my %h = map { $_ => $self->$_ } map { $_->name } Tarp::Utils::Format::Xlists->meta->get_all_attributes;
    $h{extra} = $self->extra;
    return to_json( \%h );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
