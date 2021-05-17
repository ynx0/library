/-  *resource, *graph-store
|%
+$  comment  tape
+$  book
  $:
    title=tape
    isbn=tape
  ==
::
+$  prim     (jug resource atom)  :: for a given resource, what indexes does the reader want to hear about?
+$  readers  (map ship prim)      :: given a ship, what are the resources and books that it cares about?
::  TODO anything that takes a rid can theoretically be just a name=@tas because entity=@p is always gonna be the owner of the proxy
+$  command  ::  only host can poke
  $%  [%create-library rid=resource =policy]
      [%remove-library rid=resource]
      [%add-book rid=resource =book]
      [%remove-book rid=resource top=@]
  ==
::
+$  action
  $%  [%add-comment rid=resource top=@ =comment]  :: anyone can add if they are allowed
      [%remove-comment rid=resource =index]       :: anyone can remove their own comment
      [%get-book rid=resource book-index=atom]    :: someone else wants to now get the data for a book and hear about its updates
  ==
::
+$  policies  (map resource policy)
+$  policy
  $%  [%open ~]                      ::  any ship is allowed
      [%children ~]                  ::  any children (i.e. moons) are allowed
      [%whitelist ships=(set ship)]  ::  any ships in the provided set are allowed
  ==
--
