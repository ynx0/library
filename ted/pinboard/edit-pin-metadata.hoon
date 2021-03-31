/-  spider, post
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures, pinboard
=,  strand=strand:spider
:: todo use uid instead of resource + top index
=>
|%
++  get-last-revision-node
  |=  [=node node-type=?(%pin %meta)]
  :: head of bap:ordered-map of all nodes under [top node-type]
  !!
++  get-specific-pin-by-top-index  :: todo rename to something better
  |=  [rid=resource:store top=@]
  :: =/  m  (strand ,graph:store)
  =/  m  (strand ,~)
  ^-  form:m
  ;<  =update:store  bind:m
    %+  scry:strandio  update:store
    /gx/graph-store/node/(scot %p entity.rid)/[name.rid]/(scot %ud top)/noun
  ?>  ?=(%0 -.update)
  ?>  ?=(%add-nodes -.q.update)
  =/  nodes  nodes.q.update
  :: ~&  update
  ~&  node-keys
  :: (pure:m q.update)
  (pure:m ~)
--
::                     LOGIC
:: Given a uid to a specific pin on a specific graph
:: Given the new x=@ud and y=@ud
:: Get the latest revision node that exists
:: Make a new revision node with [%text (convert x into cord)] [%text (convert y into cord)] as contents
:: increment the number from the index of the latest revision node
:: start an add-nodes thread with the newly created node 
^-  thread:spider 
|=  arg=vase
:: TODO get bowl for our and now
=/  m  (strand ,vase)
^-  form:m
=+  !<([~ [=ship name=term] top=@ [x=@ud y=@ud]] arg)
:: =/  last-meta=node (get-last-revision-node uid)
:: =|  new-meta=post
:: =:  author.new-meta    our
::    index.new-meta     (incr-index index.p.last-meta)
::    time-sent          now
::    contents.new-meta  (make-contents [x y])
:: =/ add-meta-rev-update=update:store  (meta-rev-update:pinboard [[ship name] top now [x y] index.last-meta])
:: ;<  tid=tid:spider   bind:m  (start-thread-with-args %graph-add-nodes !>(add-meta-rev-update))
;<  =graph:store  bind:m  (get-specific-pin-by-top-index [ship name] top)
(pure:m !>(~))
