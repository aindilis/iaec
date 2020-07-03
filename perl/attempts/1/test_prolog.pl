%% derived predicates

existsP(X) :-
	isFileP(X) ;
	isDirP(X).


%% actions

pdftotext(X,Y) :-
	fileExistsP(X),
	shell_quote(X,X1),
	strip_extension(X,X2),
	atom_concat(X2,'.txt',X3),
	generateShellCommand(['pdftotext ',X1,' > ',X3],Command),
	shell_command_to_string(Command,Output),
	matches(Output,''),
	fileExistsP(X3).

conditions(do(isDirP(X),S1,S2)) :-
	filenameP(X).

effects(do(isDirP(X),S1,S2)) :-
	(   Result = true ->
	    add(S1,isa(X,directory),S2) ;
	    add(S1,neg(isa(X,directory)),S2)).

poss(pdftotext(X,Y),Z) :-
	isa(X,filename),
	hasMimeType(X,pdf),
	fileContains(fileFn(X),researchPaper).

effects(do(pdftotext(X,Y),S1,S2)) :-
	delete(S1,hasMimeType(X,pdf),S2),
	add(S1,hasMimeType(X,text),S2),
	preserve(S1,fileContains(fileFn(X),researchPaper),S2).

%% atTime([2020-06-06,14:42:02],holds(isa(X,directory)))
