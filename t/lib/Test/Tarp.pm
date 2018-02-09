package Test::Tarp::Http {
    use Moose;
    use namespace::autoclean;
    use Path::Tiny;
    use Plack::App::Directory;
    use Plack::Test::Server;

    has directory => ( is => 'ro', default => sub { Path::Tiny->tempdir } );
    has static => ( is => 'ro', writer => '_static' );
    has server => ( is => 'ro', writer => '_server' );
    sub BUILD {
        my $self = shift;
        $self->_static( Plack::App::Directory->new( root => ''.$self->directory )->to_app );
        $self->_server( Plack::Test::Server->new($self->static) );
        #warn $self->server->port;
        #warn $self->directory;
    }

    sub set_sis_imports {
        my $self = shift;
        my $json = shift || '{}';
        my $imports = $self->directory->child(qw/api v1 accounts 1/, 'sis_imports.json')->touchpath;
        $imports->spew($json);
        $imports = $self->directory->child(qw/api v1 accounts 1/, 'sis_imports', '1.json')->touchpath;
        $imports->spew($json);
    }

    Test::Tarp::Http->meta->make_immutable;
    1;
};

package Test::Tarp;
use Moose;
use namespace::autoclean;

use FindBin;
use DBIx::Class::DeploymentHandler;
use Tarp::Schema;
use Text::CSV;

has 'SQL'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'schema'     => ( is => 'ro', isa => 'DBIx::Class', builder => '_schema', lazy => 1 );
has 'configfile' => ( is => 'ro', default => sub { Path::Tiny->tempfile( 'configjsonXXXXXXX' ) }, lazy => 1 );
has 'http'       => ( is => 'ro', default => sub { Test::Tarp::Http->new }, lazy => 1 );

sub _schema {
    my ( $self ) = @_;
    my $schema = Tarp::Schema->connect( 'dbi:SQLite:dbname=:memory:', '', '' );

    my $dh = DBIx::Class::DeploymentHandler->new(
                                                  {
                                                      schema              => $schema,
                                                      databases           => [qw/PostgreSQL SQLite/],
                                                      script_directory    => $self->SQL,
                                                      sql_translator_args => { add_drop_table => 0 }
                                                  }
                                                );
    $dh->install;
    return $schema;
}

sub to_csv_file_string {
    my $self = shift;
    my $arrayref = shift;
    my %columns;
    my $string;
    for my $r ( @{ $arrayref } ) {
        for my $k ( keys %{ $r } ) {
            $columns{$k} = 1;
        }
    }
    my $csv = Text::CSV->new;
    $csv->combine( sort keys %columns );
    $string .= $csv->string . "\n";
    for my $r ( @{ $arrayref } ) {
        my @cols;
        for my $k ( sort keys %columns ) {
            my $this_col = '';
            $this_col = $r->{$k} if ( exists $r->{$k} );
            push @cols, $this_col;
        }
        $csv->combine(@cols);
        $string .= $csv->string . "\n";
    }
    return $string;
}

sub accounts_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'accountsXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->accounts_data ) );
    return $file;
}

sub accounts_data {
    my $self = shift;

    return [
              { account_id => 1, name => 'Account 1', status => 'active', is_primary => 1 },
              { account_id => 2, name => 'Account 2', status => 'active', parent_account_id => 1 },
              { account_id => 3, name => 'Account 3', status => 'active', parent_account_id => 1 },
              { account_id => 4, name => 'Account 4', status => 'active', parent_account_id => 1 }
    ];
}

sub terms_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'termsXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->terms_data ) );
    return $file;
}

sub terms_data {
    my $self = shift;
    return [
            { term_id => 1, name => 'Term 1', status => 'active', start_date => '1971-01-01T00:00:00Z', is_primary => 1 },
            { term_id => 2, name => 'Term 2', status => 'active', start_date => '1972-01-01T00:00:00Z' },
            { term_id => 3, name => 'Term 3', status => 'active', start_date => '1973-01-01T00:00:00Z' },
    ];
}

sub users_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'usersXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->users_data ) );
    return $file;
}

sub users_data {
    my $self = shift;
    return [
            { user_id => 1, login_id => 'ONE',   status => 'active', is_primary => 1, sortable_name => '1' },
            { user_id => 2, login_id => 'TWO',   status => 'active', is_primary => 0, sortable_name => '2'  },
            { user_id => 3, login_id => 'THREE', status => 'active', is_primary => 0, sortable_name => '3'  },
    ];
}

sub courses_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'coursesXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->courses_data ) );
    return $file;
}

sub courses_data {
    my $self = shift;
    return [
                { course_id => 1, short_name => 'CRS1', long_name => 'Course One', status => 'active', account_id => 2, foo => 'is_course' },
                { course_id => 2, short_name => 'CRS2', long_name => 'Course Two', status => 'active', account_id => 2, foo => 'is_course' },
                { course_id => 3, short_name => 'CRS3', long_name => 'Course Three', status => 'active', account_id => 2, foo => 'is_course' },
                { course_id => 11, short_name => 'CRS1', long_name => 'Course One', status => 'active', account_id => 3, foo => 'is_course',   x => 'is_a3' },
                { course_id => 12, short_name => 'CRS2', long_name => 'Course Two', status => 'active', account_id => 3, foo => 'is_course',   x => 'is_a3' },
                { course_id => 13, short_name => 'CRS3', long_name => 'Course Three', status => 'active', account_id => 3, foo => 'is_course', x => 'is_a3' },
    ];
}

sub sections_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'sectionsXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->sections_data ) );
    return $file;
}

sub sections_data {
    my $self = shift;
    return [
            { section_id => 11, course_id => 1, name => 'Course 1 Section 1', status => 'active', is_primary => 1  },
            { section_id => 12, course_id => 1, name => 'Course 1 Section 2', status => 'active', is_primary => 1  },
            { section_id => 13, course_id => 1, name => 'Course 1 Section 3', status => 'active', is_primary => 1  },
            { section_id => 21, course_id => 2, name => 'Course 2 Section 1', status => 'active', is_primary => 0  },
            { section_id => 22, course_id => 2, name => 'Course 2 Section 2', status => 'active', is_primary => 0  },
            { section_id => 23, course_id => 2, name => 'Course 2 Section 3', status => 'active', is_primary => 0  },
    ];
}

sub enrollments_data_file {
    my $self = shift;
    my $file = Path::Tiny->tempfile( 'enrollmentsXXXXXXX' );
    $file->spew( $self->to_csv_file_string( $self->enrollments_data ) );
    return $file;
}

sub enrollments_data {
    my $self = shift;
    return [
            { user_id => 1, status => 'active', section_id => 11, role => 'student', is_primary => 1 },
            { user_id => 1, status => 'active', section_id => 12, role => 'student', is_primary => 1 },
            { user_id => 1, status => 'active', section_id => 13, role => 'student', is_primary => 1 },
            { user_id => 1, status => 'active', section_id => 21, role => 'student', is_primary => 1 },
            { user_id => 1, status => 'active', section_id => 22, role => 'student', is_primary => 1 },
            { user_id => 1, status => 'active', section_id => 23, role => 'student', is_primary => 1 },
            { user_id => 2, status => 'active', section_id => 11, role => 'student', is_primary => 0 },
            { user_id => 2, status => 'active', section_id => 12, role => 'student', is_primary => 0 },
            { user_id => 2, status => 'active', section_id => 13, role => 'student', is_primary => 0 },
            { user_id => 2, status => 'active', section_id => 21, role => 'student', is_primary => 0 },
            { user_id => 2, status => 'active', section_id => 22, role => 'student', is_primary => 0 },
            { user_id => 2, status => 'active', section_id => 23, role => 'student', is_primary => 0 },

    ];
}

__PACKAGE__->meta->make_immutable;

1;
