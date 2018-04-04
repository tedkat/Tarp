#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw/:config no_ignore_case/;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Tarp::Schema;
use DBIx::Class::DeploymentHandler;
 
my ( $help, $dsn, $user, $password, $install, $upgrade, $prepare, $downgrade, $diagram, $verbose, $force, $genkey );
 
GetOptions(
            'help|?'       => \$help,
            'DSN|D=s'      => \$dsn,
            'User|U=s'     => \$user,
            'Password|P:s' => \$password,
            'install|i'    => \$install,
            'upgrade|u'    => \$upgrade,
            'prepare|p'    => \$prepare,
            'downgrade|d'  => \$downgrade,
            'diagram|x'    => \$diagram,
            'verbose|v'    => \$verbose,
            'force|f'      => \$force,
          );
 
pod2usage(1) if $help;    ## print Synopsis and exit(1)
 
if ( $install || $upgrade || $downgrade ) {
    unless ( $dsn && $user ) {
        print STDERR sprintf 'DSN="%s" User="%s" Password="%s"%s DSN AND User are required!', $dsn, $user, $password, "\n";
        pod2usage(2);
    }
}
 
my $schema = Tarp::Schema->connect( $dsn, $user, $password );
 
$ENV{DBICDH_DEBUG} = 1 if ($verbose);
 
my $this_version = $schema->VERSION || die $@;
my $prev_version = $this_version - 1;
 
my $dh = DBIx::Class::DeploymentHandler->new(
                                              {
                                                schema              => $schema,
                                                databases           => [qw/PostgreSQL SQLite/],
                                                script_directory    => "$FindBin::Bin/../_SQL",
                                                sql_translator_args => { add_drop_table => 0 },
                                                force_overwrite     => $force,
                                              }
                                            );
 
if ($prepare) {
    $dh->prepare_install;
    if ( $this_version > 1 ) {
        $dh->prepare_upgrade(
                              {
                                from_version => $prev_version,
                                to_version   => $this_version,
                                version_set  => [ $prev_version, $this_version ],
                              }
                            );
        $dh->prepare_downgrade(
                                {
                                  from_version => $this_version,
                                  to_version   => $prev_version,
                                  version_set  => [ $this_version, $prev_version ],
                                }
                              );
    }
}
elsif ($install) {
    $dh->install;
}
elsif ($upgrade) {
    $dh->upgrade;
}
elsif ($downgrade) {
    $dh->downgrade;
}
else {
    print STDERR "Not prepare, install, upgrade or downgrade\n";
    pod2usage(2);
}
 
exit(0);
 
my $string = <<"HEREDOC";
 
DROP DATABASE IF EXISTS tarp;
 
CREATE DATABASE tarp OWNER tarp_pg;
 
 
HEREDOC
 
=head1 NAME
 
database.pl - Deploy Database for Tarp
 
=head1 SYNOPSIS
 
database.pl -p [ -x ] or ( -D xx -U xx -P xx ( -i or -u or -d ) ) [ -v ]
 
 Options:
   -D --DSN                    DSN to connect to server * required if -i -u -d
   -U --User                   User                     * required if -i -u -d
   -P --Password               Password                 * required if -i -u -d
   -p --prepare                Prepare SQL Deployment Framework
   -i --install                Install Database
   -u --upgrade                Upgrade Database
   -d --downgrade              Downgrade Database
   -v --verbose                Verbose Output
   -f --force                  Force Overwrite ( used with prepare )
   -? --help                   Display Help
 
=head1 DESCRIPTION
 
Setup or Deploy Database for Global Tarp to use
 
=head1 AUTHOR
 
Theodore Katseres
 
=head1 COPYRIGHT
 
This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
 
=cut
