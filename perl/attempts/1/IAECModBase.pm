package FRDCSA::IAEC::Perl::IAECModBase;

use Sayer;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySayer Inits Codes HasBeenInitialized Skip DontSkip Results
	IsCached AllResultsWereCached /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySayer($args{Sayer} || Sayer->new(DBName => $args{DBName}));
  # $self->MySayer->Debug(1);
  $self->Inits({});
  $self->HasBeenInitialized({});
  $self->Codes({});
  $self->Skip($args{Skip});
  $self->DontSkip($args{DontSkip});
  $self->Results({});
}

sub Fire {
  my ($self,%args) = @_;
  return $self->Fire
    (
     Data => $args{Data},
     Overwrite => $args{Overwrite},
     NoRetrieve => $args{NoRetrieve},
     OnlyRetrieve => $args{OnlyRetrieve},
     Skip => $args{Skip},
     DontSkip => $args{DontSkip},
    );
}

sub ProcessText {
  my ($self,%args) = @_;
  my $results;
  my $overwrite = $args{Overwrite} || {};
  my $skip = $args{Skip} || $self->Skip;
  my $dontskip = $args{DontSkip} || $self->DontSkip;
  my $hasdontskip = ! ! scalar keys %$dontskip;
  print Dumper({Skip => $skip}) if 1; # $UNIVERSAL::debug;
  print Dumper({DontSkip => $dontskip}) if 1; # $UNIVERSAL::debug;
  $self->IsCached({});
  foreach my $key (keys %{$self->Codes}) {
    my $doesntsaytoskip = ! exists $skip->{$key};
    my $saysdontskip = exists $dontskip->{$key};
    my $proceed = 0;
    if ($hasdontskip) {
      if ($saysdontskip) {
	$proceed = 1;
      }
    } else {
      if ($doesntsaytoskip) {
	$proceed = 1;
      }
    }
    if ($proceed) {
      print "Doing $key\n";
      my $complete = 0;
      if (! exists $self->HasBeenInitialized->{$key}) {

	# check Sayer to see if it's in the cache so we don't have to
	# bother initializing at least for now
	my $res = $self->MySayer->ExecuteCodeOnData
	  (
	   GiveHasResult => 1,
	   CodeRef => $self->Codes->{$key},
	   Data => $args{Data},
	   Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
	   NoRetrieve => $args{NoRetrieve},
	   Skip => $args{Skip},
	  );
	print Dumper({RawResults => $res}) if $args{Debug};
	if ($res->{Success}) {
	  $results->{$key} = $res->{Result};
	  $complete = 1;
	} else {
	  print "Initializing $key\n";
	  if (exists $self->Inits->{$key}) {

	    # TIME EXECUTION: https://metacpan.org/pod/Benchmark
	    &{$self->Inits->{$key}}($self);

	  }
	  $self->HasBeenInitialized->{$key} = 1;
	}
      }
      if (! $complete) {
	$results->{$key} =
	  [
	   $self->MySayer->ExecuteCodeOnData
	   (
	    CodeRef => $self->Codes->{$key},
	    Data => $args{Data},
	    Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
	    NoRetrieve => $args{NoRetrieve},
	    OnlyRetrieve => $args{OnlyRetrieve},
	    Skip => $args{Skip},
	   ),
	  ];
	$self->IsCached->{$key} = $self->MySayer->IsCached();
      }
    }
  }
  my $all = 1;
  foreach my $key (keys %{$self->IsCached}) {
    if (! $self->IsCached->{$key}) {
      $all = 0;
      last;
    }
  }
  $self->AllResultsWereCached($all);
  return $results;
}

1;
