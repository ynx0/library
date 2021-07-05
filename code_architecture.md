# Code Architecture

## Intro

<!-- assuming familiarity with hoon language and gall agents -->

TODO expl diff between this model and graph push hook

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
├── sur
│   └── library.hoon
└── install.sh
```

- The main code of the application lives in `app/library-proxy.hoon`. This contains the gall agent which proxies the `%graph-store` updates between ships.

- `lib/library.hoon` contains miscellaneous helper arms which the proxy uses extensively. A common use case is creating the different `%graph-store` updates for each action being performed.


- The `mar/library` folder contains the definitions of the marks that `%library-proxy` sends and receives in the form of pokes.

- Contained in `mar/graph/validator/library.hoon` is the definition of the validation logic that `%graph-store` uses to enforce the schema of the library applications graph data.

- `sur/library.hoon` contains all the various type definitions used by `%library-store`.

- `install.sh` is a script that automates copying the source files into a ship's pier / home desk.



## Data

### Schema

* **Library** - The fundamental data structure. A library is a graph that contains books
* **Book** - A data structure that contains an entry of a given book's metadata (i.e. title and isbn) and any comments associated with it. It is represented by a top-level node within a library graph.
* **Comment** - A node that represents a user's comment on a given book. Represented as a child node of a book's comment container node.

The schema of the application is as follows:

* Library
	- Book
		+ Metadata Revision Container
			* Specific Metadata Revision
		+ Comments Container
			* Specific Comment


Here is an example output of the simplest graph that showcases the above schema:

```
[ p=[entity=~zod name=%library1]
    q
  [   p
    { [ key=170.141.184.505.124.502.987.560.371.149.556.678.656
          val
        [   post
          [ %.y
              p
            [ author=~zod
              index=~[170.141.184.505.124.502.987.560.371.149.556.678.656]
              time-sent=~2021.6.27..14.18.57..b3dc
              contents=~
              hash=~
              signatures={}
            ]
          ]
            children
          [ %graph
              p
            { [ key=8.319.395.793.566.789.475
                  val
                [   post
                  [ %.y
                      p
                    [ author=~zod
                      index=~[170.141.184.505.124.502.987.560.371.149.556.678.656 8.319.395.793.566.789.475]
                      time-sent=~2021.6.27..14.18.57..b3dc
                      contents=~
                      hash=~
                      signatures={}
                    ]
                  ]
                  children=[%empty ~]
                ]
              ]
              [ key=1.635.018.093
                  val
                [   post
                  [ %.y
                      p
                    [ author=~zod
                      index=~[170.141.184.505.124.502.987.560.371.149.556.678.656 1.635.018.093]
                      time-sent=~2021.6.27..14.18.57..b3dc
                      contents=~
                      hash=~
                      signatures={}
                    ]
                  ]
                    children
                  [ %graph
                      p
                    { [ key=1
                          val
                        [   post
                          [ %.y
                              p
                            [ author=~zod
                              index=~[170.141.184.505.124.502.987.560.371.149.556.678.656 1.635.018.093 1]
                              time-sent=~2021.6.27..14.18.57..b3dc
                              contents=~[[%text text='Dune'] [%text text='10charlong']]
                              hash=~
                              signatures={}
                            ]
                          ]
                          children=[%empty ~]
                        ]
                      ]
                    }
                  ]
                ]
              ]
            }
          ]
        ]
      ]
    }
    q=[~ %graph-validator-library]
  ]
]

```

TODO label statements and pick this apart.


### Validator

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

Currently, there are 3 policies, X Y and Z

- open - asdfadsf
- children - asdfasdf. proof of concept. say you want to automatically allow any children without specifying them all manually. this allows you to do it.
- whitelist - asdfjasdfasdf

It is implemented [here](), and used [here]() at runtime to check

These are totally arbitrary and you can create any type of policy you want. One could imagine creating a policy as based on a 50% chance of getting in, or based on the literal alignment of the stars.




In general, the curren principle is:
- oiwner cna do all
- readers can comment only
- 



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





