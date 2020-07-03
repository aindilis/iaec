package FRDCSA::IAEC::Metadatum::PengineEvaluator;

use Data::Dumper;
# use FormalogPengine::;

use base 'FRDCSA::IAEC::Metadatum::Evaluator';

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub CheckMetadatumPrecondition {
  my ($self,%args) = @_;
  # $args{Metadatum}
  # $args{MetadatumPrecondition}
}

1;
