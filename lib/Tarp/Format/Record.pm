package Tarp::Format::Record
{
    use Moose::Role;
    use namespace::autoclean;
    use List::Util 'any';

    has extra => ( is => 'rw', isa => 'HashRef', 'default' => sub { {}; }, lazy => 1 );

    requires qw/columns key/;

    around BUILDARGS => sub {
        my ($orig, $class, %args) = @_;
        my ( @arg, %extra );
        my @h = $class->columns;
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

    sub to_hash_of_columns {
        my $self = shift;
        return {
                    map { $_ => $self->$_ } $self->columns
               };
    }

    sub to_hash {
        my $self = shift;
        return {
                    map { $_ => $self->$_ } ( $self->columns, 'extra' )
               };
    }

    sub to_array_of_columns {
        my $self = shift;
        return [ map { $self->$_ } $self->columns ];
    }

    1;

}
