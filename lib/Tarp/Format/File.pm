package Tarp::Format::File
{
    use Moose::Role;
    use namespace::autoclean;

    requires qw/file header key this_record/;

    has csv => ( is => 'ro', builder => '_init_csv', lazy => 1 );

    has records => ( is => 'ro', default => sub { []; }, init_arg => undef );

    sub _init_csv { Text::CSV->new( { escape_char => '"', quote_char => '"', eol => "\n" } ); }

    sub add_record { push @{ $_[0]->records }, $_[1] }

    sub to_string { 
        my $self = shift;

        $self->csv->combine( $self->header );
        
        my $text = $self->csv->string;
        
        for my $record ( $self->records->@* ) {
            $self->csv->combine( $record->to_array_of_columns->@* );
            $text .= $self->csv->string;
        }
        return $text;
    }

    sub has_records { scalar @{ $_[0]->records } }

    sub record {
        my $self = shift;
        my $class = $self->this_record;
        if ( ref( $_[0] ) eq 'HASH' ) {
            return $class->new( %{ $_[0] } );
        }
        else {
            return $class->new( @_ );
        }
    }

    1;

}
