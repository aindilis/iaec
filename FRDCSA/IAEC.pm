package FRDCSA::IAEC;

use FRDCSA::IAEC::Datum;
use FRDCSA::IAEC::NodeDatumAndMetadatum;

use Clone qw(clone);
use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / EdgeFunctions NodeDataAndMetadata /

  ];

sub init {
  my ($self,%args) = @_;
  $self->EdgeFunctions($args{EdgeFunctions});
  $self->NodeDataAndMetadata($args{NodeDataAndMetadata} || {});
  if ($args{NodeDataAndMetadataList}) {
    foreach my $nodedatumandmetadatum (@{$args{NodeDataAndMetadataList}}) {
      $self->NodeDataAndMetadata->{$nodedatumandmetadatum->Datum->Serialize}{$nodedatumandmetadatum->Metadatum->Serialize} =
	$nodedatumandmetadatum;
    }
  }
}

sub CollectCandidates {
  my ($self,%args) = @_;

  my $nodedatumandmetadatum = $args{NodeDatumAndMetadatum};
  print Dumper({NodeDatumAndMetadatumDatum => $nodedatumandmetadatum->Datum}) if $UNIVERSAL::debug > 3;

  # list candidates
  my $candidates = {};
  foreach my $edgefunction (values %{$self->EdgeFunctions}) {
    my $goahead = 0;
    if (defined $edgefunction->Precondition) {
      if ($edgefunction->Precondition->(@{$nodedatumandmetadatum->Datum->Datum})) {
	if (defined $edgefunction->MetadatumPrecondition) {
	  my $metadatumpreconditionclone = clone($edgefunction->MetadatumPrecondition);
	  my $res1 = $nodedatumandmetadatum->Metadatum->CheckMetadatumPrecondition
	    (
	     Method => $args{Method},
	     MetadatumPrecondition => $metadatumpreconditionclone,
	    );
	  if ($res1->{Success}) {
	    $goahead = 1;
	  }
	} else {
	  $goahead = 1;
	}
      }
    } else {
      if (defined $edgefunction->MetadatumPrecondition) {
	my $metadatumpreconditionclone = clone($edgefunction->MetadatumPrecondition);
	my $res2 = $nodedatumandmetadatum->Metadatum->CheckMetadatumPrecondition
	  (
	   Method => $args{Method},
	   MetadatumPrecondition => $metadatumpreconditionclone,
	  );
	if ($res2->{Success}) {
	  $goahead = 1;
	}
      } else {
	$goahead = 1;
      }
    }
    if ($goahead == 1) {
      print 'Candidate: '.$edgefunction->Name."\n" if $UNIVERSAL::debug > 3;
      $candidates->{$edgefunction->Name} = $edgefunction;
    }
  }
  return $candidates;
}

sub Fire {
  my ($self,%args) = @_;
  # all
  if (1 or $args{Method} eq 'all') {
    foreach my $candidate (values %{$args{Candidates}}) {
      my @result = $candidate->EdgeFunction->(@{$args{NodeDatumAndMetadatum}->Datum->Datum});
      $candidate->Effect->(
			   Method => $args{Method},
			   Result => \@result,
			   NodeDataAndMetadata => $self->NodeDataAndMetadata,
			   NodeDatumAndMetadatum => $args{NodeDatumAndMetadatum},
			   Candidate => $candidate,
			  );
    }
  }

  # priority
  # fitness

  # context
}

sub ShowObjectsAndFactbases {
  my ($self,%args) = @_;
  print "\n\n\n";
  foreach my $datum (keys %{$self->NodeDataAndMetadata}) {
    print "$datum\n";
    foreach my $metadatum (keys %{$self->NodeDataAndMetadata->{$datum}}) {
      print "\n";
      print $self->NodeDataAndMetadata->{$datum}{$metadatum}->Metadatum->ToString(Method => $args{Method});
      print "\n\n";
    }
  }
}

1;
