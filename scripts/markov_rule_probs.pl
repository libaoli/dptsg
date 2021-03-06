#!/usr/bin/perl

# reads in a corpus and counts events.

my $basedir;
BEGIN {
  $basedir = $ENV{DPTSG};
  unshift @INC, $basedir;
}

use strict;
use warnings;
use threads;
use List::Util qw|reduce min max sum|;
use TSG;

my %PARAMS = (
  alpha => 10,  # DP parameter
  iters => 500,  # number of iterations
  stop => 0.9, # stop prob for base geometric distribution
  log => 0,
  lexicon => "$basedir/data/lex.02-21",
  pcfg => "$basedir/data/pcfg_rules.prb",
  deps => 0,   # use dependences
  headed_rule => 0.9, 
  corpus => "$basedir/data/wsj.trees.02-21.clean",
  rundir => $ENV{PWD},
  srand => undef,
  verbosity => 1 
);

process_params(\%PARAMS,\@ARGV,\%ENV);
my $lexicon = read_lexicon($PARAMS{lexicon},$PARAMS{thresh});

my (%widths,%pairs);
while (my $line = <>) {
  chomp($line);
  
  my $tree = build_subtree($line,$lexicon);

  my $func = sub {
    my ($node) = @_;

    return if islex($node->{label});

    # count number of children
    my $numkids = scalar @{$node->{children}};
    $widths{$node->{label}}{$numkids}++;

    # count all nonterminals seen below
    my $find_pairs = sub {
      my ($child_node) = @_;
      $pairs{$node->{label}}{$child_node->{label}}++;
          # unless islex($child_node->{label});
    };
    map { walk($_,[$find_pairs]) } @{$node->{children}};
  };
  walk($tree,[$func]);
}

foreach my $key (keys %pairs) {
  # fit a geometric distribution across the number of children
  my $n = sum values %{$widths{$key}};
  my $sum = sum (map { $_ * $widths{$key}{$_} } keys %{$widths{$key}});
  my $stop_prob = 1.0 * $n / $sum;

  my $num_kids = sum values %{$pairs{$key}};
  
  print "$key $stop_prob $num_kids";
  map { print " $_ $pairs{$key}{$_}" } sort { $pairs{$key}{$b} <=> $pairs{$key}{$a} } keys %{$pairs{$key}};
  print $/;
}
