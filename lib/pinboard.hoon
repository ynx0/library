/-  *graph-store, *post, *resource, spider
/+  store=graph-store, strandio
:: TODO extract shared logic into a core with inferior/nested arms?
:: TODO these arms are wrong, they need to take in both a resource and a face representing our
|%
::  Thread Stuff
::  TODO should this even go here? ask ~mip
++  scry-for
  :: unholy child of
  :: https://github.com/urbit/urbit/blob/9c9446d77f0969846b1cebd12f6290d513375ad4/pkg/arvo/lib/graph.hoon#L4
  :: and https://github.com/urbit/urbit/blob/ab4356ea88f531788845dd47efe0b571dd1ae446/pkg/arvo/ted/graph/add-nodes.hoon#L6
  |*  [=mold =path]
  =/  m  (strand:spider ,mold)  :: this already looks scary. wet gate, strand defined by a parametric type?? oh my
  ^-  form:m
  ;<  result=mold   bind:m
    %+  scry:strandio  mold  (weld /gx/graph-store (snoc `^path`path %noun))
  (pure:m result)
++  got-node
  ::  based off of https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/graph.hoon#L65-L67
  |=  [res=resource =index:store]
  =/  m  (strand:spider ,node:store)
  ^-  form:m
  ;<  =update:store  bind:m  (scry-for update:store (weld /node/(scot %p entity.res)/[name.res] (turn index (cury scot %ud))))
  ?>  ?=(%0 -.update)
  ?>  ?=(%add-nodes -.q.update)
  ?>  ?=(^ nodes.q.update)
  (pure:m q.n.nodes.q.update)
++  get-latest-revision-node
  |=  [rev-container-node=node:store]
  ^-  node:store
  val:(snag 0 (tap:orm:store +.children.rev-container-node))
::
++  incr-index  :: rename to something clearer
  |=  [=index:post]
  ^-  index:post
  ?>  =(3 (lent index))  :: must be of form like [1 %meta 1]
  =/  old-index-frag=atom  (snag 2 index)  :: get the 3rd value from the index
  (snap index 2 (add 1 old-index-frag))    :: replace the 3rd value of index with incremented index
::
++  make-meta-contents  :: todo rename to something clearer
  |=  [x=@ud y=@ud]
  ^-  (list content)
  ~[[%text `@t`(scot %ud x)] [%text `@t`(scot %ud y)]]
::
++  make-pin-contents  :: todo rename to something clearer
  |=  [title=cord body=cord]
  ^-  (list content)
  ~[[%text title] [%text body]]
::
::
::
:: creating a new pin
++  add-pin-update
  |=  [rid=resource top=@ author=ship time-sent=time title=cord body=cord coords=[x=@ud y=@ud]]
  ^-  update
  =|  blank=post
  =:  author.blank     author
      time-sent.blank  time-sent
      contents.blank   ~
  ==
  =/  pin-contents   (make-pin-contents title body)
  =/  meta-contents  (make-meta-contents coords)
  :+  %0  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  :~
      [~[top] [blank(index ~[top]) [%empty ~]]]
      [~[top %meta] [blank(index ~[top %meta]) [%empty ~]]]
      [~[top %meta 1] [blank(index ~[top %meta 1], contents meta-contents) [%empty ~]]]
      [~[top %pin] [blank(index ~[top %pin]) [%empty ~]]]
      [~[top %pin 1] [blank(index ~[top %pin 1], contents pin-contents) [%empty ~]]]
  ==
::
:: creating a new metadata revision
++  meta-rev-update
  |=  [rid=resource top=@ author=ship time-sent=time new-coords=[x=@ud y=@ud] last-revision-node=node]
  :: todo use uid and assert that index is len 1 representing ref to a pin
  :: todo rename ship to author
  ^-  update
  =/  last-revision-index=index:post  index.post.last-revision-node
  =/  meta-index=index:post              (incr-index last-revision-index)
  =/  meta-contents=(list content)  (make-meta-contents new-coords)
  =|  meta-post=post
  =:  author.meta-post     author
      index.meta-post      meta-index
      time-sent.meta-post  time-sent
      contents.meta-post   meta-contents
  ==
  :+  %0  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[meta-index [meta-post [%empty ~]]]]
:: creating a new pin content revision
++  pin-rev-update
  |=  [rid=resource top=@ author=ship time-sent=time new-title=cord new-body=cord last-revision-node=node]
  :: todo use uid and assert that index is len 1 representing ref to a pin
  :: todo rename ship to author
  ^-  update
  =/  last-revision-index=index:post  index.post.last-revision-node
  =/  pin-index=index    (incr-index last-revision-index)
  =/  pin-contents       (make-pin-contents [new-title new-body])
  =|  pin-post=post:post
  =:  author.pin-post     author
      index.pin-post      pin-index
      time-sent.pin-post  time-sent
      contents.pin-post   pin-contents
  ==
  :+  %0  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[pin-index [pin-post [%empty ~]]]]
:: deleting a pin from a graph
++  remove-pin-update
  |=  [rid=resource top=@ time-sent=time]  :: todo take in a resource
  ^-  update
  :+  %0  time-sent
  :+  %remove-nodes  rid
  (sy ~[[top ~]])
--
