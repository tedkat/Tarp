package Tarp::Schema::Result::Accounts;
use Moose;
use namespace::autoclean;
use JSON;

use Tarp::Format::Record::Accounts;

extends 'DBIx::Class::Core';

with 'Tarp::Schema::Roles::Result';

__PACKAGE__->load_components(qw/FilterColumn/);

__PACKAGE__->table('c_accounts');

__PACKAGE__->add_columns(
                          account_id         => { data_type => 'text', is_nullable => 0            },
                          parent_account_id  => { data_type => 'text', is_nullable => 0            },
                          name               => { data_type => 'text', is_nullable => 0            },
                          status             => { data_type => 'text', is_nullable => 0            },
                          extra              => { data_type => 'text', is_nullable => 0,           },
                          is_dirty           => { data_type => 'char', is_nullable => 0, size => 1 }, ## expect C, U, D, or 0|'' for not dirty
                        );

__PACKAGE__->set_primary_key(qw/account_id/);

__PACKAGE__->filter_column(
                            extra => {
                                         filter_to_storage   => sub { to_json(   $_[1] ); },
                                         filter_from_storage => sub { from_json( $_[1] ); },
                                     }
                          );

__PACKAGE__->might_have( sister => 'Tarp::Schema::Result::tmpAccounts' );

sub this_record { 'Tarp::Format::Record::Accounts' }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
