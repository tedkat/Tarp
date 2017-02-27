package Tarp::Schema::Result::SYSQueue;
use Moose;
use namespace::autoclean;
use JSON;
use Path::Tiny;

extends 'DBIx::Class::Core';

__PACKAGE__->table('s_queue');

__PACKAGE__->load_components(qw/InflateColumn::DateTime TimeStamp FilterColumn/);


__PACKAGE__->add_columns(
                          queue_id        => { data_type => 'bigint',   is_nullable   => 0, is_auto_increment => 1    },
                          username        => { data_type => 'text',     is_nullable   => 0                            },
                          status          => { data_type => 'char',     is_nullable   => 0, size             => 1     }, ## C=Created, S=Sent, P=Processing, F=Finished
                          json_data       => { data_type => 'text',     is_nullable   => 0                            },
                          zip_file        => { data_type => 'text',     is_nullable   => 0                            },
                          queue_meta      => { data_type => 'text',     is_nullable   => 0                            },
                          run_start       => { data_type => 'datetime', is_nullable   => 0, timezone         => 'UTC' },
                          run_end         => { data_type => 'datetime', is_nullable   => 0, timezone         => 'UTC' },
                          creation_ts     => { data_type => 'datetime', set_on_create => 1, timezone         => 'UTC' },
                          submitted_ts    => { data_type => 'datetime', is_nullable   => 1, timezone         => 'UTC' },
                        );

__PACKAGE__->set_primary_key(qw/queue_id/);

__PACKAGE__->filter_column(
                            json_data =>  {
                                            filter_to_storage   => sub { encode_json( $_[1] ); },
                                            filter_from_storage => sub { decode_json( $_[1] ); },
                                          },
                            zip_file   => {
                                            filter_to_storage   => sub { if ( ref( $_[1] ) eq 'Path::Tiny' ) { return $_[1]->stringify; } else { return $_[1]; } },
                                            filter_from_storage => sub { path( $_[1] ); },
                                          },
                            queue_meta => {
                                            filter_to_storage   => sub { encode_json( $_[1] ); },
                                            filter_from_storage => sub { decode_json( $_[1] ); },
                                          },
                          );

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
