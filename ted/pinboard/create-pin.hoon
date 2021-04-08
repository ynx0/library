/-  spider
/+  strandio, store=graph-store, pinboard
=,  strand=strand:spider
:: TODO use uid instead of resource + top index. but does this really make sense?
:: TODO design thought: landscape uses `@da`now  rather than sequetial indexing. should i use this instead?
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
=+  !<([~ [=ship name=term] title=cord body=cord coords=[x=@ud y=@ud]] arg)
;<  =bowl:spider   bind:m   get-bowl:strandio
;<  =update:store  bind:m
    %+  scry:strandio  update:store  /gx/graph-store/graph/(scot %p ship)/[name]/graph-update-1
=/  board  ;;(graph:store +>-.q.update)
=/  last-pin=node:store  (need (get-latest-node:pinboard board))  :: this needs to later become an if statement that if null, then top is 1
=/  top=@  (add 1 (snag 0 index.post.last-pin))
=/  pin-update=update:store  (add-pin-update:pinboard [[ship name] top our.bowl now.bowl title body coords])
;<  ~  bind:m   (poke-our:strandio %graph-store %graph-update-1 !>(pin-update))  :: bypass %graph-push-hook, which fails during transform
::;<  tid=tid:spider       bind:m
  ::(start-thread-with-args:strandio %graph-add-nodes !>([~ pin-update]))  :: appears to be that this doesn't get properly called. yeah it is erroring out silently
(pure:m !>(~))  

