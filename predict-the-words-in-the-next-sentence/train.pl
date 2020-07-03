#!/usr/bin/perl -w

# figure out what causes this error:
# Can't bless non-reference value at /usr/local/share/perl/5.20.1/Class/Container.pm line 53.
# on
# /media/andrewdo/backup/minor-data/workhorse/data-ai/complete/arabian-nights/xay.workhorse.knext.dat
# /var/lib/myfrdcsas/versions/myfrdcsa-1.1/vagrant-machines/NLP-FRDCSA-Org/NLP2-Workhorse-FRDCSA-Org/data/workhorse/data-ai/complete/arabian-nights/xay.workhorse.knext.dat

use BOSS::Config;
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use AI::Categorizer;
use AI::Categorizer::FeatureSelector;
use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Learner::SVM;

$specification = q(
	--svm		Use SVM
	--bayes		Use Bayes
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/iaec";

my $learner;
if ($conf->{'--svm'}) {
  $learner = AI::Categorizer::Learner::SVM->new();
} elsif ($conf->{'--bayes'}) {
  $learner = AI::Categorizer::Learner::NaiveBayes->new();
}

my $id = 1;
my $verbose = 0;
my $n = 3;

sub Train {
  my $deep = 0;
  my $c;
  if ($deep) {
    $c = `locate -r '\.knext\.dat$$'`;
  } else {
    # my $c = `locate -r '\.knext\.dat$$' | head -n 10`;
    $c = read_file('knext-dat.txt');
  }
  my %hascategory;
  my @allcategories;
  my @documents;
  my @allfiles = split /\n/, $c;
  my @files;
  if ($deep) {
    @files = @allfiles;
  } else {
    @files = splice @allfiles, 0, 100;
  }
  foreach my $file (@files) {
    if (-f $file) {
      print "File: <$file>\n";
      my $data = read_file_dedumper($file);
      my @window;
      my $lastcleanedsentence;
      foreach my $entry (@$data) {
	if (exists $entry->{Sentence}) {
	  my $sentence = $entry->{Sentence};
	  $sentence =~ s/^\((.+)\)$/$1/;
	  $sentence = lc($sentence);
	  my $length = scalar @window;
	  my @sentence;
	  if ($length >= $n) {
	    my $hash = {};
	    my @categories;
	    foreach my $categoryname (split /\s+/, $sentence) {
	      if ($categoryname =~ /^[a-z]+$/) {
		$hash->{$categoryname}++;
		if (! exists $hascategory{$categoryname}) {
		  my $cat = AI::Categorizer::Category->by_name(name => $categoryname);
		  $hascategory{$categoryname} = $cat;
		  push @allcategories, $cat;
		}
		push @categories, $hascategory{$categoryname};
		push @sentence, $categoryname;
	      }
	    }
	    my $doc = join("\n", @window);
	    my $cleanedsentence = join(' ', @sentence);
	    if ($cleanedsentence ne $lastcleanedsentence) {
	      $lastcleanedsentence = $cleanedsentence;
	      print " <<<Doc: $doc>>>\n <<<Sen: $cleanedsentence>>>\n\n" if $verbose;
	      my $d = AI::Categorizer::Document->new
		(
		 name => "doc-".$id++,
		 content => $doc,
		 categories => \@categories,
		);
	      push @documents, $d;
	      shift @window;
	    } else {
	      @window = ();
	    }
	  }
	  my $cleanedsentence;
	  if (! scalar @sentence) {
	    foreach my $categoryname (split /\s+/, $sentence) {
	      if ($categoryname =~ /^[a-z]+$/) {
		push @sentence, $categoryname;
	      }
	    }
	  }
	  push @window, join(' ', @sentence);
	} else {
	  @window = ();
	}
      }
    }
  }

  # print Dumper
  #   ({
  #     Documents => \@documents,
  #     Categories => \@allcategories,
  #    });

  my $fs = AI::Categorizer::FeatureSelector->new(features_kept => 0.3, verbose => 1);
  my $k = AI::Categorizer::KnowledgeSet->new
    (
     documents => \@documents,
     categories => \@allcategories,
     feature_selector => $fs,
     # tfidf_weighting => 'tpc',
    );

  # print Dumper($k);
  # $learner->scan_features;
  # $learner->read_training_set;
  $learner->train(knowledge_set => $k);
  # $learner->evaluate_test_set;
  if ($conf->{'--svm'}) {
    $extra = 'svm';
  } elsif ($conf->{'--bayes'}) {
    $extra = 'bayes';
  }

  $learner->save_state(ConcatDir($UNIVERSAL::systemdir,'data-git',"sentence-prediction-model-$extra.dat"));
}

Train();
