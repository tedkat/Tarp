package Tarp::Export;

use Moose;
use namespace::autoclean;
use Try::Tiny;
use Archive::Zip qw/:ERROR_CODES :CONSTANTS/;

use Tarp::Format;

has schema => ( is => 'ro', required => 1 );

## Public

sub deletes {
    my $self = shift;
    my @zips;

    for my $run ( ['Enrollments'], ['Sections'], [qw/Accounts Terms Courses Users/]  ) {
        my ( $zip, @members ) = ( Archive::Zip->new );
        for my $rs_class ( @$run ) {
            if ( _add_member_zip($zip, "Tarp::Format::File::$rs_class"->new, $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'D'}))) {
                push @members, $rs_class;
                $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'D'})->delete;
            }
        }
        push @zips, { zip => $zip, string => join('_', @members) } if ( @members );
    }
    return \@zips;
}

sub creates {
    my $self = shift;
    my @zips;

    for my $run ( [qw/Accounts Terms Courses Users/], ['Sections'], ['Enrollments'] ) {
        my ( $zip, @members ) = ( Archive::Zip->new );
        for my $rs_class ( @$run ) {
            if ( _add_member_zip( $zip, "Tarp::Format::File::$rs_class"->new, $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'C'}))) {
                push @members, $rs_class;
                $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'C'})->update({is_dirty => ''});
            }
        }
        push @zips, { zip => $zip, string => join('_', @members) } if ( @members );
    }

    return \@zips;
}


sub updates {
    my $self = shift;
    my ( $zip, @zips, @members ) = ( Archive::Zip->new );

    for my $rs_class ( qw/Accounts Terms Courses Users Sections Enrollments/ ) {
        if ( _add_member_zip( $zip, "Tarp::Format::File::$rs_class"->new, $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'U'})) ) {
          push @members, $rs_class;
          $self->schema->resultset($rs_class)->search_rs({ is_dirty => 'U'})->update({is_dirty => ''});
        }
    }
    push @zips, { zip => $zip, string => join('_', @members) } if ( @members );
    return \@zips;
}

sub _add_member_zip {
    my ( $zip, $format_file, $resultset  ) = @_;
    for my $row ( $resultset->all ) {
        $format_file->add_record( $row->record );
    }
    if ( $format_file->has_records ) {
        my $m = $zip->addString( $format_file->to_string, $format_file->file );
        $m->desiredCompressionMethod(8); ## COMPRESSION_DEFLATED
        return 1;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;
