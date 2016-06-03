package Tarp::Schema::Result::Terms;
use Moose;
use namespace::autoclean;

use Tarp::Utils::Format::Terms;
use JSON;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('c_terms');

__PACKAGE__->add_columns(

                          term_id    => { data_type => 'text', is_nullable => 0            },
                          name       => { data_type => 'text', is_nullable => 0            },
                          status     => { data_type => 'text', is_nullable => 0            },
                          start_date => { data_type => 'text', is_nullable => 0            },
                          end_date   => { data_type => 'text', is_nullable => 0            },
                          extra              => { data_type => 'text', is_nullable => 0,           },
                          is_dirty   => { data_type => 'char', is_nullable => 0, size => 1 }, ## expect C, U, D, or 0|'' for not dirty
                        
                        );

__PACKAGE__->set_primary_key('term_id');

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

sub format {
    my $self = shift;
    Tarp::Utils::Format::Terms->new( map { $_ => $self->$_ } Tarp::Utils::Format::Terms->meta->get_all_attributes );
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
