package Tarp::Schema::Result::Enrollments;
use Moose;
use namespace::autoclean;

use Tarp::Utils::Format::Enrollments;
use JSON;

extends 'DBIx::Class::Core';

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

sub new {
    my ( $class, $attrs ) = @_;
    if ( exists $attrs->{role} && defined $attrs->{role} ) {
        $attrs->{c_role} = $attrs->{role};
        delete $attrs->{role};
    }
    return $class->next::method($attrs);
}

sub format {
    my $self = shift;
    my $f = Tarp::Utils::Format::Enrollments->new( map { $_ => $self->$_ } grep { !/extra/ } map { $_->name } Tarp::Utils::Format::Enrollments->meta->get_all_attributes );
    $f->extra( $self->extra );
    return $f;
}

sub json {
    my $self = shift;
    my %h = map { $_ => $self->$_ } map { $_->name } Tarp::Utils::Format::Enrollments->meta->get_all_attributes;
    $h{extra} = $self->extra;
    return to_json( \%h );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
