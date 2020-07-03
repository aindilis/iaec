package FRDCSA::IAEC::Datum;

use PerlLib::SwissArmyKnife;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Datum /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Datum($args{Datum});
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
  my $serialized = Dumper($self->Datum);
  $Data::Dumper::Indent = $indent;
  return $serialized;
}

sub Deserialize {
  my ($self,%args) = @_;
  my $datum = DeDumper($args{Serialized});
  $self->Datum($datum);
}

1;
