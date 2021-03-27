/-  spider
/+  strandio, store=graph-store, gra=graph, graph-view, sig=signatures
=,  strand=strand:spider 
^-  thread:spider 
|=  arg=vase 
=/  m  (strand ,vase) 
^-  form:m
=+  !<([=uid [x=@ud y=@ud] ~] arg)
:: =/  latest-meta=node (get-latest-revision-node)
:: =|  
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
