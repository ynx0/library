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
+$  prim     (jug resource atom)  :: for a given resource, what indexes does the reader want to hear about?
+$  readers  (map ship prim)      :: given a ship, what are the resources and books that it cares about?
::  TODO most things that take a rid can theoretically be just a name=@tas because entity=@p is always gonna be the owner of the proxy
::  TODO rename some `top`s to `book-index`
::  only we can poke ourselves with a comman
+$  command  
  $%  [%create-library rid=resource =policy]
      [%remove-library rid=resource]
      [%add-book rid=resource =book]
      [%revise-book rid=resource top=@ new-book=book]  :: XX if we had to, we could use a separate "book-diff" type but for now we don't need it
      [%remove-book rid=resource top=@]
      ::  using your own library proxy to request a library on your behalf
      [%request-library rid=resource]
      [%request-book rid=resource top=@]
  ==
::
::  anyone can poke us with an action, incl. ourselves
+$  action
  $%  [%add-comment rid=resource top=@ =comment]   :: anyone can add if they are allowed
      [%remove-comment rid=resource =index:store]  :: anyone can remove their own comment
      [%get-book rid=resource book-index=atom]     :: someone else wants to now get the data for a book and hear about its updates. we should only ever hear this from a foreign library-proxy and never us ourself
      ::  scry wrappers
      [%get-libraries ~]
      [%get-books rid=resource]
  ==
::
::  poke-backs to scry wrappers
+$  response
  $%  [%available-libraries libraries=(set resource)]
      [%available-books rid=resource book-indexes=(set @)]
  ==
::
+$  policies  (map resource policy)
+$  policy
  $%  [%open ~]                      ::  any ship is allowed
      [%children ~]                  ::  any children (i.e. moons) are allowed
      [%whitelist ships=(set ship)]  ::  any ships in the provided set are allowed
  ==
--
