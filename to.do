(2020-06-25 15:41:02 <White_Flame> aindilis: the real distinguisher is how many
       edge propagations do you want to take place.  All of them, some
       priority/fitness factor to deal with only some of them, only ones
       relevant to some query context, etc
 2020-06-25 15:41:21 <aindilis> hey those are some good qualifiers
 2020-06-25 15:41:23 <White_Flame> rete of course is an exhaustive approach for
       the "all of them".
 2020-06-25 15:41:35 <aindilis> yeah but it's efficient
 2020-06-25 15:41:45 <White_Flame> not really, depending on what you're doing
 2020-06-25 15:42:21 <White_Flame> rete can spend a ton of time maintaining
       partial inference results that come and go without actually hitting the
       agenda
 2020-06-25 15:42:28 <White_Flame> and of course it burns through memory
 2020-06-25 15:44:58 <White_Flame> whereas lazy BC caching can let a bunch of
       facts change over time, and only evaluate its applicability to a goal
       sometimes
 2020-06-25 15:45:42 <White_Flame> my goal is high speed changing facts that
       represent the application run state of a program, so not just monotonic
       expansion
 2020-06-25 15:45:54 <aindilis> nice
 2020-06-25 15:46:22 <White_Flame> so I tend to back waay from anything that
       requires unbounded work on assert/retract
 2020-06-25 15:46:27 <White_Flame> *away
 2020-06-25 15:49:28 <aindilis> unbounded?
 2020-06-25 15:53:28 <aindilis> well it's pretty close to monotonic expansion,
       but for instance, as new assertions are created (in autoepistemic
       contexts), there is some nonmonotonicity.
 2020-06-25 15:54:34 <White_Flame> maybe not unbounded, but explosive in size
 2020-06-25 15:54:39 <aindilis> ah
 2020-06-25 15:54:42 <aindilis> (or I guess other nonmonotonic contexts0
 2020-06-25 15:54:43 <aindilis> )
 2020-06-25 15:54:54 <aindilis> yeah unfortunately that's a problem with it
 2020-06-25 15:55:24 <aindilis> one solution is to represent the most efficient
       known storage of something.  For instance, if you concat two files, you
       can store a reference to (concat File1 File2).
 2020-06-25 15:55:50 <aindilis> so by representing data in terms of other known
       data and functions, you can have your hand at compressing it.
 2020-06-25 15:56:16 <White_Flame> java had a problem with that a while back
 2020-06-25 15:56:23 <aindilis> in the VM?
 2020-06-25 15:56:35 <White_Flame> by storing substrings as offset+length into
       the original string, they avoided copies & extra allocations
 2020-06-25 15:56:44 <aindilis> ah
 2020-06-25 15:56:50 <aindilis> but they ran into issues with it?
 2020-06-25 15:56:55 <sseehh>
       https://en.wikipedia.org/wiki/Template:Graph_search_algorithm
 2020-06-25 15:57:03 <White_Flame> but that means that in many web & editing
       contexts, they blew their heap because they were holding on to massive
       strings just to keep a few short symbols from it
 2020-06-25 15:57:29 <aindilis> well, that's clearly not the most elegant
       expression of it
 2020-06-25 15:57:34 <White_Flame> everything clever can have degenerate
       situations that really cause problems
 2020-06-25 15:57:35 <sseehh> https://en.wikipedia.org/wiki/Beam_search
 2020-06-25 15:58:07 <White_Flame> every strategy really needs to be
       heuristically driven and optionally replaced
 2020-06-25 15:58:12 <aindilis> I suppose it bears more thought, but the goal
       is not cleverness qua cleverness
 2020-06-25 15:58:59 <White_Flame> and constant monitoring of time & memory
       consumption related to strategies are necessary for large work
 2020-06-25 15:59:25 <White_Flame> on a per-use basis, but then that also gets
       into auto-classifications of what defines the problem cases & the
       success cases
 2020-06-25 15:59:44 <aindilis> okay, the goal here is not efficient
       implementation per se
 2020-06-25 15:59:56 <aindilis> but rather the ability to simply have access to
       some of this information.
 2020-06-25 16:00:06 <aindilis> for instance, obtaining an AST from some text
 2020-06-25 16:00:20 <aindilis> and to store it when recomputation is not worth
       it
 2020-06-25 16:01:08 <White_Flame> I'm just speaking as somebody who has hit
       practicality limits with memory & speed a lot
 2020-06-25 16:01:23 <aindilis> yeah, well I figure optimization can take place
       later
 2020-06-25 16:01:41 <White_Flame> tackling optimization can mean a full
       rearchitecting
 2020-06-25 16:01:46 <aindilis> understood
 2020-06-25 16:01:51 <White_Flame> including changing the fundamental feature
       set
 2020-06-25 16:01:55 <aindilis> yeah
 2020-06-25 16:01:57 <aindilis> I really
 2020-06-25 16:01:59 <aindilis> *realize
 2020-06-25 16:06:05 <aindilis> perhaps writing an inefficient version will
       give me better insight into which features I would like
 2020-06-25 16:06:26 <White_Flame> yep
 2020-06-25 16:06:51 <White_Flame> but often you should consider that to be a
       prototype that will be discarded once those issues are explored
 2020-06-25 16:07:07 <aindilis> well, my project has relied mainly on these
       kind of one off protoypes
 2020-06-25 16:07:20 <aindilis> they seem to be where I make the most progress
 )

(2020-06-25 12:04:18 <aindilis> ah RETE reminds me, I'm doing something where
       you have a lot of functions as edges, and you have data as nodes.  To
       each edge function is associated some metadata, including precondition
       predicates (applied to the data) for considering whether the edge
       function is a candidate for execution on a given data node, expected
       temporal extent of the edge function on the data node.
 2020-06-25 12:04:25 <aindilis> Applying edge functions to data node yields a
       new data node.  To each data node is associated a metadata node, with
       metadata about the data, such as data-types, provenance information,
       etc.  My question is, for all available data nodes, there is a set of
       candidate edge functions (all edge functions whose associated
       precondition predicate is true).
 2020-06-25 12:04:27 <aindilis> This seems a little like forward chaining.  So
       I was expecting RETE to be useful here somehow.
 2020-06-25 12:07:05 <aindilis> The point is to find useful functions to invoke
       on the data to make meaningful "observations" or "theorems" about the
       data.  For instance, if a data node were simply a string containing a
       person's full name, it might satisfy the precondition for a function
       which extracts the person's first, middle and last (etc) names into a
       list of three (n) strings.
 2020-06-25 12:07:54 <aindilis> The idea is to take data structures and
       delineate their contents.
 2020-06-25 12:09:22 <aindilis> There are a couple of main use cases here: one
       is Natural Language Understanding - breaking text into subunits that can
       be meaningfully analyzed.  Another application is processing research
       papers, extracting useful information about their contents, such as
       emails, researcher names and institutions, abstracts, urls, citations,
       etc.
 2020-06-25 12:10:51 <aindilis> White_Flame: this is possibly similar somewhat
       to GTS, in that we expect behavior to fall out from the KB
       automatically.  We might *also* consider doing the planning I was
       mentioning over this kind of stuff.  Do you have any ideas how to take
       this model and make it more useful than it already is?
 2020-06-25 12:11:32 <aindilis> I intend to index functions stripped from
       source code with metadata about their signatures, return types, runtime,
       semantics, etc.
 2020-06-25 12:12:06 <aindilis>
       https://github.com/aindilis/cfo/blob/master/example.pl
 2020-06-25 12:12:55 <aindilis> I was thinking of having some attention
       mechanism similar to AM to decide which threads to reveal
 )

(2020-06-06 12:34:56 <aindilis> I am debating writing my IAEC system.  So
       imagine you have a PDF file containing a standard research paper.  There
       are some operations you would want to perform on it.  First, convert to
       text.  Then extract all contents of research paper using ParsCit or
       something similar (including authors, title, author emails etc).
 2020-06-06 12:34:57 <aindilis> But you would also want to extract Abbreviation
       definitions, URIs, so on and so forth.  For each of the URIs you would
       want to check if it's a URI to a piece of software.  If it was, you
       would want to download it, etc. 
 2020-06-06 12:36:24 <aindilis> Currently this is all done using my sentinel
       program.  But sentinel is hand crafted.  I would like to break the
       program into chunks (automatically eventually) and set those chunks up
       as functions which are memoized, but which have Prolog precondition
       specifications.  For instance, a precond might be that the snippet in
       question is a filename of a valid file that contains a PDF.
 2020-06-06 12:37:39 <aindilis> So that when the preconditions are satisfied,
       the program has the option of executing the function on it.  Currently,
       I have a function invocation and memoization system (Sayer, Sayer2).  I
       need to get JavaPengine to work with variables in order to have quick
       calling of Prolog from Perl (YASWI is too slow).
 2020-06-06 12:39:25 <aindilis> The option to invoke should be guided by some
       kind of attention/interest/agenda mechanism.  The function and data
       input and output points are stored in a (tied) graph and persisted using
       SQL.  
 2020-06-06 12:39:56 <aindilis> It should also know the runtime of the function
       on average (I should add a profiling capability into Sayer{,2})
 2020-06-06 12:40:31 <aindilis> The functions are stored in CFO (Comprehensive
       Function Ontology) and metadata about them is stored as well.
 2020-06-06 12:42:21 <aindilis> There has to be a corresponding type system,
       but I do not know how to do that properly.  For instance a filename
       pointing to a valid file containing a PDF is a certain type
       validPdfFilename or something
 2020-06-06 12:42:54 <aindilis> when you execute the function, it updates the
       output's datatypes.  e.g. <apply(pdftotext,validPdfFilename)>
 )

(I need IAEC because:
 (I want to process debian documentation
   (I was looking at abbrev extraction, and all manner of text
    analysis of documentation))
 (This is not the most direct approach.  I need to be able to
  package things.  Maybe extending packager is still best.  Maybe
  ESP is too risky right now.)

 )

(file a bug report on JavaPengine about receiving variables)

(/var/lib/myfrdcsa/codebases/minor/nlu/file-annotation/test.pl
 /var/lib/myfrdcsa/codebases/minor/nlu/conclusions/sample.xml
 /var/lib/myfrdcsa/codebases/minor/suppositional-reasoner/systems/first-stab/test.pl
 /var/lib/myfrdcsa/codebases/minor/nlu/justin-nlu-mf-example.pl
 /var/lib/myfrdcsa/codebases/minor/nlu/prolog/nlu.pl
 /var/lib/myfrdcsa/codebases/minor/iaec/perl/attempts/1/notes.txt
 /var/lib/myfrdcsa/codebases/minor/iaec/perl/attempts/1/process.pl
 /var/lib/myfrdcsa/codebases/minor/prolog-agent/attempts/3/shell-commands.d.pa   (etc)
 /var/lib/myfrdcsa/codebases/minor/kbfs-formalog/kbfs_formalog.pl
 /var/lib/myfrdcsa/codebases/minor/kbfs-formalog/git-api/git-api.pl

 /var/lib/myfrdcsa/codebases/minor/kmax-object-manipulation-system/kmax-object-manipulation-system.el
 /var/lib/myfrdcsa/codebases/minor/kmax-object-manipulation-system/to.do

 /var/lib/myfrdcsa/codebases/minor/vger/frdcsa/sys/flp/autoload/vger.pl
 )

(universal-library)
(look into GATE as well)
(download this http://regexlib.com, and use with duck-typing)

(C-t g followed by i loads the ACL2 indexes)

(IAEC should combine neural methods with Eurisko's for a greater
 than the sum of its parts approach)

(neural-turing-machines may be relevant to IAEC, especially the
 part about filling in details of evolutionary algorithms)

(when you need to know which Prolog arguments should be bound and
 which should be variables, the + and - are called instantiation
 modes.  We need to either autodetect or annotate these, since
 normal true/false is not really descriptive enough for IAEC)

(https://bigzaphod.github.io/Whirl/dma/docs/aspects/aspects-man.html)

(Try a Moses style program evolver in combination with IAEC and
 Formalog)

;; FILE FIXER

(Stands for "I AM Eurisko, CYC!"
 (IAEC is the new name for AM-Eurisko-Cyc-BPS)
 )

(Perhaps part of the key to the next part of the AI would be
 building IAEC, and then using it to make conjectures about
 necessary conditions of different AIs.  For instance, it might
 conjecture a theorem that establishes more bounds on possible
 AIs, leading to techniques to try to find them.)

(If we know that any increasingly intelligent sequence of
 programs must ultimately be bounded below in terms of length by
 a monotonic increasing function that limits to infinity, and
 further that simply any sequence of integers must be so
 similarly, what else can we demonstrate.)

(perhaps attempt to union am-utexas with iaec, so that there is a
 prolog/lisp (and possibly even flora-2) integration.)

(we want to use ACL2 in order to verify/prove properties of the
 functions that Eurisko and AM are evolving, and that the
 programmers are abetting.  Just like AM would examine
 conjectures about the different objects in its KB, we want to
 use ACL2 to prove properites of the different data
 structures (functions) - like sayer.  So for instance, run time,
 etc.  Then use this information for program synthesis.  Use
 Cyc's blackboard to track progress.

 (/var/lib/myfrdcsa/codebases/minor/iaec/systems/eurisko-resources/doc/other/The Cyc Blackboard System v1.0.pdf) 

 (programmer should aid evolution by specifically programming
  components as needed (or by lemma proving))

 )

(
 ACL2 get acl2-emacs.el working:
 (sudo apt-get install acl2 acl2-books acl2-books-certs acl2-books-source acl2-doc acl2-emacs acl2-source)
 (cd /usr/share/acl2-6.5 && sudo ln -s /usr/share/emacs/site-lisp/acl2/ emacs)

 # ln -s /usr/share/acl2-6.5/books/ /usr/share/emacs/site-lisp/acl2/
 # ln -s /usr/share/emacs/site-lisp/acl2/emacs /usr/share/emacs/site-lisp/acl2/
 # # ln -s /usr/share/emacs/site-lisp/acl2 /usr/share/emacs/site-lisp/acl2/books/interface/emacs
 # ln -s /usr/share/acl2-6.5/doc.lisp /usr/share/emacs/site-lisp/acl2

 )

(use rosettacode to figure out how to do a lot of things in
 common lisp)

(think about having the program behave somewhat optimally when
 recognizing different kinds of input, as cross cutting concerns
 (if I am using that concept correctly.))

(iaec should look into data/text mining and knowledge discovery)

(M-x run-acl2)
(M-x acl2-doc)

(completed (look into lisp objectstores, and also, into ORM systems.  Ask
 Jess to explain the difference between ORM and ObjectStores etc))

(download academic pubs about acl2 at
  http://www.cs.utexas.edu/users/moore/acl2, including the ACL2
  Workshop series)

(One possible thing to do to get the auto-programmer and the IAEC
 and system-implementor working, would be to have it try out
 every different possibility of mereological type such as when
 KNext is saying that something may be a certain way, but it is
 unclear which way it is.  Could also order them by probability,
 such as by using WSD results.  This way, the program can direct
 it's evolution.  Then we can simulate everything from the
 structure describe by the text, as input to the program for
 trying to evolve programs to solve problems.  Awesome.)

(Also do fact extraction or rule extraction from existing code,
 and also extract ontologies and such from the code class
 structure.  Also, use our sayer2 object tracing/caching in order
 to extract instances of those objects.)

(solution
 (Is CLOS built into the ACL2 restricted lisp?)
 (ACL2 is a very small subset of full Common Lisp. ACL2 does not
  include the Common Lisp Object System (CLOS), higher order
  functions, circular structures, and other aspects of Common
  Lisp that are non-applicative.))

(Can model constraints, and have evolver and such use those
 constraints on solution.  for instance, with general game
 playing.)

(prolog is proofs as programs)

(emacs eieio has persistance: 11.4 `eieio-persistent')

(use EIEIO for the latest versions of the freekbs2-mode)

(find out if Emacs EIEIO MOP exists, like
 make-programmatic-class)

(Read AMOP)

(look into whether it is possible to implement CLOS and MOP in
 ACL2, or if it has been done already)

(genetic metaprogramming with metaobject protocol)

(mapcar (lambda (list) `(corpus -s ,list)) (list am bps eurisko iaec oscar etc))

(the states that ACL2 describes includes (much like Sayer2 and KBFS/NLU) :

 acl2 
 booleans    integers   vectors     records   caches
 bits        symbols    arrays      stacks    files
 characters  strings    sequences   tables    directories
 )

(AM and Eurisko apply strongly to the life planner)

(NLU can use ACL2 because it has strings as a type)

(So looking at ACL2 it seems (although I'm not sure) that it
 doesn't have a lot of theories about metamathematics, maybe
 these could be imported somehow from other theorem provers.)

(the acl2 manual says:
 (It is a good heuristic to look for relations between parts with
  the same top-level function symbol (as here, with SUBSETP). It
  is also a good heuristic to throw out parts of the formula that
  seem disconnected (as here, with the terms involving (CAR A)).)
 (This makes me think that some of the ACL2 rewrite
  simplification heuristics could be used with IAEC to aid it's
  proving.  Note how the interactivity of checkpoints with ACL2
  recalls the REPL of the AM/Eurisko systems.))

(codify the theorem-proving-tutorial using rules, for instance,
 there are different "modes" of cleaning up checkpoints - write
 code to help with executing these modes.)

(have a system which can answer our own questions about IAEC.
 For instance, in working with ACL2 in a very detailed way - I am
 forgetting some of the details about IAEC.  For instance, why is
 it necessary for us to be able to prove equivalences about the
 terms constraining text meaning?  In the IAEC as opposed to
 Sayer2 case I understand, because we want to prove theorems
 about our data structures.  But you see, I have forgotten why we
 want to do that.
 (note Mon Apr 20 21:38:38 CDT 2015: I am thinking that maybe we
  want to do that for NLU?  So we can do NLU understanding.  Also see middle of /var/lib/myfrdcsa/codebases/minor/iaec/requirements/release-helper-req)
 )

(Questions
 (Is CLOS not implementable in ACL2, or just hasn't been yet?)

 )

(ACL2 has notions of a strong rule, see if we can discuss the
 structure of ACL2 rules in ACL2 itself and prove things like the
 rule is a strong version)

(IAEC could use the versions of lisp implemented in Prolog stored
in the LogicMOO project.)

(develop a DBFS, like this:
 (instead of as with FreeKBS2, for instance, if you assert ('P'
 'a') and ('P' 'b'), there will be two predicates stored in the
 KB.  Make this more like the Sayer system, in that both 'P'
 entries are "symlinks" or foreign keys that point to the sayer
 entry for 'P'.  Then, using this analogy of symlinks, think
 about a FS that is implemented where it has both FS and DB
 bindings, so that, as with IAEC, one could get the contents of
 the file by saying (dataFn <ID>) where ID was the ID of the
 entry for P.  also (idFn 'P'))
 (look into Solid FS for feature lists)

 )

(look into KDD proceedings)


(
 I don't know why I have to be so obsessed with knowing the nature of reality.
 me:  ah
 I am fond of platonic reality
 Meredith:  So I need a path through the confusing forest of information.
 me:  here's an idea
 consider the space of ideas
 and the paths between them
 then consider what follows from the destination of each path
 that right there is a search tree
 the null state - no assumptions
 or is that the first assumption?
 I've always wanted to write that program
 Meredith:  You should do it.
 Meredith is typing
 )

(make it hard to trac it's work:
 https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy)

(In addition to mapping web APIs, it should also map programming
 language modules and objects)
