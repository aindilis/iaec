package FRDCSA::IAEC::Metadatum;

use FRDCSA::IAEC::Metadatum::AIPrologEvaluator;
use FRDCSA::IAEC::Metadatum::PengineEvaluator;

use PerlLib::SwissArmyKnife;

use Data::Dumper;

my $aiprologevaluator;
my $pengineevaluator;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Metadatum /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Metadatum($args{Metadatum});
}

sub Clone {
  my ($self,%args) = @_;
  my $copy = bless { %$self }, ref $self;
  return $copy;
}

sub Serialize {
  my ($self,%args) = @_;
  my $indent = $Data::Dumper::Indent;
  $Data::Dumper::Indent = 0;
  my $serialized = Dumper($self->Normalize);
  $Data::Dumper::Indent = $indent;
  return $serialized;
}

sub Deserialize {
  my ($self,%args) = @_;
  my $metadatum = DeDumper($args{Serialized});
  $self->Metadatum($metadatum);
}

sub Normalize {
  my ($self,%args) = @_;
  return [sort {$a cmp $b} @{$self->Metadatum}];
}

sub Do {
  my ($self,%args) = @_;
  # $prolog->do($args{Action});
}

sub GetEvaluatorForMethod {
  my ($self,%args) = @_;
  if ($args{Method} eq 'AIProlog') {
    if (! defined $aiprologevaluator) {
      $aiprologevaluator = FRDCSA::IAEC::Metadatum::AIPrologEvaluator->new();
    }
    return $aiprologevaluator;
  } elsif ($args{Method} eq 'Pengine') {
    if (! defined $pengineevaluator) {
      $pengineevaluator = FRDCSA::IAEC::Metadatum::PengineEvaluator->new();
    }
    return $pengineevaluator;
  }
}

sub CheckMetadatumPrecondition {
  my ($self,%args) = @_;
  my $evaluator = $self->GetEvaluatorForMethod(Method => $args{Method});
  my $item = Dumper($self->Metadatum);
  my $metadatum = DeDumper($item);
  return $evaluator->CheckMetadatumPrecondition
    (
     Metadatum => $metadatum,
     MetadatumPrecondition => $args{MetadatumPrecondition},
    );
}

sub ProcessMetadatumEffect {
  my ($self,%args) = @_;
  my $evaluator = $self->GetEvaluatorForMethod(Method => $args{Method});
  my $item = Dumper($self->Metadatum);
  my $metadatum = DeDumper($item);
  $metadatum = DeDumper($item);
  return $evaluator->ProcessMetadatumEffect
    (
     Metadatum => $metadatum,
     MetadatumEffect => $args{Candidate}->MetadatumEffect,
     ReturnValue => $args{ReturnValue},
    );
}

sub ToString {
  my ($self,%args) = @_;
  my $evaluator = $self->GetEvaluatorForMethod(Method => $args{Method});
  return $evaluator->ToString(Metadatum => $self->Metadatum);
}

1;
