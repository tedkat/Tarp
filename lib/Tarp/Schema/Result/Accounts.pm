package Tarp::Schema::Result::Accounts;
use Moose;
use namespace::autoclean;

use Tarp::Utils::Format::Accounts;
use JSON;

extends 'DBIx::Class::Core';

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

sub format {
    my $self = shift;
    my $f = Tarp::Utils::Format::Accounts->new( map { $_ => $self->$_ } grep { !/extra/ } map { $_->name } Tarp::Utils::Format::Accounts->meta->get_all_attributes );
    $f->extra( $self->extra );
    return $f;
}

sub json {
    my $self = shift;
    my %h = map { $_ => $self->$_ } map { $_->name } Tarp::Utils::Format::Accounts->meta->get_all_attributes;
    $h{extra} = $self->extra;
    return to_json( \%h );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
