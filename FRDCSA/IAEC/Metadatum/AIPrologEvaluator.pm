package FRDCSA::IAEC::Metadatum::AIPrologEvaluator;

use FRDCSA::IAEC::Metadatum;

use KBS2::ImportExport;
# KBS2::ImportExport::Mod::AIProlog

use AI::Prolog;
use Clone qw(clone);
use Data::Dumper;


use base 'FRDCSA::IAEC::Metadatum::Evaluator';

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyImportExport(KBS2::ImportExport->new);
}

sub CheckMetadatumPrecondition {
  my ($self,%args) = @_;
  my $res1 = $self->MyImportExport->Convert
    (
     Input => $args{Metadatum},
     InputType => 'Interlingua',
     OutputType => 'Prolog',
    );
  if ($res1->{Success}) {
    my $metadatum = $res1->{Output};
    print Dumper({Metadatum => $metadatum}) if $UNIVERSAL::debug > 3;
    print Dumper({MetadatumPreconditionInterlingua => $args{MetadatumPrecondition}}) if $UNIVERSAL::debug > 3;
    my $res2 = $self->MyImportExport->Convert
      (
       Input => $args{MetadatumPrecondition},
       InputType => 'Interlingua',
       OutputType => 'Prolog',
      );
    if ($res2->{Success}) {
      my $metadatumprecondition = $self->PostProcessWorkAround($res2->{Output});
      print Dumper({MetadatumPrecondition => $metadatumprecondition}) if $UNIVERSAL::debug > 3;
      # my $aiprolog = AI::Prolog->new($metadatum);
      # my $res3 = $aiprolog->query($metadatumprecondition);
      my $factbase = "unknown(X) :- not(neg(X)), not(X).\n".$metadatum.$metadatumprecondition;
      print "\n\n\n".$metadatum."\n\n\n" if $UNIVERSAL::debug > 3;
      my $aiprolog = AI::Prolog->new($factbase);
      my $res3 = $aiprolog->query('predicate(INPUT).');
      my @results;
      while (my $result = $aiprolog->results) {
	push @results, $result;
      }
      print Dumper({AIPrologEvaluatorResults => \@results}) if $UNIVERSAL::debug > 3;
      my $success = !! scalar @results;
      return
	{
	 Success => $success,
	};
    }
  }
  return
    {
     Success => 0,
     Error => undef,
    };
}

sub ProcessMetadatumEffect {
  my ($self,%args) = @_;
  my $res1 = $self->MyImportExport->Convert
    (
     Input => $args{Metadatum},
     InputType => 'Interlingua',
     OutputType => 'Prolog',
    );
  if ($res1->{Success}) {
    my $metadatum = $res1->{Output};
    print Dumper({Metadatum => $metadatum}) if $UNIVERSAL::debug > 3;
    print Dumper($args{MetadatumEffect}) if $UNIVERSAL::debug > 3;
    my $type = ref($args{MetadatumEffect});
    my $assertions;
    if ($type eq 'CODE') {
      my $res2 = $args{MetadatumEffect}->
	(
	 ReturnValue => $args{ReturnValue},
	);
      if ($res2->{Success}) {
	$assertions = $res2->{Assertions};
      }
    } elsif ($type eq 'ARRAY') {
      $assertions = $args{MetadatumEffect};
    }
    print Dumper({Assertions => $assertions}) if $UNIVERSAL::debug > 3;
    $assertionsclone = clone($assertions);
    my $res2 = $self->MyImportExport->Convert
      (
       Input => $assertionsclone,
       InputType => 'Interlingua',
       OutputType => 'Prolog',
      );
    if ($res2->{Success}) {
      my $metadatumeffect = $res2->{Output};
      print Dumper({MetadatumEffect => $metadatumeffect}) if $UNIVERSAL::debug > 3;
      my $aiprolog = AI::Prolog->new($metadatum);
      my $res3 = $aiprolog->query($metadatumeffect);
      my @results;
      while (my $result = $aiprolog->results) {
	push @results, $result;
      }
      print Dumper(\@results) if $UNIVERSAL::debug > 3;
      my $res3 = $self->MyImportExport->Convert
	(
	 Input => $aiprolog->{_prog},
	 InputType => 'AIProlog',
	 OutputType => 'Interlingua',
	);
      if ($res3->{Success}) {
	return
	  {
	   Success => 1,
	   Metadatum => FRDCSA::IAEC::Metadatum->new(Metadatum => $res3->{Output}),
	  };
      }
    }
  }
  return
    {
     Success => 0,
     Error => undef,
    };
}

sub PostProcessWorkAround {
  my ($self,$input) = @_;
  my @result;
  foreach my $line (split /\n/, $input) {
    print "<$line>\n" if $UNIVERSAL::debug > 3;
    if ($line =~ /^$/) {

    } elsif ($line =~ /^(.+)\.$/) {
      push @result, $1;
    } else {
      die "No can do\n";
    }
  }
  return "predicate(INPUT) :-\n".join(",\n",map {"\t".$_} @result).'.';
}

sub ToString {
  my ($self,%args) = @_;
  my $res1 = $self->MyImportExport->Convert
    (
     Input => $args{Metadatum},
     InputType => 'Interlingua',
     OutputType => 'Prolog',
    );
  if ($res1->{Success}) {
    my $metadatum = $res1->{Output};
    return $metadatum;
  }
}

1;
