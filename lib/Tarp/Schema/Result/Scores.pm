package Tarp::Schema::Result::Scores;
use Moose;
use namespace::autoclean;

use JSON;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('t_studentscores');

__PACKAGE__->add_columns(
                          score_type         => { data_type => 'text', is_nullable => 0            },
                          student_sis_id     => { data_type => 'text', is_nullable => 0            },
                          section_sis_id     => { data_type => 'text', is_nullable => 0            },
                          current_score      => { data_type => 'text', is_nullable => 0            },
                          point_possible     => { data_type => 'text', is_nullable => 0            },
                          extra              => { data_type => 'text', is_nullable => 0,           },
                          is_dirty           => { data_type => 'char', is_nullable => 0, size => 1 }, ## expect C, U, D, or 0|'' for not dirty
                        );

__PACKAGE__->set_primary_key(qw/score_type student_sis_id section_sis_id/);

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
