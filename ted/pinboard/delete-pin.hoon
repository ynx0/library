/-  spider
/+  strandio, store=graph-store, pinboard
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
=+  !<([~ [=ship name=term] top=@] arg)
;<  =bowl:spider    bind:m  get-bowl:strandio
=/  remove-pin-update=update:store  (remove-pin-update:pinboard [[ship name] top our.bowl now.bowl])
;<  tid=tid:spider  bind:m
  (start-thread-with-args:strandio %graph-add-nodes !>([~ remove-pin-update]))
(pure:m !>(~))