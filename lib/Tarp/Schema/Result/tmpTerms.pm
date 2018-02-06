package Tarp::Schema::Result::tmpTerms;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Terms;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('tmp_terms');

__PACKAGE__->add_columns(
                          term_id    => { data_type => 'text', is_nullable => 0            },
                          name       => { data_type => 'text', is_nullable => 0            },
                          status     => { data_type => 'text', is_nullable => 0            },
                          start_date => { data_type => 'text', is_nullable => 0            },
                          end_date   => { data_type => 'text', is_nullable => 0            },
                          extra      => { data_type => 'text', is_nullable => 0            },
                        );

__PACKAGE__->set_primary_key('term_id');

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have( sister => 'Tarp::Schema::Result::Terms' );

sub this_record { 'Tarp::Format::Record::Terms' }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
