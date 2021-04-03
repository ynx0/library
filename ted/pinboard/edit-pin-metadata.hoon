/-  spider, *graph-store
/+  strandio, store=graph-store, pinboard
=,  strand=strand:spider
:: TODO use uid instead of resource + top index. but does this really make sense?
::                     LOGIC
:: Given a resource and top level index fragment to a specific pin on a specific graph
:: Given the new x=@ud and y=@ud
:: Get the latest revision node that exists
:: Make a new revision node with [%text (convert x into cord)] [%text (convert y into cord)] as contents
:: increment the number from the index of the latest revision node
:: start an add-nodes thread with the newly created node 
^-  thread:spider 
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([~ [=ship name=term] top=@ [x=@ud y=@ud]] arg)
;<  =bowl:spider         bind:m   get-bowl:strandio
;<  meta-container=node  bind:m  (got-node:pinboard [ship name] ~[top %meta])
=/  last-meta=node  (get-latest-revision-node:pinboard meta-container)
=/  add-meta-rev-update=update:store
  (meta-rev-update:pinboard [ship name] top our.bowl now.bowl [x y] last-meta)
;<  tid=tid:spider  bind:m
  (start-thread-with-args:strandio %graph-add-nodes !>([~ add-meta-rev-update]))
(pure:m !>(~))
