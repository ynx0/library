/-  spider, post, *graph-store
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures, pinboard
=,  strand=strand:spider
:: TODO get bowl for our and now
:: TODO use uid instead of resource + top index
=>
|%
++  scry-for
  :: unholy child of 
  :: https://github.com/urbit/urbit/blob/9c9446d77f0969846b1cebd12f6290d513375ad4/pkg/arvo/lib/graph.hoon#L4
  :: and https://github.com/urbit/urbit/blob/ab4356ea88f531788845dd47efe0b571dd1ae446/pkg/arvo/ted/graph/add-nodes.hoon#L6
  |*  [=mold =path]
  =/  m  (strand ,mold)  :: this already looks scary. wet gate, strand defined by a parametric type?? oh my
  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl:strandio  :: doing (get-bowl:strandio) causes a (gigantic) crash :(
  =/  fullpath=^path  (weld /gx/graph-store (snoc `^path`path %noun))
  ::~&  path
  ::~&  fullpath
  ;<  result=mold   bind:m
    %+  scry:strandio  mold  fullpath
  (pure:m result)
++  got-node
  :: similarly unholy hybrid threadified got-node from lib/graph.hoon
  |=  [res=resource =index:store]
  =/  m  (strand ,node:store)
  ^-  form:m
  ::  based off of https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/graph.hoon#L65-L67
  ;<  =update:store  bind:m  (scry-for update:store (weld /node/(scot %p entity.res)/[name.res] (turn index (cury scot %ud))))
  ?>  ?=(%0 -.update)
  ?>  ?=(%add-nodes -.q.update)
  ?>  ?=(^ nodes.q.update)
  ::~&  nodes.q.update
  (pure:m q.n.nodes.q.update)
:: ++  get-last-revision-node
  :: |=  [=node node-type=?(%pin %meta)]
  :: head of bap:ordered-map of all nodes under [top node-type]
  :: !!
:: ++  get-specific-pin-by-top-index  :: todo rename to something better
  :: |=  [rid=resource:store top=@]
  ::=/  m  (strand ,node)
  :: =/  m  (strand ,~)
  :: ^-  form:m
  ::;<  =update:store  bind:m
  ::  %+  scry:strandio  update:store
  ::  /gx/graph-store/node/(scot %p entity.rid)/[name.rid]/(scot %ud top)/noun
  ::?>  ?=(%0 -.update)
  ::?>  ?=(%add-nodes -.q.update)
  ::=/  nodes  nodes.q.update
  ::~&  nodes
  :: (got-nodes:store rid ~[top])
  ::(pure:m (got-node:gra nodes))
  :: (pure:m ~)
--
::                     LOGIC
:: Given a resource and top level index fragment to a specific pin on a specific graph
:: Given the new x=@ud and y=@ud
:: Get the latest revision node that exists
  ::  pin-node=the pin in question
  ::  latest-metadata revision = head of bap:ordered-map of all nodes in children of pin-node-meeta
:: Make a new revision node with [%text (convert x into cord)] [%text (convert y into cord)] as contents
:: increment the number from the index of the latest revision node
:: start an add-nodes thread with the newly created node 
^-  thread:spider 
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([~ [=ship name=term] top=@ [x=@ud y=@ud]] arg)
;<  meta-container=node  bind:m  (got-node [ship name] ~[top %meta])
::~&  meta-container
=/  last-meta=node     val:(snag 0 (tap:orm:store +.children.meta-container)) :: get the latest metadata revision
::~&  last-meta
::~&  key.last-meta
::~&  index.post.val.last-meta
::~&  (snag 2 index.post.val.last-meta)
::~&  `node:store`val.last-meta
;<  =bowl:spider  bind:m  get-bowl:strandio  :: doing (get-bowl:strandio) causes a (gigantic) crash :(
=/  add-meta-rev-update=update:store
  (meta-rev-update:pinboard [ship name] top our.bowl now.bowl [x y] last-meta)
~&  add-meta-rev-update
;<  tid=tid:spider  bind:m  (start-thread-with-args:strandio %graph-add-nodes !>([~ add-meta-rev-update]))
::;<  tid=tid:spider  bind:m  (await-thread:strandio %graph-add-nodes !>(add-meta-rev-update))  :: bad, doesn't work unless i re-ota my fakezod, which i don wanna do b/c graph-store has breaking changes that i don't wanna deal with
~&  tid
(pure:m !>(~))
