/-  spider
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures
=,  strand=strand:spider
:: =>  :: do i need this? spider guide 
|%
++  get-last-revision-node
:: |=  [uid, index=atom]??
++  incr-index  !!
--
^-  thread:spider 
|=  arg=vase 
=/  m  (strand ,vase) 
^-  form:m
=+  !<([=uid [x=@ud y=@ud] ~] arg)
=/  last-meta=node (get-last-revision-node)
=|  new-meta=post
=:  author.new-meta    our
    index.new-meta     (incr-index index.p.last-meta)
    time-sent          now
    contents.new-meta  (make-contents [x y])
:: (add-nodes [index.post [post]])
:: replace contents with new [x and y]
:: replace index with +(index.latest-meta)
:: call add-nodes thread with new node
::
::               LOGIC
:: Given a uid to a specific pin on a specific graph
:: Given the new x=@ud and y=@ud
:: Get the latest revision node that exists
:: Make a new revision node with [%text (convert x into cord)] [%text (convert y into cord)] as contents
:: increment the number from the index of the latest revision node
:: start an add-nodes thread with the newly created node 
::
::
:: ;<  t=@da   bind:m  get-time:strandio
:: ;<  s=ship  bind:m  get-our:strandio
(pure:m !>(~))
