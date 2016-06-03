package Tarp::Utils::Builder::ToDB;

use Moose;
use namespace::autoclean;


use Test::Deep::NoTest 'eq_deeply';

extends 'Tarp::Utils::Builder';

has 'ignore_deletes' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_updates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_creates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );

has 'primaries'      => ( is => 'ro', isa => 'ArrayRef', builder => '_prim', lazy => 1, init_arg => undef );
has 'attributes'     => ( is => 'ro', isa => 'ArrayRef', builder => '_attr', lazy => 1, init_arg => undef );

sub _prim { return [ $_[0]->rs->result_source->primary_columns ];              }
sub _attr { return [ map { $_->name } $_[0]->util->meta->get_all_attributes ]; }

## is row in local data store? yes!return index : no!return -1
sub _in_dataset {
    my ( $self, $row ) = @_;

    my $in_dataset = -1;
    
    for ( my $i = 0; $i < scalar( @{ $self->data } ); $i++ ) {
        my $found = 0;

        for my $key ( @{ $self->primaries } ) {
            $found++ if ( $row->$key() eq $self->data->[$i]->$key() );
        }

        $in_dataset = $i if ( $found == scalar( @{ $self->primaries } ) );
    }
    return $in_dataset;
}

## mark row for update and update data in local db
sub _update_row_if_changed {
    my ( $self, $index, $row ) = @_;
    
    my $format = $self->data->[$index];
    
    for my $attr ( @{ $self->attributes } ) {
        if ( $attr eq 'extra' ) {
            $row->extra( $format->extra() ) if ( ! eq_deeply( $format->extra, $row->extra ) );
        }
        else {
            $row->$attr( $format->$attr() ) if ( $format->$attr() ne $row->$attr() );
        }
    }
    if ( $row->is_changed() ) {
        $row->is_dirty( 'U' );
        $row->update;
    }
}

## mark row for delete and update data
sub _delete_row {
    my ($self, $row) = @_;
    $row->is_dirty('D');
    $row->update;
}

## create row with mark for create
sub _create_row {
    my ($self, $row) = @_;
    $self->rs->create( { (map { $_ => $row->$_ } @{ $self->attributes }), is_dirty => 'C' } );
}


## Methods #################################################################################

sub commit {
    my $self = shift;
  
    $self->schema->txn_do( sub {
    
        my $rs = $self->rs->search_rs;
        
        while ( my $row = $rs->next ) {
    
            my $index = $self->_in_dataset( $row );
            
            if ( $index >= 0 ) {
    
                $self->_update_row_if_changed( $index, $row ) unless $self->ignore_updates;
                splice @{ $self->data }, $index, 1; ## Remove from local dataset
            }
            else {
                $self->_delete_row( $row ) unless $self->ignore_deletes;
            }
        }
        
        if ( ! $self->ignore_creates ) {
            for my $row ( @{ $self->data } ) { $self->_create_row( $row ); }
        }
        
        @{ $self->data } = (); ## Reset local dataset after commit;
    } );
    
    1;
}    

sub load {
    my ( $self, $data ) = @_;

    die "load must be called with a hashref argument\n" unless ( ref( $data ) eq 'HASH' );

    push @{ $self->data }, $self->util->new( %$data );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Tarp::Utils::Builder::ToDB - Factory Class for loading data into local Database

=head1 SYNOPSIS

  use Tarp::Utils::Builder::ToDB;

  my $schema = Tarp::Schema->connect( 'dbi:SQLite:dbname=localsql.db', '', '' );
  
  my $to = Tarp::Utils::Builder::ToDB->new( schema => $schema, format => 'accounts' );
  
  for my $raw_data ( get_accounts_hashrefs() ) {
      $to->load( $raw_data );
  }
  
  $to->commit;
  

=head1 DESCRIPTION

This module provides a safe interface to the local Tarp Database.

=head2 new( %attr | \%attr )

Method returns a new instance of Tarp::Utils::Builder::ToDB
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

L<Tarp::Utils::Builder>, L<Tarp::Utils::Format> and L<Tarp::Schema>.

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
