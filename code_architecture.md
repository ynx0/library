# Code Architecture

## Intro

The purpose of this application is to serve as an example of how one can use `%graph-store`
as the scaffolding for a new social media application they'd like to build.<sup>*</sup>


In this document, we will cover:
- The features offered by this application
- How the application structures its data
	- Where is that structure found? <!-- sur files -->
	- Where is that structure enforced?
- How the application handles access control
	- Permissions per-library: explicit set by policy
	- Permissions per-book: implicity granted when given access to library. (note: descision arbitrary, doesn't have to be this way)
- 

Library is a toy social media application in which you can create a collection of books, called a library, which can contain any number of books. You can share individual collections per-ship. The creator of the collection has de-facto admin powers; he is the only one who can add or remove books to/from the library, remove the library itself, and add comments or remove anyone's comments. Guest ships may request access to specific libraries, which if granted, allows them to request any book from the library\*\*.




*\*The structure of this application is by no means the only or one, true way to build an application using `%graph-store`.*

\*\*This is an arbitrary design decision. It very well could be that permission is also doled out per-book, but this was chosen for simplicities sake.


## Project Structure

"briefly show and explain project file structure (don't forget, ted/ and gen/ are deprecated)"


Let's take a look at the structure of the project

```
├── app
│   └── library-proxy.hoon
├── lib
│   └── library.hoon
├── mar
│   ├── graph
│   │   └── validator
│   │       └── library.hoon
│   └── library
│       ├── action.hoon
│       ├── command.hoon
│       └── response.hoon
├── misc
│   ├── library cmdline snippets.txt
│   ├── may 17 plan.txt
│   ├── may 20 plan.txt
│   ├── old_notes.txt
│   ├── old_thread_code.hoon
│   ├── proxy app status.txt
│   ├── user flows.txt
│   └── working scries.txt
└── sur
    └── library.hoon
├── ignore_files.txt
├── code_architecture.md
├── install.sh
├── README.md

8 directories, 19 files

```


## Data

### Schema
"schema explanation"


* **Library** - The fundamental data structure. A library is a graph that contains books
* **Book** - A data structure that contains an entry of a given book's metadata (i.e. title and isbn) and any comments associated with it. It is represented by a top-level node within a library graph.
* **Comment** - A node that represents a user's comment on a given book.

The schema of the application is as follows:

* Library
	- Book
		+ Metadata Revision Container
			* Specific Metadata Revision
		+ Comments Container
			* Specific Comment


Here is an example output of the simplest graph that showcases the above schema:

```
TODO output
```


### Validator
"validator logic explanation, briefly"

The schema consists of rules we define over how the shape and contents of the a graph should look like. The validator enforces these rules. 

The main arm to look at is `+graph-indexed-post`, which is what graph-store uses internally to verify the adherence of every graph to its schema any time it is updated. At the time of creation/modification, every indexed-post is fed into this function, which pass/fails the operation.

Summary:

- None of the structural nodes require data, so we simply assert that their contents are empty
- For a specific comment, i.e. a post with an index matching the structure `[@ %comments @ ~]`, we assert that contents only contains a single `%text` content. This choice is arbitrary but meant to keep the application simple.
- For a specific metadata revision, i.e. a post with index matching the structure `[@ %meta @ ~]`,
  we first ensure that it's contents only contain two `%text` content instances.


### Access

"explain implicit permissioning system (i.e. when you have access to a book, you automatically have access to commenting. deliberate choice, not required to be this way)"

"explain policies"


## Agent State
"explain the state that the app holds and what its used for"

## Networking Architecture:
"explain core design decisions: every host of library is themselves responsible for sending out data to relevant people, receivers only trust host's update."

"show the flow of incoming/outgoing traffic. diagram would be nice here"
	* "~zod, host of ~zod/library1 issues %add-comment to proxy, proxy sends graph store update to local graph store, proxy receives the same update, sends it out to all others. same flow as if any other person did an %add-comment, it is broadcast."
"(maybe) show full data flow in short bulleted form. %get-libraries -> %get-library resource -> %get-book resource book -> %add-comment"
"(maybe) explain how poke-back pattern is used to surface data to the end user."

## Closing Words
"emphasize: this is just one architecture that you could follow, you can really do anything you want."





