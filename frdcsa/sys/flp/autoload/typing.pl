%% rebuild :-
%% 	consult('/var/lib/myfrdcsa/codebases/minor/iaec/frdcsa/sys/flp/autoload/typing.pl'),
%% 	duckTypes([2017-5-17,12:0:0],dateTime).	

%% :- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

%% duckTypes(Object,Type) :-
%% 	typingParseDomain(Object, Output),
%% 	view([output,Output]).

%% %% do a DCG here instead

%% hasSpecificationPredicate(dateTime,dateTimeDCG).

%% typingParseDomain(Object, Output) :-
%% 	view([object,Object]),
%% 	typingParseDomain(Object, Output, _).

%% typingParseDomain(Object, Output, R) :-
%% 	Type = dateTime,
%% 	view([object,Object]),
%% 	view([1]),
%% 	hasSpecificationPredicate(Type,SpecificationPredicate),
%% 	view([2]),
%% 	ToEval =.. [SpecificationPredicate,Output,Object,R],
%% 	view([3]),
%% 	view([toEval,ToEval,object,Object,type,Type,specificationPredicate,SpecificationPredicate]),
%% 	view([4]),
%% 	ToEval.

%% dateTimeDCG(Item) --> [Item],
%% 	{
%% 	 view([a1]),
%% 	 Item = [Y-M-D,H:Mi:S],
%% 	 view([a2]),
%% 	 integer(Y),
%% 	 view([a3]),
%% 	 integer(M),hasConstraint(M,betweenInclusive(1,12)),
%% 	 view([a4]),
%% 	 integer(D),hasConstraint(D,betweenInclusive(1,31)),
%% 	 view([a5]),
%% 	 integer(H),hasConstraint(H,betweenInclusive(0,23)),
%% 	 view([a6]),
%% 	 integer(Mi),hasConstraint(Mi,betweenInclusive(0,59)),
%% 	 view([a7]),
%% 	 integer(S),hasConstraint(S,betweenInclusive(0,59))
%% 	}.

%% hasConstraint(Item,Constraint) :-
%% 	Constraint =.. [betweenInclusive,Start,End],
%% 	Item >= Start,
%% 	Item =< End.