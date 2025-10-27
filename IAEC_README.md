# IAEC: I AM Eurisko, Cyc!

**A cognitive system for making intelligent suppositions about data structures**

## What is IAEC?

IAEC (I AM Eurisko, Cyc!) is an ambitious knowledge representation and automated reasoning system that bridges symbolic AI and modern computing. The name signals its goal: to synthesize the groundbreaking approaches of Doug Lenat's Eurisko (heuristic discovery and meta-reasoning) with Cyc's comprehensive commonsense knowledge representation—as a free/libre, open-source system.

At its heart, IAEC is a **suppositional reasoning engine** that:
- Makes intelligent guesses (suppositions) about data as it encounters it
- Builds a dynamic knowledge graph connecting data through transformations
- Tracks provenance and context explicitly through metadata
- Uses modal reasoning to maintain and refine multiple competing interpretations

## The Core Insight: Suppositions Over Assertions

Traditional systems make definitive assertions. IAEC makes *suppositions*—tentative, revisable assumptions that can be:
- **Sustained** when consistent with other observations
- **Refined** as more context becomes available  
- **Retracted** when contradictions arise
- **Generalized** when specific details aren't yet clear

This mirrors human reasoning: we constantly make provisional interpretations that we adjust as we learn more.

### Example: Reading "Jane went to the bank"

A traditional NLP system might try to definitively determine whether "bank" means a financial institution or a river bank. IAEC instead makes suppositions:

```prolog
suppose(isa('Jane', person)).
suppose(has_wn_sense('went', went#v#1)).
suppose(isa('bank', place)).  % Generalized—not yet committed to specific sense
```

As it reads further context (e.g., "to visit her friends"), it refines its suppositions. If it encounters contradictions, it can backtrack to reconsider which suppositions might be mistaken.

## Architecture: Data as a Knowledge Graph

IAEC represents knowledge as a **directed graph** where:

- **Nodes** contain data (strings, numbers, objects, file contents, etc.)
- **Edges** represent function invocations that derive new knowledge
- **Metadata** describes types, relationships, and properties
- **Provenance** tracks how each piece of knowledge was derived

### Visual Example

```
['Andrew Dougherty']                          
isa(A, string)
isa(A, personFullName)
         │
         ├──GetFirstName──→ ['Andrew']
         │                   isa(B, string)
         │                   isa(B, personFirstName)
         │                   hasFirstName(A, B)
         │
         └──GetLastName───→ ['Dougherty']
                            isa(C, string)
                            isa(C, personLastName)
                            hasLastName(A, C)
```

Each transformation is explicit, traceable, and annotated with metadata about:
- **Types** (`isa(A, string)`)
- **Relationships** (`hasFirstName(A, B)`)
- **Properties** (runtime complexity, determinism, stochasticity)
- **Preconditions** (requirements for function application)
- **Effects** (what new knowledge/relationships are created)

### Web Content Example

Starting from a URL, IAEC can automatically explore relationships:

```
['https://frdcsa.org']
isa(A, url)
    │
    └──GetURLContent──→ ['<html><head><title>FRDCSA</title>...']
                        isa(B, htmlString)
                        hasHTMLContents(A, B)
                            │
                            └──ToText──→ ['FRDCSA\nWhose problems...']
                                         isa(C, string)
                                         hasTextContents(B, C)
```

## How IAEC Works

### 1. Observation and Supposition

When IAEC encounters data, it makes observations and generates suppositions:

```prolog
% Observation: "Jane" looks like a person's name
suppose(isa('Jane', person)).
suppose(isa('Jane', probablyFemale)).  % Can be revised if evidence suggests otherwise

% Observation: String appears to be a filename
suppose(isa('/home/user/data.pdf', filepath)).
suppose(hasExtension('/home/user/data.pdf', pdf)).
```

### 2. Function Application with Preconditions

Functions have explicit preconditions that must be satisfied before they can be applied:

```prolog
% Function: GetFirstName
precondition: isa(A, personFullName)
effect: creates new node B with
  - isa(B, string)
  - isa(B, personFirstName)  
  - hasFirstName(A, B)
```

### 3. Meta-Reasoning About Function Selection

IAEC uses metadata about functions to intelligently decide which to apply:

- **Runtime complexity**: O(n) vs O(n²)
- **Actual timing**: Historical microseconds for different inputs
- **Determinism**: Does it always produce the same output?
- **Stochasticity**: Does it involve randomness?
- **Side effects**: Does it modify external state?

This enables intelligent exploration: fast, deterministic functions first; expensive or risky operations only when justified.

### 4. Constraint Detection and Backtracking

When IAEC detects violated constraints, it can:
- Identify which suppositions might be mistaken
- Backtrack to reconsider alternatives
- Build multiple parallel interpretations (modal reasoning)

### 5. Progressive Refinement

IAEC doesn't need complete information to proceed:

```
1. Initial: suppose('bank' is a place)     [general]
2. Context adds: "to deposit money"
3. Refined: suppose('bank' is a financialInstitution)  [specific]
```

## Integration with Modern AI

IAEC is designed to complement, not replace, modern machine learning approaches:

| Neural Networks | IAEC |
|----------------|------|
| Pattern recognition | Explicit reasoning |
| Implicit knowledge | Explicit knowledge graph |
| Black box | Transparent provenance |
| Fixed after training | Continuously learning |
| Excellent at perception | Excellent at reasoning |

**Together they're powerful:** Neural networks can provide the "intuitions" (e.g., "this looks like a financial transaction"), while IAEC provides the reasoning framework and context control.

## Key Technologies

### Knowledge Representation (Prolog/Perl)

IAEC is implemented across multiple languages:

- **Prolog** for logical reasoning and knowledge representation
- **Perl** for data structure manipulation via Sayer/Sayer2
- **MySQL** for persistent storage via prolog-mysql-store

### Sayer: The Data Structure Investigator

Sayer is IAEC's subsystem for analyzing arbitrary Perl data structures:

> "Sayer gets its name because it builds a context by asserting interesting facts about arbitrary Perl data structures."

Sayer recursively investigates data, building a graph of observations:
- Is this a string? A number? A reference?
- Does this string contain a paragraph? A name? Code?
- What interesting patterns can be extracted?

### Prolog MySQL Store: Persistent Knowledge

The `prolog-mysql-store` provides IAEC with long-term memory:

```prolog
% Store metadata persistently
store_assert(mydb, iaec:metadata(UUID, isa, string)).
store_assert(mydb, iaec:metadata(UUID, hasLength, 42)).

% Store relationships with variables
store_template(mydb, iaec:hasPrecondition(operation1, [hasSymlink(A, B)])).

% Query across sessions
?- store_call(mydb, iaec:metadata(UUID, isa, Type)).
```

This enables IAEC to:
- Remember previous analyses
- Build knowledge incrementally over time
- Share knowledge across multiple agent instances

### AgentSpeak(L) Meta-Interpreter (SPAMI)

IAEC integrates with autonomous AI agents through SPAMI:

```prolog
% From iaec2.pasl
+!investigate(A) :: atom(A) <-
    !investigate_atom(A).

+isa(A, existingFile) :: unknown(hasExtension(A, _)) & has_filename_extension(A, B) <-
    +hasExtension(A, B).

+hasExtension(A, pdf) :: unknown(hasMIMEType(A, _)) & has_mime_type(A, B) <-
    +hasMIMEType(A, B).
```

This allows IAEC to:
- React to new beliefs as they're discovered
- Trigger investigations based on observations
- Coordinate multiple specialized agents

## Example: File Investigation Agent

When given a file path, IAEC automatically investigates:

```prolog
+!investigate('/home/user/thesis.pdf') <-
    % Observe
    +isa('/home/user/thesis.pdf', existingFile);
    
    % Check executable?
    if executable_file('/home/user/thesis.pdf') then
        +hasProperty('/home/user/thesis.pdf', executable);
    
    % Determine extension
    has_filename_extension('/home/user/thesis.pdf', Ext);
    +hasExtension('/home/user/thesis.pdf', Ext);
    
    % Determine MIME type
    has_mime_type('/home/user/thesis.pdf', MIME);
    +hasMIMEType('/home/user/thesis.pdf', MIME);
    
    % MIME type is PDF → convert to text
    if MIME = 'application/pdf' then
        has_corresponding_text_file('/home/user/thesis.pdf', TextFile);
        +hasCorrespondingTextFile('/home/user/thesis.pdf', TextFile);
        
        % Recursively investigate text file
        !investigate(TextFile);
    
    % Text file → count characters
    if MIME = 'text/plain' then
        has_character_count('/home/user/thesis.pdf', Count);
        +hasCharacterCount('/home/user/thesis.pdf', Count);
        
        % If small enough, summarize with LLM
        if Count < 32768 then
            read_text_from_file('/home/user/thesis.pdf', Text);
            !summarize(Text, Summary);
            +hasSummarization('/home/user/thesis.pdf', Summary).
```

Each step is a supposition that builds on previous observations, creating a rich graph of knowledge about the file.

## Philosophical Foundations

### Modal Reasoning

IAEC embraces uncertainty through modal logic:

```
Suppose A is true
Suppose B might be true
Suppose C is probably false
```

This allows reasoning about:
- **Possibility**: What could be true?
- **Necessity**: What must be true?
- **Probability**: How likely is each interpretation?

### Anti-Rivalry of Information

As part of the FRDCSA (Formalized Research Database: Cluster, Study and Apply) ecosystem, IAEC embodies the principle that **information is anti-rivalrous**: sharing knowledge makes everyone better off, not worse off.

This manifests in:
- **Open source**: All code freely available (GPLv3)
- **Shared ontologies**: Comprehensive Function Ontology mined from existing code
- **Collaborative knowledge**: Multiple agents sharing insights via persistent storage

### Context as First-Class Citizen

Unlike neural networks where context is implicit in weights, IAEC makes context explicit and manipulable:

```prolog
% Context is visible
context(readingSentence42).
within_context(readingSentence42, [
    suppose(isa('Jane', person)),
    suppose(refers_to('Jane', entity_1234)),
    suppose(sameEntity('Jane'@sentence41, 'Jane'@sentence42))
]).

% Context can be reasoned about
?- is_consistent(context(readingSentence42)).
?- what_if(retract(suppose(isa('bank', financialInstitution))), NewContext).
```

## Use Cases

### 1. Natural Language Understanding

Read text incrementally, making suppositions about:
- Word senses
- Entity references  
- Relationship structures
- Discourse context

Revise interpretations as more context becomes available.

### 2. Software Analysis

Investigate codebases by supposing:
- What functions do
- What data structures represent
- How components relate
- Where bugs might exist

### 3. Research Paper Processing

Given a PDF:
- Extract text
- Identify: authors, abstract, citations
- Extract: software systems mentioned, GitHub links
- Classify: research area, methodology
- Summarize: key contributions

### 4. Autonomous Systems

Embedded in agents to:
- Reason about sensor data
- Plan actions based on suppositions
- Coordinate multiple specialized agents
- Learn from successes and failures

### 5. Life Planning (FLP Integration)

As part of Free Life Planner:
- Analyze user's situation (files, emails, calendar)
- Suppose goals and constraints
- Reason about action sequences
- Track progress over time

## Current Implementation Status

**IAEC is working!** The system has been successfully integrated and is operational:

### Integrated Prolog Implementation (iaec3.pasl)
- ✅ **Fully integrated** with prolog-mysql-store for persistent knowledge
- ✅ **AgentSpeak(L) integration** via SPAMI for autonomous agent behavior
- ✅ **Metadata management** with variable support for complex patterns
- ✅ **Graph-based reasoning** with nodes, edges, and provenance tracking
- ✅ **File investigation** pipeline (detect type, extract content, summarize)
- ✅ **Knowledge persistence** across sessions via MySQL backend

### Perl (via Sayer/Sayer2)
- ✅ Data structure analysis
- ✅ Graph construction
- ✅ Function application
- 🔄 Being further integrated with IAEC proper

### Release Status

The system is **currently in use** but undergoing preparation for public release. Interestingly, IAEC is being used to manage its own release process—**marking which git file revisions are ready for release**. This is a beautiful example of dogfooding: IAEC is reasoning about and tracking the state of its own source code, deciding which components are ready for the world to see.

This self-application demonstrates IAEC's practical utility for:
- Tracking file states and metadata
- Making intelligent decisions about readiness
- Managing complex dependencies between components
- Building knowledge incrementally (as each file is reviewed and marked)

## Getting Started

> **Note**: IAEC is currently operational but preparing for public release. The system is actively being used internally and will be released once all components are properly documented and marked ready. Watch the repository for release announcements.

### Prerequisites

```bash
# SWI-Prolog
sudo apt-get install swi-prolog

# MySQL/MariaDB
sudo apt-get install mysql-server libmyodbc unixodbc

# Perl with necessary modules
cpan install DBI DBD::mysql
```

### Basic Usage (Coming Soon)

Once released, you'll be able to:

```prolog
:- use_module(mysql_store).
:- use_module(iaec).

% Initialize
?- iaec_init.
?- store_connect(mydb, 'localhost', 'iaec_db', 'user', 'password').

% Process some data
?- iaec_process('Andrew Dougherty', Analysis).

% Investigate a file
?- iaec_investigate('/path/to/document.pdf', Beliefs).

% View the knowledge graph
?- iaec_export_graph(Graph).
```

### Current Internal Usage

The integrated system (iaec3.pasl + prolog-mysql-store) is currently being used for:
- **Release management**: Tracking which source files are ready for release
- **File analysis**: Investigating documents, code, and data structures
- **Knowledge accumulation**: Building persistent knowledge graphs
- **Agent coordination**: Multiple specialized agents sharing insights

## Roadmap

### Current (Pre-Release)
- [x] Core Prolog implementation with prolog-mysql-store
- [x] AgentSpeak(L) integration via SPAMI (iaec3.pasl)
- [x] File investigation pipeline
- [x] Persistent knowledge graphs
- [ ] Complete documentation for all components
- [ ] Finalize release-ready file marking
- [ ] Public release of integrated system

### Near Term (Post-Release)
- [ ] Complete modal logic implementation
- [ ] Expand Comprehensive Function Ontology
- [ ] Enhanced Sayer-IAEC bridge
- [ ] Additional domain-specific function libraries
- [ ] Tutorial and example scenarios

### Medium Term  
- [ ] Deep learning integration for "sounds right" system
- [ ] Probabilistic reasoning over suppositions
- [ ] Multi-agent coordination protocols
- [ ] Natural language generation from knowledge graph
- [ ] Interactive visualization of knowledge graphs

### Long Term
- [ ] Self-modifying heuristics (true Eurisko-style)
- [ ] Learned function discovery and composition
- [ ] Cross-domain knowledge transfer
- [ ] Deep integration with other FRDCSA systems
- [ ] Distributed IAEC instances sharing knowledge

## Why IAEC Matters

In an era of powerful but opaque neural networks, IAEC offers:

1. **Transparency**: Every inference is traceable
2. **Revisability**: Wrong assumptions can be corrected  
3. **Explainability**: The system can explain its reasoning
4. **Context control**: Context is explicit and manipulable
5. **Incremental learning**: Knowledge builds over time
6. **Collaborative potential**: Multiple agents share insights

Most importantly, IAEC provides a **bridge** between:
- Classical symbolic AI (Cyc, Eurisko, expert systems)
- Modern machine learning (neural networks, deep learning)
- Human reasoning (suppositional, revisable, context-aware)

### Dogfooding: IAEC Managing Its Own Release

A particularly elegant demonstration of IAEC's capabilities is that **it's currently being used to manage its own release process**. IAEC investigates its own source files, reasons about their readiness, and tracks which git revisions are ready for public release.

This self-application illustrates several key strengths:

- **Meta-reasoning**: IAEC can reason about code (including its own)
- **State tracking**: It maintains knowledge about file states across time
- **Practical utility**: It's useful enough to use on real problems (even its own!)
- **Incremental refinement**: Decisions about release-readiness can be revisited as code evolves

This is the kind of self-reflective capability that Eurisko pioneered—and it's already working in IAEC.

## Contributing

IAEC is developed as part of the FRDCSA project and welcomes contributions:

1. **Code**: Implement functions, fix bugs, optimize
2. **Knowledge**: Add to the function ontology
3. **Testing**: Try IAEC on your problems, report issues
4. **Documentation**: Improve explanations, add examples
5. **Integration**: Connect IAEC with other systems

## Related Systems

- **Sayer/Sayer2**: Data structure investigation
- **SPAMI**: AgentSpeak(L) Meta-Interpreter  
- **prolog-mysql-store**: Persistent Prolog facts
- **Free Life Planner**: AI-assisted planning
- **FRDCSA**: The broader ecosystem

## License

GNU General Public License v3.0

We believe in the anti-rivalry of information. By keeping IAEC free and open, we ensure that improvements benefit everyone, fostering collective advancement over individual competition.

## References

### Historical Context
- Doug Lenat's **Eurisko** (1976-1983): Heuristic discovery and self-modification
- **Cyc** (1984-present): Large-scale commonsense knowledge base
- **STRIPS** (1971): Planning with preconditions and effects
- **Modal Logic**: Reasoning about possibility, necessity, and belief

### Philosophical Influences
- The document in this repository describes the original vision
- FRDCSA: 26+ years of work on formalized research
- Free/Libre Open Source Software (FLOSS) principles

### Technical Foundations
- SWI-Prolog: Logic programming environment
- Perl: Practical data structure manipulation  
- MySQL: Reliable persistent storage
- AgentSpeak(L): BDI agent architecture

## Contact & Support

- **GitHub**: https://github.com/aindilis/iaec
- **FRDCSA**: https://frdcsa.org
- **Issues**: File via GitHub Issues
- **Questions**: GitHub Discussions

---

**IAEC: Making intelligent suppositions about the world, one data structure at a time.**

*Part of the FRDCSA ecosystem — because the problems we face require collaborative intelligence.*
