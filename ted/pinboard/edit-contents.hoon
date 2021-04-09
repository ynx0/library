/-  spider
/+  strandio, store=graph-store, pinboard
=,  strand=strand:spider
:: TODO use uid instead of resource + top index. but does this really make sense?
::                     LOGIC
:: Given a resource and top level index fragment to a specific pin on a specific graph
:: Given the new title and body
:: Get the latest revision node that exists
:: Create a new update with the revision node
:: start an add-nodes thread with the newly created node
^-  thread:spider 
|=  arg=vase
=/  m  (strand ,~)
^-  form:m
=+  !<([~ [=ship name=term] top=@ new-title=cord new-body=cord] arg)
;<  =bowl:spider         bind:m   get-bowl:strandio
;<  pin-rev-container=node   bind:m  (got-node:pinboard [ship name] ~[top %pin])
=/  last-pin-rev=node  (get-latest-node:pinboard +.children.pin-rev-container)
=/  add-pin-rev-update=update:store
  (pin-rev-update:pinboard [ship name] top our.bowl now.bowl new-title new-body last-pin-rev)
;<  tid=tid:spider  bind:m
  (start-thread-with-args:strandio %graph-add-nodes !>([~ add-pin-rev-update]))
(pure:m !>(~))
