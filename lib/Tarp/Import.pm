package Tarp::Import;

use Moose;
use namespace::autoclean;
use Test::Deep::NoTest 'eq_deeply';
use Try::Tiny;
use Text::CSV;

use Tarp::Utils::Types qw/ FileORCode /;
use Tarp::Format;

my @CLASSIFY = qw/Accounts Terms Courses Users Sections Enrollments/;

## Public
has [ @CLASSIFY ] => ( is => 'ro', isa => FileORCode, required => 1 );
has schema        => ( is => 'ro', required => 1 );

## Private

## Constructor

sub BUILD {
    my $self = shift;
    for my $load ( @CLASSIFY ) {

        ## Setup fileformat
        my $format = "Tarp::Format::File::$load"->new;

        ## Setup tmp{RESULT} resultset
        my $load_rs =  $self->schema->resultset( 'tmp'.$load );

        ## Perform DB Load to Tmp Table
        if ( ref( $self->$load ) eq 'CODE' ) {
            $self->schema->txn_do( sub { 
                try {
                    _parse_data( $format, $load_rs, $self->$load->() )
                }
                catch {
                    die 'Import(CODE) Failed tmp' . $load . ' : ' . $_ . "\n";
                };
            });
        }
        else {
            $self->schema->txn_do( sub {
                try {
                    _parse_file( $format, $load_rs, $self->$load );
                }
                catch {
                    die 'Import(FILE:' . $self->$load . ') Failed tmp' . $load . ' : ' . $_ . "\n";
                };
            });
        }
    }
}

# sub process { ::DONT DO! Each must be ran then exported.
#   my $self = shift;
#   my $updates = $self->process_updates() // 0;
#   my $deletes = $self->process_deletes() // 0;
#   my $creates = $self->process_creates() // 0;
#   return { updates => $updates, deletes => $deletes, creates => $creates };
# }

sub updates {
    my $self = shift;
    my $counter = 0;
    $self->schema->txn_do( sub {
        ## Get Deleted users and update the data
        for my $user ( $self->schema->resultset('Users')->not_in_sister->all ) {
            $user->login_id(  'xxx'     . $user->user_id );
            $user->password( 'xxxxxxx' . $user->user_id );
            $user->is_dirty('U');
            $user->update;
            $counter++;
        }
        ## Get all possible updates
        for my $rs_class ( @CLASSIFY ) {
            for my $row ( $self->schema->resultset($rs_class)->in_sister->all ) {
                my $krow = $row->to_pruned_hash;
                my $trow = $row->sister->to_pruned_hash;
                ## for data we care about check if update is nessesary
                if ( ! eq_deeply( $krow, $trow ) ) {
                    map { $row->$_( $trow->{$_} ) } keys %$krow;
                    $row->extra( $row->sister->extra );
                    $row->is_dirty('U');
                    $row->update;
                    $counter++;
                }
                elsif ( ! eq_deeply( $row->extra, $row->sister->extra ) ) {
                    $row->extra( $row->sister->extra );
                    $row->update;
                }
            }
        }
    });
    return $counter;
}

sub deletes {
    my $self = shift;
    my $counter = 0;
    $self->schema->txn_do( sub {
        for my $rs_class ( @CLASSIFY ) {
            $counter += $self->schema->resultset($rs_class)->not_in_sister->update( { is_dirty => 'D' } );
        }
    });
    return $counter;
}

sub creates {
    my $self = shift;
    my $counter = 0;
    $self->schema->txn_do( sub {
        for my $rs_class ( @CLASSIFY ) {
            for my $row ( $self->schema->resultset('tmp'.$rs_class)->not_in_sister->all ) {
                my $new_row = $row->record->to_hash;
                $new_row->{is_dirty} = 'C';
                $self->schema->resultset($rs_class)->create( $new_row );
                $counter++;
            }
        }
    });
    return $counter;
}

###############
## FUNCTIONS
###############

sub _parse_file {
    my ( $fileformat, $rs, $file ) = @_;
    my $csv = Text::CSV->new( { escape_char => '"', quote_char => '"', eol => "\n" } );
    open( my $FILE, '<', $file ) || die $file, $!;
    my $header = $csv->getline($FILE);
    $csv->column_names( $header );
    $rs->delete; ## DROP DATA IN TEMP
    while ( my $row = $csv->getline_hr($FILE) ) {
        $rs->create( $fileformat->record( $row )->to_hash );
    }
    die $csv->error_diag() unless $csv->eof;
}

sub _parse_data {
    my ( $fileformat, $rs, $data ) = @_;
    die 'data not ARRAYREF!' unless ( ref($data) eq 'ARRAY' );
    $rs->delete; ## DROP DATA IN TEMP
    $rs->create( $fileformat->record( $_ )->to_hash ) foreach ( @$data );
}

# sub _get_removed_users_as_update {
#     my $resultset = shift;
#     my @removed_users;
#     for my $removed_user ( $resultset->not_in_sister->all ) {
#         my $record = Tarp::Format::Record::Users->new( %{ $removed_user->to_prunned_hash } );
#         $record->login_id( 'xxx' . $record->user_id );
#         $record->password( 'xxxxxxx' . $record->user_id );
#         push @removed_users, $record;
#     }
#     return \@removed_users;
# }


__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Tarp::Import - Class for loading data into local Database

=head1 SYNOPSIS

  use Tarp::Import;

  my $import = Tarp::Import->new; ## new loads files into tempTables

  $import->updates; ## perform temp to live table comparisons look for updates
  $import->creates; ## ...                                    look for creates
  $import->deletes; ## ...                                    look for deletes

=head1 DESCRIPTION

This module provides a safe interface to import data into a local Tarp Database.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Theodore Katseres.

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
