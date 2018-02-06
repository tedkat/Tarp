package Tarp::Schema::Result::Enrollments;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Enrollments;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('c_enrollments');

__PACKAGE__->add_columns(

                          course_id          => { data_type => 'text',    is_nullable => 0                     },
                          user_id            => { data_type => 'text',    is_nullable => 0                     },
                          c_role             => { data_type => 'text',    is_nullable => 0, accessor => 'role' },
                          role_id            => { data_type => 'text',    is_nullable => 0,                    },
                          root_account       => { data_type => 'text',    is_nullable => 0,                    },
                          section_id         => { data_type => 'text',    is_nullable => 0                     },
                          status             => { data_type => 'text',    is_nullable => 0                     },
                          associated_user_id => { data_type => 'text',    is_nullable => 0                     },
                          extra              => { data_type => 'text',    is_nullable => 0,                    },
                          is_dirty           => { data_type => 'char',    is_nullable => 0, size => 1          }, ## expect C, U, D, or 0|'' for not dirty

                        );

__PACKAGE__->set_primary_key(qw/course_id user_id c_role section_id associated_user_id/);

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have(
                            sister => 'Tarp::Schema::Result::tmpEnrollments',
                            {
                                'foreign.course_id'          => 'self.course_id',
                                'foreign.user_id'            => 'self.user_id',
                                'foreign.c_role'             => 'self.c_role',
                                'foreign.section_id'         => 'self.section_id',
                                'foreign.associated_user_id' => 'self.associated_user_id'
                            }
                       );

sub new {
    my ( $class, $attrs ) = @_;
    if ( exists $attrs->{role} && defined $attrs->{role} ) {
        $attrs->{c_role} = $attrs->{role};
        delete $attrs->{role};
    }
    return $class->next::method($attrs);
}

sub this_record { 'Tarp::Format::Record::Enrollments' }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
