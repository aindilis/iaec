(load swipl from perl)

(verify 
 (completed (have bidirectional logic))
 (in progress (able to interact with prolog REPL from within perl if needed))
 )
(be able to assert into freekbs2 from prolog
 (create assertz, asserta
  (make a wrapper around asserta assertz)
  (use an ordering, also stored in FreeKBS2)
  (use sort {exists $order->{$a} and exists $order->{$a}{$b}},
   plus add stuff about grouping predicates)
  (implement the prolog translation)
  )
 )
(write wrapper around swipl which accepts all swipl options and
 invokes from perl, plus loads FRDCSA libraries for interacting
 with FRDCSA from prolog)

(write at least two attempts, an initial quick and dirty proof of
 concept just to get the ball rolling, and then later make it
 work well)

(then use this to implement persistence for adventure system)

(question:
 (why is this better than just using the persistency.pl
  mechanism)
 (because it is easier to recover from errors, and stores the
  data better than just in a flat file, updates - no need for
  long session logs
  (although keep logs also, but don't reload every time)))

(question
 (what is the use of this system)
 (to be able to interact with the resource manager and the rest
  of the FRDCSA on other systems and such.  can interact between
  unilang and prolog now.  Hence can interact between opencyc and
  other systems.  Can get iaec working this way.))
