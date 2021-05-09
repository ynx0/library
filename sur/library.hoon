/-  *resource, *graph-store
|%
+$  comment  tape
+$  book
  $:
    title=tape
    isbn=tape
  ==
::
+$  prim  (jug atom ship)             :: list of ships allowed to access a single book, represented by top level atom of book node
+$  permissions  (map resource prim)  :: map of a resource to its prim
+$  command
  $%  [%update-permissions rid=resource top=@ =ship operation=?(%add %remove)] ::  only our can poke
      :: this will init permissions for a given resource?. i.e, add by permissions *prim
      :: todo should we use more friendly name such as owner=ship name=@tas instead of rid=resource?
      [%create-library rid=resource]
      [%remove-library rid=resource]
      [%add-book rid=resource =book]                                           ::  only our can poke
      [%remove-book rid=resource top=@]                                        ::  only our can poke
  ==
::
+$  action
  $%  [%add-comment rid=resource top=@ =comment]  :: anyone can add if they have permissions to view
      [%remove-comment rid=resource =index]       :: anyone can remove own
  ==
--
