#!/usr/bin/perl -w

use PPI::Document;

use Data::Dumper;

my $Document = PPI::Document->new('/var/lib/myfrdcsa/codebases/minor/sentinel/scripts/sentinel');
my $sub_nodes = $Document->find
  (
   sub { $_[1]->isa('PPI::Statement') }
  );

foreach my $sub_node (@$sub_nodes) {
  print "<<<".$sub_node->content().">>>\n";
}
