package FRDCSA::IAEC::PurePerl::Sentinel;

# we need to split this into function slices, like as used with Sayer
# in Capability::TextAnalysis


#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use System::ExtractAbbrev;
use UniLang::Util::TempAgent;

use File::ChangeNotify;

$specification = q(
	-f <file>		Run as a one off analyzing a PDF file
	-k			Use KBFS
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $agent = UniLang::Util::TempAgent->new();

my $HOME = $ENV{HOME};

my $abbrev = System::ExtractAbbrev->new();

if (! exists $conf->{'-f'}) {
  my $tmpdirectories =
    [
     "$HOME/incoming",
     "/var/lib/myfrdcsa/codebases/internal/digilib/data/collections/manuals",
     "$HOME",
     "$HOME/Downloads",
     "$HOME/ocr-output",
     "$HOME/asr-output",
     "$HOME/Documents",
     "/var/lib/myfrdcsa/codebases/minor/nlu/systems/mf/formalization-queue",
     "/var/lib/myfrdcsa/codebases/internal/digilib/data/wgetcache",
    ];

  my $directories;
  foreach my $dir (@$tmpdirectories) {
    if (-d $dir) {
      push @$directories, $dir;
    }
  }

  print Dumper($directories);

  my $watcher = File::ChangeNotify->instantiate_watcher
    (
     directories => $directories,
     filter      => qr/\.(?:pdf|PDF|tar.gz|tgz|TGZ|tar.bz2)$/,
    );

  my @allcommands = ();
  while ( my @events = $watcher->wait_for_events() ) {
    my @commands = ();
    print Dumper({Events => \@events});
    foreach my $event (@events) {
      # bless( {
      #          'type' => 'create',
      #          'path' => '/home/andrewdo/WS02-11-010.pdf'
      #        }, 'File::ChangeNotify::Event' ),
      if ($event->type eq 'create') {
	my $file = $event->path;
	if ($file =~ /\.pdf$/i) {
	  sleep 3;
	  push @commands, ProcessPDFFile(PDFFile => $file);
	} elsif ($file =~ /(\.tar\.gz|tgz|\.tar\.bz2)$/i) {
	  sleep 3;
	  push @commands, ProcessSoftwareArchiveFile(File => $file);
	}
      }
    }
    # ask the user if they want to execute these commands
    print Dumper({Commands => \@commands});
  }
} elsif (exists $conf->{'-f'}) {
  ProcessPDFFile(PDFFile => $conf->{'-f'});
}

sub Chase {
  my (%args) = @_;
  my $c = 'chase '.shell_quote($args{File});
  my $res1 = `$c`;
  chomp $res1;
  return $res1;
}

sub ProcessPDFFile {
  my (%args) = @_;
  my @commands;

  my $pdffile = $args{PDFFile};
  my $qpdffile = shell_quote($pdffile);
  my $chasedfile = Chase(File => $pdffile);
  my $txtfile = $pdffile;
  $txtfile =~ s/\.pdf$/\.txt/i;
  my $qtxtfile = shell_quote($txtfile);


  my $docid = -1;
  if ($conf->{'-k'}) {
    my $m = $agent->MyAgent->QueryAgent
      (
       Receiver => $args{Agent} || 'KBFS-Agent1',
       Data => {
		Eval => [['_prolog_list',['_prolog_list',\*{'::FileIDs'}],['retrieveFileIDs',$chasedfile,\*{'::FileIDs'},'Org::FRDCSA::Sentinel::KBFS']]],
	       },
      );
    print Dumper({M => $m});
    my $list = $m->{Data}{Result}[1][1];
    print Dumper({List => $list});
    shift @$list;
    $docid = $list->[0];
  }

  system 'pdftotext '.$qpdffile;
  my $command = 'extract-links.pl -p -i '.$qtxtfile.' 2> /dev/null';
  print $command."\n";
  my $dumper = `$command`;
  print $dumper;
  my $links = DeDumper($dumper);

  if ($conf->{'-k'}) {
    my $term = ['hasLinks',['file',$docid],['_prolog_list',@$links]];
    # from: /var/lib/myfrdcsa/codebases/internal/clear/Clear/Doc.pm
    my $res0 = $agent->MyAgent->QueryAgent
      (
       Receiver => 'KBS2',
       Data => {
		_DoNotLog => 1,
		Command => 'assert',
		Formula => $term,
		Method => 'MySQL',
		Database => 'freekbs2',
		Context => 'Org::FRDCSA::Sentinel::KBFS::DocData',
		Asserter => 'guest',
		# Quiet => undef,
		# OutputType => undef,
		Flags => {
			  # AssertWithoutCheckingConsistency => 1,
			 },
		Data => $args{Data},
		Type => $args{Type},
		Force => $args{Force},
	       },
      );
    print Dumper(Res0 => $res0);
  }

  push @commands, ProcessPDFFileLinks
    (
     DocID => $docid,
     Links => $links,
    );
  # things to extract:

  my $command2 = '/var/lib/myfrdcsa/codebases/minor/academician/scripts/process-parscit-results.pl -f '.$qpdffile.' -o -p -t '.$qtxtfile;
  print $command2."\n";
  my $res1 = `$command2`;
  my $data = DeDumper($res1);
  print Dumper({Authors => $data->{algorithm}{'ParsHed'}{variant}{author}});
  print Dumper({Emails => $data->{algorithm}{'ParsHed'}{variant}{email}});

  my $emails = `/var/lib/myfrdcsa/codebases/internal/perllib/scripts/extract-emails.pl -i $qtxtfile`;
  print $emails."\n";

  my $text = read_file($txtfile);
  my $abbrevs = $abbrev->ExtractAbbrev(Text => $text);
  print Dumper({Abbrevs => $abbrevs});

  if (0) {
    # try to extract emails legitimately, but if can't try to extract
    foreach my $line (split /\n/, $res1) {
      if ($line =~ /\@/) {
	push @possibleobfuscatedemails, $line;
      }
    }
    print Dumper({Emails => \@possibleobfuscatedemails});
  }
  # system name
  # authors names, institutions and email address
  # links in the paper
  # extract abbreviations

  # fixme, write a version of extract links that takes care of the
  # oddities of pdftotext links

  # now with this run extract-links.pl, then feed to radar.  store
  # them.  get author information, if we can't find their code,
  # set up an email to ask for it.

  return \@commands;
}

sub ProcessPDFFileLinks {
  my (%args) = @_;
  my $links = $args{Links};
  print Dumper
    ({
      Links => $links,
     });
  my @commands;
  foreach my $link (@$links) {
    if ($link =~ /^https?:\/\/github.com\/([^\/]+)\/([^\/]+)/ or
	$link =~ /\.git$/ or
	$link =~ /\.(tar.gz|tgz)$/) {
      push @commands, 'radar -y '.shell_quote($link);
    }
  }
  return \@commands;
}

sub ProcessSoftwareArchiveFile {
  my (%args) = @_;
  my @commands;
  push @commands, 'packager -y -l '.shell_quote($args{File});
  return \@commands;
}
