#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use AI::Categorizer;
use AI::Categorizer::FeatureSelector;
use AI::Categorizer::Learner::NaiveBayes;
use AI::Categorizer::Learner::SVM;
use Algorithm::NaiveBayes::Model::Frequency;
# use Algorithm::SVM::Model::Frequency;

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
  $learner = AI::Categorizer::Learner::SVM->restore_state
    (ConcatDir($UNIVERSAL::systemdir,'data-git',"sentence-prediction-model-svm.dat"));
} elsif ($conf->{'--bayes'}) {
  $learner = AI::Categorizer::Learner::NaiveBayes->restore_state
    (ConcatDir($UNIVERSAL::systemdir,'data-git',"sentence-prediction-model-bayes.dat"));
}

my $id = 1;
my $verbose = 1;
my $n = 3;

use PerlLib::ToText;
use Rival::Lingua::EN::Sentence qw(get_sentences);

my $totext = PerlLib::ToText->new();

sub Predict {
  # my $c = `locate -r '\.knext\.dat$$' | head -n 10`;
  my @hypotheses;
  my @allcategories;
  foreach my $file (split /\n/, `find /var/lib/myfrdcsa/codebases/minor/iaec/predict-the-words-in-the-next-sentence/temp`) {
    print "<$file>\n";
    my $res1 = $totext->ToText(File => $file);
    if ($res1->{Success}) {
      my $data = get_sentences($res1->{Text});
      my @window;
      my $lastcleanedsentence;
      foreach my $sentence (@$data) {
	if (1) {
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
	      print " <<<Doc: $doc>>>\n <<<Sen: $cleanedsentence>>>\n" if $verbose;
	      my $d = AI::Categorizer::Document->new
		(
		 name => "doc-".$id++,
		 content => $doc,
		 categories => \@categories,
		);
	      my $h = $learner->categorize($d);
	      my @top = sort {$h->{scores}{$b} <=> $h->{scores}{$a}} keys %{$h->{scores}};
	      my @best = splice @top,0,15;
	      print " <<<Act: ";
	      my $matches = {};
	      my $nonmatches = {};
	      foreach my $cat (@best) {
		if (exists $hash->{$cat}) {
		  $matches->{$cat} = 1;
		} else {
		  $nonmatches->{$cat} = 1;
		}
		print "$cat ".sprintf("%1.2f",$h->{scores}{$cat}).', ';
	      }
	      print "\n";
	      print 'Matches: '.join(' ',keys %$matches)."\n";
	      print 'NonMatc: '.join(' ',keys %$nonmatches)."\n";
	      print "\n\n";
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
}

Predict();
