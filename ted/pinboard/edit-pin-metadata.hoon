/-  spider
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures, post
=,  strand=strand:spider
:: =>  :: do i need this? spider guide
|%
++  get-last-revision-node  !!
:: |=  [uid, index=atom]
++  incr-index
  |=  [=index:post]
  ^-  index:post
  ?>  =(3 (lent index))  :: must be of form like [1 %meta 1]
  =/  old-index-frag=atom  (snag 2 a)  :: get the 3rd value from the index
  (snap a 2 (add 1 old-index-frag))    :: replace the 3rd value of index with incremented index
++  make-contents  :: todo move this into lib
  |=  [x=@ud y=@ud]
  [[%text `@t`(scot %ud x)] [%text `@t`(scot %ud y)]]
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
=/  m  (strand ,vase) 
^-  form:m
=+  !<([=uid [x=@ud y=@ud] ~] arg)
=/  last-meta=node (get-last-revision-node uid)
=|  new-meta=post
=:  author.new-meta    our
    index.new-meta     (incr-index index.p.last-meta)
    time-sent          now
    contents.new-meta  (make-contents [x y])
=/ add-meta-rev-update=update:store
  :+  %0  now
  :+  %add-nodes  [our %some-date-time1]
  %-  ~(gas by *(map index:store node:store))
  :~([meta-index [blank(index meta-index, contents meta-contents) [%empty ~]]])
;<  tid=tid:spider   bind:m  (start-thread-with-args %graph-add-nodes !>(add-meta-rev-update))
(pure:m !>(~))
