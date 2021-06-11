# library

Simple library application. 

![Made with %graph-store](https://img.shields.io/badge/Made%20with-%25graph--store-darkblue)

## Features

Using this application, you will be able to:

- Create libraries, where a library is a collection of books
- Add and remove books from a library, if you are the owner
- Allow other's to view your library based on various permissioning schemes (policies)
- Add and remove comments from a library, if you are the owner or were granted access


## Installation

First, clone this repository in the directory that your piers are stored in.

```
$ git clone https://github.com/ynx0/library
```

Then, `|mount` the clay filesystem.

```
:dojo> |mount %
```

Then, run the install script. This copies the source code of the library app into the `%home` desk.

```
$ ./library/install.sh <path/to/the/pier>
```

Finally, `|commit` the `%home` desk in both ships

```
:dojo> |commit %home
```

You should see output as follows:

```
+ /~zod/needs/to/finish/this/4/section
TODO :^)
```

## Usage

*Note: The following section assumes you have multiple (fake) ships running. We'll user **~zod** and **~nus**, but feel free to use any ones you like.*

First, follow the installation instructions for two ships, ~zod and ~nus.

To get baseline, run the following two commands:

This first one prints out the state of the graphs in graph store.
```
:graph-store +dbug [%state 'graphs']
```

This second one prints out the state of the library-proxy app.
```
:library-proxy +dbug
```


Now, let's create a library on ~zod.

We'll create it with the `%open` policy, which means that anyone can request for access to the library.

**TODO** rename library to %sci-fi-collection

```
~zod:dojo> :library-proxy &library-command [%create-library [our %library1] [%open ~]]
```

Let's verify that the library exists.
```
~zod:dojo> :graph-store +dbug [%state 'graphs']
TODO output
```
We can see that there is now an empty graph.


Now, let's add a book to our library. Be careful that the isbn is either length of 10 or 13.
```
:library-proxy &library-command [%add-book [our %library1] ["Dune123" "0441172717"]]
```

Verify that the book was created successfully.
```
:graph-store +dbug [%state 'graphs']
TODO
```

Now, let's edit title of the book to remove the unnecessary numbers.

```
TODO this isn't implemented
```

Verify that a revision node was created successfully.
```
:graph-store +dbug [%state 'graphs']
```

Now, let's bring ~nus into the picture.

~nus wants to see what libraries are available on ~zod

Get the list of available libraries from ~zod
```
~nus:dojo> :~zod/library-proxy &library-action [%get-libraries ~]
TODO output
```
We see one, called %library1. 

Now, to make it official, we'll request this one from ~zod.

```
~nus:dojo> :library-proxy &library-command [%request-library [~zod %library1]]
```

If you'll notice, ~zod's library proxy has updated information regarding who's tracking what resource.

```
~zod:dojo> :library-proxy +dbug
TODO output
```


Now, let's see what books are available on ~zod/library1
```
~nus:dojo> :~zod/library-proxy &library-action [%get-books [~zod %library1]]
TODO output
```

Right now, we see the index of one book. 
Let's give it a face.

```
=top-of-dune <index from the last input>
```

Now let's request this book
```
~nus:dojo> :library-proxy &library-command [%request-book [~zod %library1] top-of-dune]
```

Verify that we got the update
```
~nus:dojo> :graph-store +dbug [%state 'graphs']
```

Zod, observe that ~nus is now tracking top-of-dune


~nus, Let's write a comment
~nus, Let's write another comment

Verify its in our graph store
Verify its in zods graph store

~nus deletes his own comment
~zod deletes nus's 2nd comment (shows admins powers)

~zod deletes the book
on ~zod check diff in library-proxy and graph store state
on ~nus check diff in graph store state

~zod deletes the library
on ~zod check diff in library-proxy and graph store state
on ~nus check diff in graph store state, notice kick from subscription



## Advanced Usage

There are three different policies.

- %open - anyone can request the library
- %children - only children can request the library
- %whitelist - only select ships specified at the time of creation can request the library


## Reference

View the reference [here](https://zombo.com)


