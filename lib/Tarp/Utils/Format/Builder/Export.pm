package Tarp::Utils::Format::Builder::Export;

use Moose;
use namespace::autoclean;
use Try::Tiny;

extends 'Tarp::Utils::Format::Builder';

has 'ignore_deletes' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_updates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );
has 'ignore_creates' => ( is => 'ro', isa => 'Bool', 'default' => 0, lazy => 1 );

sub _get_data {
    my ( $self, $rs, $zip ) = @_;
    my ( $csv, $file, $m );
    while ( my $row = $rs->next ) {
        my $format = $row->format;
        if ( !defined $csv ) {
            $csv  = $format->csv_header; ## Add header to csv data
            $file = $format->file;
        }
        $csv .= $row->format->to_csv;
    }
    if ( defined $csv ) {
        if ( defined $zip ) {
            $m = $zip->addString( $csv, $file );
            $m->desiredCompressionMethod(8) ## COMPRESSION_DEFLATED
        }
        else {
            $m = { $file => $csv }
        }
    }
    return $m;
}


## Methods #################################################################################

sub gather {
    my ( $self, $zip ) = @_;

    if ( defined $zip && !( ref($zip) && ref($zip) eq 'Archive::Zip::Archive' ) ) {
        die '$zip not a Archive::Zip object!';
    }

    my ( $type, $params );

    if    ( ! $self->ignore_updates ) { $type = 'update'; $params = { is_dirty => 'U' }; }
    elsif ( ! $self->ignore_creates ) { $type = 'create'; $params = { is_dirty => 'C' }; }
    elsif ( ! $self->ignore_deletes ) { $type = 'delete'; $params = { is_dirty => 'D' }; }
    else                              { die 'Unknown type for gather!';                  }

    delete $self->data->{$type} if ( exists $self->data->{$type} );

    $self->schema->txn_do( sub{
        my $m = $self->_get_data( $self->rs->search_rs( $params ), $zip );
        $self->data->{$type} = $m if ( defined $m );
        if ( $type eq 'delete' ) {
            $self->rs->search_rs( $params )->delete;
        }
        else {
            $self->rs->search_rs( $params )->update( { is_dirty => '' } );
        }
    });
    return 1;
}

sub heap {
    my ( $self, $zip ) = @_;

    if ( defined $zip && !( ref($zip) && ref($zip) eq 'Archive::Zip::Archive' ) ) {
        die '$zip not a Archive::Zip object!';
    }

    delete $self->data->{ $self->format } if ( exists $self->data->{ $self->format } );

    $self->schema->txn_do( sub{
        my $m = $self->_get_data( $self->rs->search_rs( { is_dirty => '' } ), $zip );
        $self->data->{ $self->format } = $m if ( defined $m );
    } );
    return 1;
}

sub pick {
    my ( $self, $query, $zip ) = @_;

    if ( defined $zip && !( ref($zip) && ref($zip) eq 'Archive::Zip::Archive' ) ) {
        die '$zip not a Archive::Zip object!';
    }

    delete $self->data->{ $self->format } if ( exists $self->data->{ $self->format } );

    $self->schema->txn_do( sub{
        my $m = $self->_get_data( $self->rs->search_rs( $query ), $zip );
        $self->data->{ $self->format } = $m if ( defined $m );
    } );
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Tarp::Utils::Format::Builder::Export - Factory Class for loading changed data into a zip

=head1 SYNOPSIS

  use Tarp::Utils::Format::Builder::Export;
  use Archive::Zip;

  my $zip = Archive::Zip->new;

  my $schema = Tarp::Schema->connect( 'dbi:SQLite:dbname=localsql.db', '', '' );

  my $to = Tarp::Utils::Format::Builder::Export->new(
                                                 schema         => $schema,
                                                 format         => 'accounts',
                                                 zip            => $zip,
                                                 ignore_creates => 1,
                                                 ignore_deletes => 1
                                             );
  $to->gather();

  ## $zip may contain members for all updates for accounts

=head1 DESCRIPTION

This module provides a safe interface to the local Tarp Database.

=head2 new( %attr | \%attr )

Method returns a new instance of Tarp::Utils::Format::Builder::Export
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

=head2 gather();

Get All changed data from this formats commit based on ignore_(updates|deletes|creates) passed.  Try to ignore to sets at a time.

=head2 heap();

Like gather but grabs all non-dirty data.

=head2 data

Returns HashRef for this object's current action store. HashRef of keyed zip members.  example.

  $object->data->{update} or $object->data->{create} or $object->data->{delete}

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
