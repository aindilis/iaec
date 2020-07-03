%% hasPotentialSourcesOfNewSystems(['/home/andrewdo/Downloads/Downloads-tor','/home/andrewdo','/home/andrewdo/Downloads']).
%% hasPlural(hasPotentialSourceOfNewSystems/1,hasPotentialSourcesOfNewSystems/1).
%% :- dynamic hasPotentialSourceOfNewSystems/1.

%% hasPlural(hasArchiveFormat/1,hasArchiveFormats/1).

%% listPlurals :-
%% 	hasPlural(SingularPredicate/SPArity,PluralPredicate/PPArity),
%% 	length(SPArgList,SPArity),
%% 	length(PPArgList,PPArity),
%% 	SPTerm =.. [SingularPredicate|SPArgList],
%% 	PPTerm =.. [PluralPredicate|PPArgList],
%% 	PPTerm,
%% 	member(PPList,PPArgList),
%% 	member(SPEntry,SPArgList),
%% 	member(SPEntry,PPList),
%% 	%% see(SPTerm),
%% 	kbfs_assert(SPTerm),
%% 	fail.
%% listPlurals.

%% :- listPlurals.

%% loadBashHistory(Commands) :-
%% 	process_create(path(cat),[file('/home/andrewdo/.bash_history')],
%% 		       [stdout(pipe(Out))]),
%% 	read_string(Out, _, Output),
%% 	close(Out),
%% 	split_string(Output, "\n", "", Commands).
