/-  *post
=>
|%
::  first content is pin title
::  second content is a 
::
++  max-length-title  20
++  max-length-body   250
++  are-coordinates-valid
  |=  [x=@ud y=@ud]
  ^-  ?
  :: invariant: all x and y are gte 0 b/c @ud
  =/  max-width=@ud  1.920
  =/  max-height=@ud  1.080
  ?&  (lte y max-height)
      (lte x max-width)
  ==
--
|_  i=indexed-post
++  grow
  |%
  ++  noun  i
  ::
  ++  graph-permissions-add
    ?+  index.p.i  !!
      [@ ~]          [%yes %yes %no]
      [@ %meta ~]    [%self %self %no]
      [@ %meta @ ~]  [%yes %self %no]
      [@ %pin ~]     [%self %self %no]
      [@ %pin @ ~]   [%self %self %no]
    ==
  ::
  ++  graph-permissions-remove
    ?+  index.p.i  !!
      [@ ~]          [%yes %self %no]
      [@ %meta ~]    [%no %no %no]
      [@ %meta @ ~]  [%yes %self %no]
      [@ %pin ~]     [%no %no %no]
      [@ %pin @ ~]   [%yes %self %no]
    ==
  ++  transform-add-nodes
    |=  [=index =post =atom was-parent-modified=?]
    !!
    :: ^-  [^index ^post]
    :: =-  [- post(index -)]
    :: [atom ~]
  ::
    ++  notification-kind  `[%message [0 1] %count %none]
  ::
  --
++  grab
  |%
  ++  noun
    |=  p=*
    =/  ip  ;;(indexed-post p)
    ?+    index.p.ip  !!
    ::  top level node: pin
    ::  structural node with no content
    ::
        [@ ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  metadata revision container
    ::  structural node with no content
    ::
        [@ %meta ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  single metadata revision
    ::  content node with data format [x y] specifying x and y coordinates of the pinboard
    ::
        [@ %meta @ ~]
      :: ?>  ?=([[%text *] [%text *] ~] contents.p.ip)  :: todo figure this out
      =/  contents  contents.p.ip
      ~&  contents
      :: =/  x  ;;(@ud -.i.contents)  :: TODO make this actually work
      :: =/  y  ;;(@ud +.i.contents)
      :: ?>  (are-coordinates-valid [x y])
      ip
    ::  container for pin content revisions
    ::  structural node with no content
    ::
        [@ %pin ~]
      ?>  ?=(~ contents.p.ip)
      ip
    ::  specific pin revision
    ::  content node with data format [title body]
    ::
        [@ %pin @ ~]
      :: ?>  ?=([[%text *] [%text *] ~] contents.p.ip)
      =/  contents  contents.p.ip
      :: =/  title  +.i.contents  :: TODO make this actually work
      :: =/  body   +.t.contents  :: aa
      :: ~&  title
      :: ~&  body
      ::  ?>  (lte (lent title) max-length-title)
      ::  ?>  (lte (lent body) max-length-body)
      ip
    ==
  --
++  grad  %noun
--
