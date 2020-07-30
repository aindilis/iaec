# iaec
I AM Eurisko, Cyc!  A system to attempt to partially reimplement all of these seminal technologies as one, free/libre, system with some possible improvements

IAEC consists of many technologies.  They are all aimed at proving things about data and relating it.

The first implementation we've been working on (both Perl and Prolog versions), is similar to our Sayer 
and Sayer2 systems.  It creates a graph, with data as nodes, and function calls as edges.

For instance: you could have the following graph with 1 node and 0 edges:

'''
['Andrew Dougherty']
'''

Then you could invoke an edge called GetFirstName, to obtain the datapoint ['Andrew'].

So the graph would look like:

'''
['Andrew Dougherty'] -> GetFirstName -> ['Andrew']
'''

You could also call GetLastName, so the graph would look like:

'''
['Andrew'] <- GetFirstName <- ['Andrew Dougherty'] -> GetLastName -> ['Dougherty']
'''

So there are functions.  These come from our "Comprehensive Function Ontology", and are mined from existing code.

We associate preconditions with each function, required for it to run.  The preconditions operate on metadata.  For instance:

'''
['Andrew Dougherty'] might have the following metadata:

isa(A,string).
isa(A,personFullName).
'''

So both of these are data types, but other metadata could hold.

So GetFirstName has a precondition of isa(A,personFullName).  It creates a new node containing the data of the first name.
Furthermore, it updates the metadata for the original node, and creates metadata for the new node: e.g.

'''
['Andrew Dougherty']
isa(A,string)
isa(A,personFullName)
hasFirstName(A,B)

['Andrew']
isa(B,string)
isa(B,personFirstName)
hasFirstName(A,B)
'''

So for instance you might have:

'''
['https://frdcsa.org']
isa(A,string)
isa(A,url)
'''

and then have an edge: GetURLContent

'''
['https://frdcsa.org']
isa(A,string)
isa(A,url)
hasHTMLContents(A,B)

['<html>
  <head>
    <title> FRDCSA </title>
  </head>
  <body>
    <br>
    <center>
...']
isa(B,string)
hasHTMLContents(A,B)
'''

Then you might call ToText on this and so get

'''
['https://frdcsa.org']
isa(A,string)
isa(A,url)
hasHTMLContents(A,B)

['<html>
  <head>
    <title> FRDCSA </title>
  </head>
  <body>
    <br>
    <center>
...']
isa(B,string)
hasHTMLContents(A,B)
hasTextContents(B,C)

['FRDCSA
Whose problems are you solving today?

introduction
minor codebases | internal codebases | external codebases | git codebases | packages
free life planner | github | homepage
...]
isa(C,string)
hasTextContents(B,C)
'''



Some more information now about the edges.  Like nodes, they have associated properties (similar to metadata).  
For instance,  They might have information about runtime, both in symbolic O notation, and actual number of 
microseconds for different invocations.  They might indicate whether the function is nondeterministic, stochastic, 
etc.  Just every kind of algorithmic property.

These properties are used as input to a decision making process about which function expansions to invoke first.

So this is just a quick overview about how IAEC works.  More later.
