:- dynamic neg/1, isa/2, hasProperty/2, hasExtension/2, hasMIMEType/2, hasCorrespondingTextFile/2.

p :-
	show('.').

show(Item) :-
	print_term(Item,[]),
	nl,
	true.

:- consult('/var/lib/myfrdcsa/codebases/minor/interactive-execution-monitor/frdcsa/sys/flp/autoload/args.pl').

test(isFileNameP([
		  %% precondition([atom('input')]),
		  precondition([atom(A),unknown(isa(A,existingFilename))]),
		  edgeFunction([exists_file(A)]),
		  predicateEffect([isa(A,existingFilename)])
		 ])).

test(isDirectoryP([
		   precondition([atom(A),unknown(isa(A,existingDirname))]),
		   edgeFunction([exists_directory(A)]),
		   predicateEffect([isa(A,existingDirname)])
		  ])).

test(executableFilenameP([
			  precondition([isa(A,existingFilename),unknown(hasProperty(A,executable))]),
			  edgeFunction([executable_file(A)]),
			  predicateEffect([hasProperty(A,executable)])
			 ])).

test(hasExtension([
		   precondition([isa(A,existingFilename),unknown(hasExtension(A,B))]),
		   edgeFunction([has_filename_extension(A,B)]),
		   predicateEffect([hasExtension(A,B)])
		  ])).

test(hasPDFMIMEType([
		     precondition([hasExtension(A,'pdf'),unknown(hasMIMEType(A,'pdf'))]),
		     edgeFunction([has_mime_type(A,'pdf')]),
		     predicateEffect([hasMIMEType(A,'pdf')])
		    ])).

test(hasCorrespondingTextFile([
			       precondition([hasMIMEType(A,'pdf'),unknown(hasCorrespondingTextFile(A,_))]),
			       edgeFunction([has_corresponding_text_file(A,B)]),
			       predicateEffect([hasCorrespondingTextFile(A,B)])
			      ])).

% test(parscitResults([
% 		     precondition([hasMIMEType(A,'pdf'),hasCorrespondingTextFile(A,_),unknown(parscitResults(A,B))]),
% 		     edgeFunction([process_with_parscit(A,B)]),
% 		     predicateEffect([parscitResults(A,B)])
% 		    ])).
	      


unknown(A) :-
	not(A),
	not(neg(A)).

iaec(Input,State,Results) :-
	show([state,State]),
	collect_candidates(Input,State,Candidates),
	fire(Input,State,Candidates,State2),
	(   State = State2 -> Results = State2 ; iaec(Input,State2,Results)).

collect_candidates(Input,State,Candidates) :-
	findall(Candidate,(
			   test(Test),
			   Test =.. [Name,ArgumentList],
			   argt(ArgumentList,precondition(PreconditionList)),
			   (   precondition_holds(Input,PreconditionList,State) -> Candidate = Test)
			  ),Candidates).

precondition_holds(Input,PreconditionList,State) :-
	foreach(member(Fact,State),(
				    %% show([asserting,Fact]),
				    assert(Fact))),
	(   forall(member(Precondition,PreconditionList),(call((term_variables(Precondition,[Input|_]),show([precondition(Precondition)]),Precondition))))
	->  Result = success ; Result = failure),
	foreach(member(Fact,State),(
				    %% show([retracting,Fact]),
				    retract(Fact)
				   )),
	Result = success.

fire(Input,State1,Candidates,State2) :-
	show(candidates(Candidates)),
	findall(Do,
		(   member(Candidate,Candidates),
		    Candidate =.. [Name,ArgumentList],
		    argt(ArgumentList,edgeFunction(EdgeFunctionList)),
		    argt(ArgumentList,predicateEffect(EffectList)),
		    eval_holds(Input,EdgeFunctionList,State,Results),
		    (	(   Results \= []) ->
		    	findall(Item,foreach(member(Effect,EffectList),(p,term_variables(Effect ,[Input|_]),p,Item = Effect)),Do) ;
		    	findall(Item,foreach(member(Effect,EffectList),(p,term_variables(Effect, [Input|_]),p,Item = neg(Effect))),Do))),
		StateDiff),
	(   is_list(StateDiff) -> append(StateDiff,RealStateDiff) ; RealStateDiff = []),
	%% append(StateDiff,RealStateDiff),
	apply_state_diff(State1,RealStateDiff,State2).

eval_holds(Input,EdgeFunctionList,State,Results) :-
	findall(Result,
		(   member(EdgeFunction,EdgeFunctionList),
		    (	show([edgeFunction(EdgeFunction)]),
			copy_term(EdgeFunction,Term),
			numbervars(Term,0,End),
			Term =.. [P|Numbers],
			term_variables(EdgeFunction,[Input|Vars]),
			call(EdgeFunction),
			EdgeFunction =.. [Pred|Numbers2],
			Result = [Pred,Numbers,Numbers2])), %% figure out about nested terms/vars
		Results),
	show([results,Results]).

apply_state_diff(State1,StateDiff,State2) :-
	append(State1,StateDiff,State2).

run :-
	iaec('/home/andrewdo/morbini-phd-thesis.pdf',[],Results),
	print_term(Results,[]),nl.

executable_file(A) :-
	fail.

has_filename_extension(A,B) :-
	B = 'pdf'.

has_mime_type(A,B) :-
	B = 'pdf'.

has_corresponding_text_file(A,B) :-
	B = '/home/andrewdo/morbini-phd-thesis.txt'.

