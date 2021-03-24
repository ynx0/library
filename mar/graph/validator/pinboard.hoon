/-  *post
=>
|%
::  first content is name/title
::  second content is a %section reference
::
++  is-text-pointer
  |=  [cs=(list content) num-elts=@ud]
  ^-  ?
  =/  our-lent=@ud  2
  ?&  =((lent cs) (add num-elts our-lent))
      ?=([* * *] cs)
      ?=(%text -.i.cs)
      ?=([%reference [* @ %sections @ud ~]] i.t.cs)
  ==
--
|_  i=indexed-post
++  grow
  |%
  ++  noun  i
  ::
  ::  TODO enumerate all options below
  ++  graph-permissions-add
    ?+  index.p.i  !!
      [@ ~]        [%yes %yes %no]
    ==
  ::
  ++  graph-permissions-remove
    ?+  index.p.i  !!
      [@ ~]        [%yes %self %self]
    ==
  --
++  grab
  |%
  ++  noun
    |=  p=*
    =/  ip  ;;(indexed-post p)
    ?+    index.p.ip  !!
    ::  top level: book index
    ::  only content is the book title
    ::
        [@ ~]
      ?>  ?=([* ~] contents.p.ip)
      ?>  ?=(%text -.i.contents.p.ip)
      ip
    ::
    ::
        [@ %sections ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::
        [@ %sections @ud ~]
      ?>  ?=([* ~] contents.p.ip)
      ?>  ?=(%text -.i.contents.p.ip)
      ip
    ::  container for chapters
    ::  null content
        [@ %chapters ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  chapter
    ::  index is a sequential id
    ::
        [@ %chapters @ud ~]
      ?>  ?=(is-text-pointer 0)
      ip
    ::  container for bookmarks
    ::  bookmarks and chapters are the same structurally,
    ::  but have different semantic purposii
        [@ %bookmarks ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  bookmark
        [@ %bookmarks @ud ~]
      ?>  (is-text-pointer contents.p.ip 0)
      ip
    ::  container for annotations
        [@ %annotations ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  annotation
    ::  last content is the annotation text
        [@ %annotations @ud ~]
      ?>  (is-text-pointer contents.p.ip 1)
      ?>  ?=([* * * ~] contents.p.ip)
      ?>  ?=(%text -.i.t.t.contents.p.ip)
      ip
    ==
  --
++  grad  %noun
--
