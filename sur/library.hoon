/-  *resource, store=graph-store
|%
+$  comment  cord
+$  book
  $:
    title=cord
    isbn=cord
    :: TODO fulltext=cord ?
  ==
::
::  networking datastructures.
::  the following are for tracking who to send updates to
::  not for access control. (for that look at `policies`)
+$  prim     (jug @tas atom)      :: for a given library name, what indexes does the reader want to hear about?
+$  readers  (map ship prim)      :: given a ship, what are the libraries and books per library that it cares about?
::  TODO most things that take a rid can theoretically be just a name=@tas because entity=@p is always gonna be the owner of the proxy
::  TODO rename some `top`s to `book-index`
::  only we can poke ourselves with a command
+$  command  
  $%  [%create-library library-name=@tas =policy]
      [%remove-library library-name=@tas]
      [%add-book library-name=@tas =book]
      [%revise-book library-name=@tas top=@ new-book=book]  :: XX if we had to, we could use a separate "book-diff" type instead of =book but for now we don't need it
      [%remove-book library-name=@tas top=@]
      ::  using your own library proxy to request a library on your behalf
      [%request-library rid=resource]
      [%request-book rid=resource top=@]
  ==
::
::  anyone can poke us with an action, incl. ourselves
+$  action
  $%  [%add-comment library-name=@tas top=@ =comment]   :: anyone can add if they are allowed
      [%remove-comment library-name=@tas =index:store]  :: anyone can remove their own comment
      [%get-book library-name=@tas book-index=atom]     :: someone else wants to now get the data for a book and hear about its updates. we should only ever hear this from a foreign library-proxy and never us ourself
      ::  scry wrappers
      [%get-libraries ~]
      [%get-books library-name=@tas]
  ==
::
::  poke-backs to scry wrappers
+$  response
  $%  [%available-libraries libraries=(set @tas)]
      [%available-books library-name=@tas book-indexes=(set @)]
  ==
::
+$  policies  (map @tas policy)
+$  policy
  $%  [%open ~]                      ::  any ship is allowed
      [%children ~]                  ::  any children (i.e. moons) are allowed
      [%whitelist ships=(set ship)]  ::  any ships in the provided set are allowed
  ==
--
