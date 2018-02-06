package Tarp::Schema::Result::tmpUsers;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Users;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('tmp_users');

__PACKAGE__->add_columns(
                          user_id                    => { data_type => 'text', is_nullable => 0            },
                          login_id                   => { data_type => 'text', is_nullable => 0            },
                          authentication_provider_id => { data_type => 'text', is_nullable => 0            },
                          password                   => { data_type => 'text', is_nullable => 0            },
                          first_name                 => { data_type => 'text', is_nullable => 0            },
                          last_name                  => { data_type => 'text', is_nullable => 0            },
                          sortable_name              => { data_type => 'text', is_nullable => 0            },
                          short_name                 => { data_type => 'text', is_nullable => 0            },
                          email                      => { data_type => 'text', is_nullable => 0            },
                          status                     => { data_type => 'text', is_nullable => 0            },
                          extra                      => { data_type => 'text', is_nullable => 0            },
                        );

__PACKAGE__->set_primary_key('user_id');

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have( sister => 'Tarp::Schema::Result::Users' );

sub this_record { 'Tarp::Format::Record::Users' }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
