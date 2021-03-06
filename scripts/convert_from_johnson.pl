#!/usr/bin/perl

my $basedir;
BEGIN {
  $basedir = $ENV{DPTSG};
  unshift @INC, $basedir;
}

use strict;
use warnings;
use TSG;

# load the map

my %PARAMS = (
  'map' => undef,     # map file
  'scrub' => 1,       # remove asterisks denoting TSG derivation
  'delex' => 1,       # removes underscores around terminals
);
process_params(\%PARAMS,\@ARGV,\%ENV);

my %rule_mapping;

my $map_file = $PARAMS{map};
open READ, $map_file or die "can't open map file '$map_file'";
while (my $line = <READ>) {
  chomp($line);
  my ($flat,$full) = split(/ \|\|\| /,$line);
  
  $rule_mapping{$flat} = $full;
}
close READ;

# subtree-internal nodes MUST be annotated to prevent an infinite
# amount of recursion; for example, consider the rule 
#   NP-4 -> @NP-2 DT-0
# mapping to
#   NP-4 -> (NP-4 (*NP-4 @NP-2 DT-0))
# if the internal NP-4 is not marked, then the recursive call will
# result in infinite expansion
my $annotate = 1;

my (%rules,%map);

while (my $line = <>) {
  chomp($line);
  if ($line eq "(TOP)") {
    print "(TOP)\n";
    next;
  }

  my $tree = build_subtree($line);

  walk($tree,[\&unbinarize]);

  walk($tree,[\&unflatten]);

  walk($tree,[\&remove_mark])
    if ($PARAMS{scrub});

  print build_subtree_oneline($tree,$PARAMS{delex}), $/;
}

sub substitute_subtree {
  # node is the current node in the subtree, and nodes is the list of
  # nodes yest to be matched with the leaves of the subtree node is a
  # part of
  my ($node,$nodes,$isroot) = @_;
  $isroot = 1 unless defined $isroot;

  if ($annotate) {
    $node->{label} = "*" . $node->{label} unless $isroot;
  }

  my $numkids = @{$node->{children}};

#   print "  SUB($node->{label},[", join(" ",map{$_->{label}}@$nodes), "]) $numkids kids\n";

  for my $k (0..$#{$node->{children}}) {
    my $kid = @{$node->{children}}[$k];
    if ($kid->{numkids} == 0) {
      my $repl = shift @$nodes;
#         print "   SUBBING $kid->{label} = $repl->{label}\n";
      @{$node->{children}}[$k] = $repl;
    } else {
      substitute_subtree($kid,$nodes,0);
    }
  }

  return $node;
}

sub unbinarize {
  my ($node) = @_;

  # if the node has any kids, see if they need to be unbinarized
  if (@{$node->{children}}) {
	my $kidno = 0;
	for (;;) {
	  my $kid = @{$node->{children}}[$kidno];

	  # if the kid needs to be unbinarized, do it, and don't increment
	  # the index, since we might have to recursively consider the
	  # grandkid that replaced the kid; otherwise, we do increment
	  if ($kid->{label} =~ /^</) {
		splice(@{$node->{children}},$kidno,1,@{$kid->{children}});
	  } else {
		$kidno++;
	  }

	  last if $kidno >= @{$node->{children}};
	}
  }
}

sub unflatten {
  my ($node) = @_;

  if ($node->{children}) {

    my $rule = "$node->{label} --> " . join(" ",map {$_->{label}} @{$node->{children}});

    if (exists $rule_mapping{$rule}) {
      my $full_rule = $rule_mapping{$rule};

      my $subtree = build_subtree($full_rule);
      my @kids = @{$node->{children}};
      substitute_subtree($subtree,\@kids);
      $node->{children} = $subtree->{children};
    }
  }
}

# removes markings denoting internal nodes
sub remove_mark {
  my ($node) = @_;

  $node->{label} =~ s/^\*//;
}
