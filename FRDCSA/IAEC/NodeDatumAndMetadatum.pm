package FRDCSA::IAEC::NodeDatumAndMetadatum;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Datum Metadatum /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Datum($args{Datum});
  $self->Metadatum($args{Metadatum});
}

1;
