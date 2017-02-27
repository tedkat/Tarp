package Tarp::Utils::Format {
use Moose::Role;
use namespace::autoclean;
use List::Util qw/any/;
use Text::CSV;

has extra => ( is => 'rw', isa => 'HashRef', 'default' => sub { {}; }, lazy => 1 );

requires 'header', 'file';

around BUILDARGS => sub {
    my ($orig, $class, %args) = @_;
    my ( @arg, %extra );
    my @h = $class->header;
    for my $k ( keys %args ) {
        if ( any { $_ eq $k } @h ) {
            push @arg, $k, $args{$k};
        }
        else {
            $extra{$k} = $args{$k};
        }
    }
    return $class->$orig( @arg, extra => \%extra ) if ( %extra );
    return $class->$orig( @arg );
};

sub csv_header {
    my $self = shift;
    my $csv = Text::CSV->new( { escape_char => '"', quote_char => '"', eol => "\n" } );
    $csv->combine( map { $_ } $self->header );
    return $csv->string;
}

sub to_csv {
    my $self = shift;
    my $csv = Text::CSV->new( { escape_char => '"', quote_char => '"', eol => "\n" } );
    $csv->combine( map { $self->$_ } $self->header );
    return $csv->string;
}

sub to_hash {
    my $self = shift;
    return { map { $_ => $self->$_ } $self->header };
}

1;
}
