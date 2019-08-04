#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw/:config no_ignore_case/;
use Pod::Usage;
use List::Util 'any';
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::ISO8601;
use Text::CSV;
use IO::String;

## Local Lib
use FindBin;
use lib $FindBin::Bin.'/../lib';
use Tarp;
use Tarp::Export;

## SCRIPT VARS AND COMMANDLINE OPTIONS
my ($DATE, $TYPE, $DEBUG, $LIST, $HELP, $STUDENT, $USER) = ('', '', 0, 0, 0, 0, 0);

GetOptions(
            'help|?'    => \$HELP,
            'type|t=s'  => \$TYPE,
            'list|l'    => \$LIST,
            'student|s' => \$STUDENT,
            'user|u=s'  => \$USER,
            'debug|d'   => \$DEBUG,
            'date=s'    => \$DATE,
          );

if ( $LIST ) {
  print "types are:\n\t", join("\n\t", qw/Enrollments Courses Sections/), "\n";
  exit(1);
}
if ( $DATE ) {
    my $strptime = DateTime::Format::Strptime->new( pattern => '%F', on_error => 'croak' );
    $DATE = $strptime->parse_datetime($DATE);
} else {
    $DATE = DateTime->now;
}

if ( $TYPE ) {
    pod2usage(2) unless any { /$TYPE/ } qw/Enrollments Courses Sections/;
}

pod2usage(1) if $HELP;

## LIBRARY USAGE

my $tarp = Tarp->new( debug => $DEBUG, configfile => $FindBin::Bin . '/../config.json' );
my $export = Tarp::Export->new( schema => $tarp->schema );

my %term_map; # GET Canvas Terms
for my $t ( @{ $tarp->CanvasCloud->api('terms', scheme => $tarp->config->{CanvasCloud}{scheme})->list->{enrollment_terms} } ) {
    if ( exists $t->{sis_term_id} && defined $t->{sis_term_id} ) {
        $term_map{ $t->{sis_term_id} } = $t;
    }
}

my @tarp_terms; # Get Current Tarp Terms which are mapped
for my $t ( $tarp->schema->resultset('Terms')->all ) {
    if ( my $end_dt = DateTime::Format::ISO8601->parse_datetime( $t->end_date ) ) {
        if ( my $start_dt = DateTime::Format::ISO8601->parse_datetime( $t->start_date ) ) {
            if ( $DATE <= $end_dt && $DATE >= $start_dt && exists $term_map{ $t->term_id } ) {
                push @tarp_terms, $t->term_id;
            }
        }
    }
}

## PROGRAM LOGIC
if ( $TYPE ) {
    for my $termid ( @tarp_terms ) {
        if ( $TYPE eq 'Enrollments' ) {
            PostProcess( $TYPE, Enrollments( $termid ) );
        } elsif ( $TYPE eq 'Courses' ) {
            PostProcess( $TYPE, Courses( $termid ) );
        } elsif ( $TYPE eq 'Sections' ) {
            PostProcess( $TYPE, Sections( $termid ) );
        } else { die "$TYPE UNKNOWN!!!\n"; }
    }
} else {
    for my $termid ( @tarp_terms ) {
        PostProcess( 'Enrollments', Enrollments( $termid ) );
        PostProcess( 'Sections', Sections( $termid ) );
        PostProcess( 'Courses', Courses( $termid ) );
    }
}

exit(0);

############## SUBS

sub Courses {
    my $tid = shift;
    my %Return = ( DIFF => [], NotInTarp => [], NotInDownload => [] );
    print STDERR "Courses Term->", $term_map{$tid}{name}, "\n" if ( $DEBUG );
    my $can_report = $tarp->CanvasCloud->api('reports', scheme => $tarp->config->{CanvasCloud}{scheme});
    my $text = $can_report->get( 'sis_export_csv', { 'parameters[enrollment_term_id]' => $term_map{$tid}{id}, 'parameters[courses]' => 1 } );

    return \%Return unless $text;

    my $io = IO::String->new($text);

    my %courses;
    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $io ) );
    while ( my $row = $csv->getline_hr($io) ) {
      $courses{ $row->{course_id} } = $row;
    }

    for my $s ( keys %courses ) {
        if ( my $e = $tarp->schema->resultset('Courses')->find( { course_id => $s } ) ) {
            if ( $e->status ne $courses{$s}{status} ) {
                push @{ $Return{DIFF} }, $e->to_pruned_hash;
                print STDERR "X" if ( $DEBUG ); ## DIFF
            }
            delete $courses{$s};
        }
    }

    for my $s ( keys %courses ) {
        if ( $courses{$s}{status} eq 'active' ) {
            $courses{$s}{status} = 'deleted';
            push @{ $Return{NotInTarp} }, $courses{$s};
            print STDERR 'D' if ( $DEBUG ); ## NotInTarp
        }
    }
    print STDERR "\n" if ( $DEBUG );
    return \%Return;
}

sub Sections {
    my $tid = shift;
    my %Return = ( DIFF => [], NotInTarp => [], NotInDownload => [] );
    print STDERR "Sections Term->", $term_map{$tid}{name}, "\n" if ( $DEBUG );
    my $can_report = $tarp->CanvasCloud->api('reports', scheme => $tarp->config->{CanvasCloud}{scheme});
    my $text = $can_report->get( 'sis_export_csv', { 'parameters[enrollment_term_id]' => $term_map{$tid}{id}, 'parameters[sections]' => 1 } );

    return \%Return unless $text;

    my $io = IO::String->new($text);

    my %sections;
    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $io ) );
    while ( my $row = $csv->getline_hr($io) ) {
      $sections{ $row->{section_id} } = $row;
    }

    for my $s ( keys %sections ) {
        if ( my $e = $tarp->schema->resultset('Sections')->find( { section_id => $s } ) ) {
            if ( $e->status ne $sections{$s}{status} ) {
                push @{ $Return{DIFF} }, $e->to_pruned_hash;
                print STDERR "X" if ( $DEBUG ); ## DIFF
            }
            delete $sections{$s};
        }
    }

    for my $s ( keys %sections ) {
            if ( $sections{$s}{status} eq 'active' ) {
                $sections{$s}{status} = 'deleted';
                push @{ $Return{NotInTarp} }, $sections{$s};
                print STDERR 'D' if ( $DEBUG ); ## NotInTarp
            }
    }
    print STDERR "\n" if ( $DEBUG );
    return \%Return;
}

sub Enrollments {
    my $tid = shift;
    my %Return = ( DIFF => [], NotInTarp => [], NotInDownload => [] );
    print STDERR "Enrollments Term->", $term_map{$tid}{name}, "\n" if ( $DEBUG );
    my $can_report = $tarp->CanvasCloud->api('reports', scheme => $tarp->config->{CanvasCloud}{scheme});
    my $text = $can_report->get( 'sis_export_csv', { 'parameters[enrollment_term_id]' => $term_map{$tid}{id}, 'parameters[enrollments]' => 1 } );
    
    return \%Return unless $text;

    my $io = IO::String->new($text);

    my %sections;
    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $io ) );
    while ( my $row = $csv->getline_hr($io) ) {
        if ( $row->{user_id} ne '' && ( $row->{role} eq 'student' || $row->{role} eq 'teacher' ) ) {
            next if ( $STUDENT && $row->{role} eq 'teacher' );  ## Student only flag skip teacher
            next if ( $USER && $row->{user_id} ne $USER );      ## User only flag
            $sections{ $row->{section_id} }{ $row->{user_id} } = $row;
        }
    }

    for my $s ( keys %sections ) {
        my $enroll_rs;
        ## Different query based on STUDENT flag
        if ( $STUDENT ) {
            $enroll_rs = $tarp->schema->resultset('Enrollments')->search_rs( { c_role => 'student', section_id => $s } );
        } elsif ( $USER ) {
            $enroll_rs = $tarp->schema->resultset('Enrollments')->search_rs( { user_id => $USER, section_id => $s } );
        } else {
            $enroll_rs = $tarp->schema->resultset('Enrollments')->search_rs( { section_id => $s } );
        }
        
        for my $e ( $enroll_rs->all ) {
            if ( exists $sections{$s}{$e->user_id} ) {
                if ( $e->status ne $sections{$s}{$e->user_id}{status} ) {
                    push @{ $Return{DIFF} }, $e->to_pruned_hash;
                    print STDERR "X" if ( $DEBUG ); ## DIFF
                }
            }
            else {
                if ( $e->status eq 'active' ) { #ignore deleted status if not in download
                    push @{ $Return{NotInDownload} }, $e->to_pruned_hash;
                    print STDERR 'T' if ( $DEBUG ); ## NotInDowload
                }
            }
            delete $sections{$s}{$e->user_id};
        }

        for my $e ( keys %{ $sections{$s} } ) {
            if ( $sections{$s}{$e}{status} eq 'active' ) {
                $sections{$s}{$e}{status} = 'deleted';
                push @{ $Return{NotInTarp} }, $sections{$s}{$e};
                print STDERR 'D' if ( $DEBUG ); ## NotInTarp
            }
        }
    }
    print STDERR "\n" if ( $DEBUG );
    return \%Return;
}

sub PostProcess {
    my $type  = shift;
    my $recon = shift;

    for my $state ( qw/NotInTarp NotInDownload DIFF/ ) {
        if ( exists $recon->{$state} && ref( $recon->{$state} ) eq 'ARRAY' ) {
            if ( @{ $recon->{$state} } ) {
                my $zip = $export->raw( $type, $recon->{$state} );
                if ( $zip->members ) {
                    $zip->writeToFileNamed("$state.zip") if ( $DEBUG );
                    $tarp->send_zips( [ { zip => $zip, string => $state } ], 'reconcile' );
                }
            }
        }
        else {
            die "->reconcile state:$state ( returned unexpected Results )!\n";
        }
    }
}

exit 0;


=head1 NAME

reconsile_with_cloud.pl - Reconcile Cloud Tarp with Local Tarp

=head1 SYNOPSIS

reconsile_with_cloud.pl (@options)

 Options:
  -t --type  "TYPE"           set type to reconcile
  -l --list                   list reconcile types
  -s --student                only process students
  -u --user "[USERID]"        only process user
  -d --debug                  set debug
     --date  "2002-01-01"     override today's date with this date
  -? --help                   Display Help

=head1 DESCRIPTION

Check Cloud Canvas and diff to local creating and sending changes file back to cloud.

=head1 AUTHOR

Theodore Katseres

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
