package Tarp::Utils::Format::Builder::Import;

use Moose;
use namespace::autoclean;


use Test::Deep::NoTest 'eq_deeply';
use JSON;
extends 'Tarp::Utils::Format::Builder';

has 'ignore_deletes' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_updates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_creates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );

has 'attributes'     => ( is => 'ro', isa => 'ArrayRef', builder => '_attr', lazy => 1, init_arg => undef );

sub _prim { return [ $_[0]->rs->result_source->primary_columns ];              }
sub _attr { return [ map { $_->name } $_[0]->util->meta->get_all_attributes ]; }

## Test for dirty
sub _is_dirty {
    return 1 if ( defined $_[0] && $_[0] =~ m/(C|U|D)/ );
    return 0;
}

## is row in local data store? yes!return index : no!return -1
sub _in_dataset {
    my ( $self, $format ) = @_;
    exists $self->data->{$format->key} ? return $self->data->{$format->key} : return undef;
}

## mark row for update and update data in local db
sub _update_row_if_changed {
    my ( $self, $format, $row ) = @_;

    my $oldformat = $row->format;
    my $valid_change = 0;
    for my $attr ( @{ $self->attributes } ) {

        if ( $attr eq 'extra' ) {
            if ( ! eq_deeply( $format->extra, $oldformat->extra ) ) {
                $row->extra( $format->extra() );
            }
        }
        else {
            if ( $format->$attr() ne $oldformat->$attr() ) {
                $row->$attr( $format->$attr() );
                $valid_change++;
            }
        }
    }
    if ( $row->is_changed() ) {
        if ( $valid_change ) {
            $row->is_dirty( 'U' );
            $self->schema->resultset('HistoryLog')->create(
                                                            {
                                                                domainspace => $self->format,
                                                                nametag     => $format->key,
                                                                jsondata    => { 'update' => { to => $format->to_hash, from => $oldformat->to_hash } },
                                                            }
                                                          );
        }
        $row->update;
    }
}

## mark row for delete and update data
sub _delete_row {
    my ($self, $row) = @_;
    my $format = $row->format;
    $self->schema->resultset('HistoryLog')->create(
                                                    {
                                                        domainspace => $self->format,
                                                        nametag     => $format->key,
                                                        jsondata    => { 'delete' => $format->to_hash },
                                                    }
                                                  );
    $row->is_dirty('D');
    $row->status( 'deleted' );
    $row->update;
}

## create row with mark for create
sub _create_row {
    my ($self, $d) = @_;
    $self->rs->create( { (map { $_ => $d->$_ } @{ $self->attributes }), is_dirty => 'C' } );
    $self->schema->resultset('HistoryLog')->create(
                                                    {
                                                        domainspace => $self->format,
                                                        nametag     => $d->key,
                                                        jsondata    => { 'create' =>  $d->to_hash },
                                                    }
                                                  );
}


## Methods #################################################################################

sub commit {
    my $self = shift;

    $self->schema->txn_do( sub {

        my $rs = $self->rs->search_rs;

        while ( my $row = $rs->next ) {

            my $newdata = $self->_in_dataset( $row->format );

            if ( defined $newdata ) {
                ## Ignore update if already dirty
                if ( ! _is_dirty( $row->is_dirty ) && !$self->ignore_updates ) {
                    $self->_update_row_if_changed( $newdata, $row );
                }
                delete $self->data->{ $newdata->key }; ## Remove from local dataset
            }
            else {
                $self->_delete_row( $row ) unless $self->ignore_deletes;
            }
        }

        if ( ! $self->ignore_creates ) {
            for my $key ( keys %{ $self->data } ) {
                $self->_create_row( $self->data->{$key} );
            }
        }

        %{ $self->data } = (); ## Reset local dataset after commit;
    } );

    1;
}

sub load {
    my ( $self, $data ) = @_;

    die "load must be called with a hashref argument\n" unless ( ref( $data ) eq 'HASH' );

    my $fmt = $self->util->new( %$data );

    if ( exists $self->data->{$fmt->key} ) {
        warn 'duplicate key in load ', $fmt->key, ' SKIPPING';
    }
    else {
        $self->data->{$fmt->key} = $fmt;
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Tarp::Utils::Format::Builder::Import - Factory Class for loading data into local Database

=head1 SYNOPSIS

  use Tarp::Utils::Format::Builder::Import;

  my $schema = Tarp::Schema->connect( 'dbi:SQLite:dbname=localsql.db', '', '' );

  my $to = Tarp::Utils::Format::Builder::Import->new( schema => $schema, format => 'accounts' );

  for my $raw_data ( get_accounts_hashrefs() ) {
      $to->load( $raw_data );
  }

  $to->commit;


=head1 DESCRIPTION

This module provides a safe interface to the local Tarp Database.

=head2 new( %attr | \%attr )

Method returns a new instance of Tarp::Utils::Format::Builder::Import
The following attributes are available:

=head3 format => 'string'

Required argument: set format link for Tarp::Utils::Format::* and Tarp::Schema::Result::*

=over 6

=item users

L<Tarp::Utils::Format::Users> and L<Tarp::Schema::Result::Accounts>

=item accounts

L<Tarp::Utils::Format::Accounts> and L<Tarp::Schema::Result::Accounts>

=item terms

L<Tarp::Utils::Format::Terms> and L<Tarp::Schema::Result::Terms>

=item courses

L<Tarp::Utils::Format::Courses> and L<Tarp::Schema::Result::Courses>

=item sections

L<Tarp::Utils::Format::Sections> and L<Tarp::Schema::Result::Sections>

=item enrollments

L<Tarp::Utils::Format::Enrollments> and L<Tarp::Schema::Result::Enrollments>

=item groups

L<Tarp::Utils::Format::Groups> and L<Tarp::Schema::Result::Groups>

=item groups_membership

L<Tarp::Utils::Format::GroupMembership> and L<Tarp::Schema::Result::GroupMembership>

=item xlists

L<Tarp::Utils::Format::Xlists> and L<Tarp::Schema::Result::Xlists>

=back

=head3 schema => $schema

Required argument: connect called local instance of Tarp::Schema


=head3 ignore_deletes => 0

Optional argument: default is false, truethy if you want to skip over deletes.

=head3 ignore_updates => 0

Optional argument: default is false, truethy if you want to skip over updates.

=head3 ignore_creates => 0

Optional argument: default is false, truethy if you want to skip over creates.

=head2 load( \%raw_data );

Convert raw data passed as hashref to format Tarp::Utils::Format::* given in new and push
to this object's array store.

=head2 data

Returns ArrayRef for this object's current store. Should be array of Tarp::Utils::Format::* objects.

=head2 commit

Process comb over all ->load'ed data and compare that list to what is currently in the local database for format given.
On updates it will update local database and mark the local record as an update.
On deletes it will mark the record as a delete.
On creates it will add the record to the local database with a mark of create.
I<commit> will process all data as a single transaction to the database if there is an error data will be rolled back.

=head1 SEE ALSO

L<Tarp::Utils::Format::Builder>, L<Tarp::Utils::Format> and L<Tarp::Schema>.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Theodore Katseres.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Terms of the Perl programming language system itself

a) the GNU General Public License as published by the Free
   Software Foundation; either version 1, or (at your option) any
   later version, or
b) the "Artistic License"


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
