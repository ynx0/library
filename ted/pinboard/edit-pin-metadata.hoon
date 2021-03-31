/-  spider, post
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures, pinboard
=,  strand=strand:spider
:: =>  :: do i need this? spider guide
|%
++  get-last-revision-node  !!
:: |=  [uid, index=atom]
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
=+  !<([[=ship name=term] top=@ [x=@ud y=@ud] ~] arg)
=/  last-meta=node (get-last-revision-node uid)
=|  new-meta=post
=:  author.new-meta    our
    index.new-meta     (incr-index index.p.last-meta)
    time-sent          now
    contents.new-meta  (make-contents [x y])
=/ add-meta-rev-update=update:store  (meta-rev-update:pinboard [[ship name] top now [x y] index.last-meta])
;<  tid=tid:spider   bind:m  (start-thread-with-args %graph-add-nodes !>(add-meta-rev-update))
(pure:m !>(~))
