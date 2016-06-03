package Test::Tarp;
use Moose;
use namespace::autoclean;

use FindBin;
use DBIx::Class::DeploymentHandler;
use Tarp::Schema;

has 'SQL'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'schema' => ( is => 'ro', isa => 'DBIx::Class', builder => '_schema', lazy => 1 );

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

sub accounts_data {
    my $self = shift;

    return(
              { account_id => 1, name => 'ZZZ', status => 'active' },
              { account_id => 2, name => 'AAA', status => 'active' },
              { account_id => 3, name => 'BBB', status => 'active' },
              { account_id => 4, name => 'CCC', status => 'active' }
          );
}

__PACKAGE__->meta->make_immutable;

1;
