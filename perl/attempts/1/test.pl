#!/usr/bin/perl -w

# some things that need to be done - YASWI is too slow here.  We need
# pengines integration, but that's blocking on this issue:
# https://github.com/simularity/JavaPengine/issues/3

# also our persistence is not very fast, maybe use data-integration
# SWIPL MySQL ODBC integration to be faster, need to finish that

# go through each file and directory

# prove things that are true about it

foreach my $filename (split /\n/, `ls ~/`) {
  print "<$filename>\n";
  Analyze
    (
     Data => '/home/andrewdo/Users_Interest_from_Social_Networks_SIGIR19.pdf',
     Metadata => [
		  ['isa',Var('?DataPoint'),'filename'],
		  ['fileContains',['fileFn',Var('?DataPoint')],'researchPaper'],
		 ],
    );
}

# have type prerequisites on tests
# have expected timing on tests, worst-case, etc
# have composite tests

# have multiple answer types

my $tests =
  {
   "FileTests" => {
		   isFileP => {
			       Sub => sub { -f $_[0] },
			       Type => "boolean",
			      },
		   isDirectoryP => {
			      Sub => sub { -d $_[0] },
			      Type => "boolean",
			     },
		   executableFileP => {
			       Sub => sub { -x $_[0] },
			       Type => "boolean",
			      },
		  },
  };

my $knowledge = [
		 "(implies (or (IsFileP ?X) (IsDirP ?X)) (ExistsP ?X))",
		 "(implies (FilenameP ?X) (and (propose-test IsDirectoryP ?X) (propose-test DirTest ?X)))",
		 "(implies (IsDirP ?X) (queue-test DirTest ?X))",
		];

# propose tests

sub GenerateAssertions {
  my %args = @_;
  my @assertions;
  # run tests

  foreach my $testsuite (keys %$tests) {
    foreach my $test (keys %{$tests->{$testsuite}}) {
      my $sub = $tests->{$testsuite}->{$test};

      # if the test is a binary test, use those results
      $sub->($args{Item})
    }
  }
}


