/-  *post, *resource, spider
/+  *graph-store, strandio
:: TODO extract shared logic into a core with inferior/nested arms?
:: TODO these arms are wrong, they need to take in both a resource and a face representing our
|%
:: Thread Only Functions: Can only be called as a strand/ in a spider context
++  scry-for
  :: unholy child of
  :: https://github.com/urbit/urbit/blob/9c9446d77f0969846b1cebd12f6290d513375ad4/pkg/arvo/lib/graph.hoon#L4
  :: and https://github.com/urbit/urbit/blob/ab4356ea88f531788845dd47efe0b571dd1ae446/pkg/arvo/ted/graph/add-nodes.hoon#L6
  |*  [=mold =path]
  =/  m  (strand:spider ,mold)
  ^-  form:m
  ;<  result=mold   bind:m
    %+  scry:strandio  mold  (weld /gx/graph-store (snoc `^path`path %noun))
  (pure:m result)
::
++  got-node
  ::  based off of https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/graph.hoon#L65-L67
  |=  [res=resource =index]
  =/  m  (strand:spider ,node)
  ^-  form:m
  ;<  =update  bind:m  (scry-for update (weld /node/(scot %p entity.res)/[name.res] (turn index (cury scot %ud))))
  ?>  ?=(%add-nodes -.update)
  ::?>  ?=(^ nodes.q.update)  :: might not work
  =/  out-node  ;;(node +>->.q.update)  :: this is really ugly code. gotta figure out how not to use +>->
  (pure:m out-node)
  ::(pure:m *node)
::
++  get-latest-node
  ::|=  [rev-container-node=node]
  |=  [=graph]
  ^-  (unit node)
  :: todo proper unit code
  :: unwrapped: given a revision container node:
  :: 1. get its children, which nets a graph of all revisions
  :: 2. discard the leading %graph term
  :: 3. listify the children, with greatest key first
  :: 4. get the first element of the list
  :: 5. get the value from key/value pair of key = index fragment, val = node
  ::=/  revisions  +.children.rev-container-node
  =/  node-list=(list (pair atom node))  (tap:orm graph)
  ::?~  node-list  ~  :: why doesn't this line work????? i literally had it working like 2 seconds ago AHhhh
  =/  latest-node  (snag 0 node-list)
  [~ +:latest-node]
  
::
++  incr-index  :: rename to something clearer
  |=  [=index:post]
  ^-  index:post
  ?>  =(3 (lent index))                    :: index must be of form like [1 %meta 1] or [1 %pin 1]
  =/  old-index-frag=atom  (snag 2 index)  :: get the 3rd value from the index
  (snap index 2 (add 1 old-index-frag))    :: replace the 3rd value of index with incremented index
::
++  make-meta-contents
  |=  [x=@ud y=@ud]
  ^-  (list content)
  ~[[%text `@t`(scot %ud x)] [%text `@t`(scot %ud y)]]
::
++  make-pin-contents
  |=  [title=cord body=cord]
  ^-  (list content)
  ~[[%text title] [%text body]]
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
  :-  time-sent
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
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[meta-index [meta-post [%empty ~]]]]
::
:: creating a new pin content revision
++  pin-rev-update
  |=  [rid=resource top=@ author=ship time-sent=time new-title=cord new-body=cord last-revision-node=node]
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
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[pin-index [pin-post [%empty ~]]]]
::
:: deleting a pin from a graph
++  remove-pin-update
  |=  [rid=resource top=@ time-sent=time]
  ^-  update
  :-  time-sent
  :+  %remove-nodes  rid
  (sy ~[[top ~]])
--
