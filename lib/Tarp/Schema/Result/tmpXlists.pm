package Tarp::Schema::Result::tmpXlists;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Xlists;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('tmp_xlists');

__PACKAGE__->add_columns(
                          xlist_course_id => { data_type => 'text', is_nullable => 0 },
                          section_id      => { data_type => 'text', is_nullable => 0 },
                          status          => { data_type => 'text', is_nullable => 0 },
                          extra           => { data_type => 'text', is_nullable => 0 },
                        );

__PACKAGE__->set_primary_key(qw/xlist_course_id section_id/);

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have(
                            sister => 'Tarp::Schema::Result::Xlists',
                            {
                                'foreign.xlist_course_id' => 'self.xlist_course_id',
                                'foreign.section_id'      => 'self.section_id'
                            }
                       );

sub this_record { 'Tarp::Format::Record::Xlists' }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
