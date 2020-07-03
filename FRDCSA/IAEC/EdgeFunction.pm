package FRDCSA::IAEC::EdgeFunction;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Precondition MetadatumPrecondition EdgeFunction Effect
	MetadatumEffect /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name} or 'edgeFunction_'.rand());

  $self->Precondition($args{Precondition});
  $self->MetadatumPrecondition($args{MetadatumPrecondition});

  $self->EdgeFunction($args{EdgeFunction});

  $self->Effect($args{Effect});
  $self->MetadatumEffect($args{MetadatumEffect});
}

1;
