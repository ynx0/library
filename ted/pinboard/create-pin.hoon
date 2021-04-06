/-  spider
/+  strandio, graph-store, pinboard
=,  store=zero:graph-store
=,  strand=strand:spider
:: TODO use uid instead of resource + top index. but does this really make sense?
::                     LOGIC
:: Given a resource and top level index fragment to a specific pin on a specific graph
:: Given the title and body
:: Get the latest pin node that exists
:: Create a new update with the new pin
:: start an add-nodes thread with the newly created pin
^-  thread:spider 
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([~ [=ship name=term] top=@ title=cord body=cord coords=[x=@ud y=@ud]] arg)
;<  =bowl:spider         bind:m   get-bowl:strandio
;<  pin=node             bind:m  (got-node:pinboard [ship name] ~[top])
=/  last-pin=node  (get-latest-node:pinboard pin-container)
=/  add-pin-update=update:store  (add-pin-update:pinboard [[ship name] top our.bowl now.bowl title text coords])
;<  tid=tid:spider  bind:m
  (start-thread-with-args:strandio %graph-add-nodes !>([~ add-pin-update]))
(pure:m !>(~))
