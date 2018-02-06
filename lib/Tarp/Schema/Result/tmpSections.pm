package Tarp::Schema::Result::tmpSections;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Sections;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('tmp_sections');

__PACKAGE__->add_columns(
                          section_id  => { data_type => 'text', is_nullable => 0            },
                          course_id   => { data_type => 'text', is_nullable => 0            },
                          name        => { data_type => 'text', is_nullable => 0            },
                          status      => { data_type => 'text', is_nullable => 0            },
                          start_date  => { data_type => 'text', is_nullable => 0            },
                          end_date    => { data_type => 'text', is_nullable => 0            },
                          extra       => { data_type => 'text', is_nullable => 0            },
                        );

__PACKAGE__->set_primary_key('section_id');

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have( sister => 'Tarp::Schema::Result::Sections' );

sub this_record { 'Tarp::Format::Record::Sections' }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
