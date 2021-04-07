/-  *post, met=metadata-store, graph=graph-store
=>
|%
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
    |=  vip=vip-metadata:met
    ^-  permissions:graph
    ?+  index.p.i  !!
      [@ ~]          [%yes %yes %no]
      [@ %meta ~]    [%self %self %no]
      [@ %meta @ ~]  [%yes %self %no]
      [@ %pin ~]     [%self %self %no]
      [@ %pin @ ~]   [%self %self %no]
    ==
  ::
  ++  graph-permissions-remove
    |=  vip=vip-metadata:met
    ^-  permissions:graph
    ?+  index.p.i  !!
      [@ ~]          [%yes %self %no]
      [@ %meta ~]    [%no %no %no]
      [@ %meta @ ~]  [%yes %self %no]
      [@ %pin ~]     [%no %no %no]
      [@ %pin @ ~]   [%yes %self %no]
    ==
  ++  transform-add-nodes
    |=  [=index =post =atom was-parent-modified=?]
    :: todo this needs to be implemented properly
    :: based off of publish, doesn't take parent-modified into account
    ^-  [^index ^post]
    =-  [- post(index -)]
    ?+    index  ~|(transform+[index post] !!)
        [@ ~]          [atom ~]
        [@ %meta ~]    [atom %meta ~]
        [@ %pin ~]     [atom %pin ~]
        [@ %meta @ ~]  [i.index %meta atom ~]
        [@ %pin @ ~]   [i.index %meta atom ~]
    ==
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
      ~|  "top level pin node should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  metadata revision container
    ::  structural node with no content
    ::
        [@ %meta ~]
      ~|  "metadata revision container should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  single metadata revision
    ::  content node with data format [x y] specifying x and y coordinates of the pinboard
    ::
        [@ %meta @ ~]
      ?>  ?=([[%text *] [%text *] ~] contents.p.ip)
      =/  contents  contents.p.ip
      ~|  "coordinates aren't valid numbers"
      =/  x  (slav %ud +.i.contents)
      =/  y  (slav %ud +.i.t.contents)
      ~|  "invalid coordinates {<x>} {<y>}"
      ?>  (are-coordinates-valid [x y])
      ip
    ::  container for pin content revisions
    ::  structural node with no content
    ::
        [@ %pin ~]
      ~|  "pin revision container should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  specific pin revision
    ::  content node with data format [title body]
    ::
        [@ %pin @ ~]
      ?>  ?=([[%text *] [%text *] ~] contents.p.ip)
      =/  contents  contents.p.ip
      =/  title=tape  (trip +.i.contents)
      =/  body=tape   (trip +.i.t.contents)
      ~|  "title too long"
      ?>  (lte (lent (tuba title)) max-length-title)  :: tuba normalizes things like emojis to count as one character
      ~|  "body too long"
      ?>  (lte (lent (tuba body)) max-length-body)
      ip
    ==
  --
++  grad  %noun
--

