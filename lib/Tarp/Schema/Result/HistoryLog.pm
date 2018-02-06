package Tarp::Schema::Result::HistoryLog;
use Moose;
use namespace::autoclean;
use JSON;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime TimeStamp FilterColumn/);

__PACKAGE__->table('t_history_log');

__PACKAGE__->add_columns(
                          histlog_id         => { data_type => 'bigint',   is_nullable   => 0, is_auto_increment => 1 },
                          domainspace        => { data_type => 'text',     is_nullable   => 0, },
                          nametag            => { data_type => 'text',     is_nullable   => 0, },
                          jsondata           => { data_type => 'text',     is_nullable   => 0, },
                          creation_ts        => { data_type => 'datetime', set_on_create => 1, timezone => 'UTC' },
                        );

__PACKAGE__->set_primary_key(qw/histlog_id/);

__PACKAGE__->filter_column(
                            jsondata => {
                                            filter_to_storage   => sub { to_json(   $_[1] ); },
                                            filter_from_storage => sub { from_json( $_[1] ); },
                                        }
                          );

sub json {
    my $self = shift;
    return to_json( { map { $_ => '' . $self->$_ } $self->result_source->columns } );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
