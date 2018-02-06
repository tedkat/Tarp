use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Tarp;
use Path::Tiny;
use JSON;

## Testing 
use Test::Tarp;
my $testtarp = Test::Tarp->new( SQL => "$FindBin::Bin/../_SQL" );

my $http = $testtarp->http;

## Used tested elseware
use Tarp::Import;

## THIS CLASS TEST
use_ok( 'Tarp' );

## Setup Moc ConfigFile
my $config = {
    database => { "dsn"=> "dbi:SQLite:dbname=:memory:", "user"=> "", "password"=> "" },
    CanvasCloud => { 
                        "domain"=> "localhost:".$http->server->port,
                        scheme => 'http',
                        token => "daspo__STRING_SOUP_IS_GOOD_FOOD_0*U2!EF",
                        account_id => "1"
                   }
};
$testtarp->configfile->spew( to_json( $config ) );

## ##

ok my $tarp = Tarp->new( configfile => $testtarp->configfile, schema => $testtarp->schema ), 'Create Tarp Object';

my $tarp_import = Tarp::Import->new(
                                        Accounts    => sub { [] },
                                        Terms       => sub { [] },
                                        Courses     => sub { [] },
                                        Users       => sub { [] },
                                        Sections    => sub { [] },
                                        Enrollments => sub { [] },
                                        schema      => $testtarp->schema
                                   );

ok $tarp->push_changes( $tarp_import ), 'Push No Changes'; ## nothing todo here

$tarp_import = Tarp::Import->new(
                                        Accounts    => sub { $testtarp->accounts_data },
                                        Terms       => sub { $testtarp->terms_data },
                                        Courses     => sub { $testtarp->courses_data },
                                        Users       => sub { $testtarp->users_data },
                                        Sections    => sub { $testtarp->sections_data },
                                        Enrollments => sub { $testtarp->enrollments_data },
                                        schema      => $testtarp->schema
                                );

## 

$http->set_sis_imports(q/{ "id": 1, "workflow_state": "imported", "progress": "100" }/);

ok $tarp->push_changes( $tarp_import ), 'Push Changes';

done_testing();
