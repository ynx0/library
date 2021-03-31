/-  *graph-store, post
:: TODO extract shared logic into a core with inferior/nested arms?
:: TODO these arms are wrong, they need to take in both a resource and a face representing our
|%
++  incr-index  :: rename to something clearer
  |=  [=index:post]
  ^-  index:post
  ?>  =(3 (lent index))  :: must be of form like [1 %meta 1]
  =/  old-index-frag=atom  (snag 2 a)  :: get the 3rd value from the index
  (snap a 2 (add 1 old-index-frag))    :: replace the 3rd value of index with incremented index
++  make-meta-contents  :: todo rename to something clearer
  |=  [x=@ud y=@ud]
  ^-  contents
  ~[[%text `@t`(scot %ud x)] [%text `@t`(scot %ud y)]]
++  make-pin-contents  :: todo rename to something clearer
  |=  [title=cord body=cord]
  ^-  contents
  ~[[%text title] [%text body]]
::
::
::
:: creating a new pin
++  add-pin-update
  |=  [[=ship name=term] top=@ time-sent=time title=cord body=cord coords=[x=@ud y=@ud]]
  ^-  update
  :+  %0  now
  :+  %add-nodes  [ship name]
  %-  ~(gas by *(map index node))
  =|  blank=post
  =:  author.blank     author
      time-sent.blank  time-sent
      contents.blank   ~
  ==
  =/  pin-contents
    ~[[%text title] [%text body]]
  =/  meta-contents  (make-coord-contents coords)
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
  |=  [[=ship name=term] top=@ time-sent=time new-coords=[x=@ud y=@ud] last-revision-index=index]
  :: todo use uid and assert that index is len 1 representing ref to a pin
  :: todo rename ship to author
  ^-  update
  =/  meta-index              (incr-index last-revision-index)
  =/  meta-contents=contents  (make-meta-contents new-coords)
  =|  meta-post=post
  =:  author.meta-post     ship
      index.meta-post      meta-index
      time-sent.meta-post  time-sent
      contents.meta-post   meta-contents
  :+  %0  now
  :+  %add-nodes  [ship name]
  %-  ~(gas by *(map index node))
  ~[meta-index [meta-post [%empty ~]]]
:: creating a new pin content revision
++  pin-rev-update
  |=  [[=ship name=term] top=@ time-sent=time new-title=cord new-body=cord last-revision-index=index]
  :: todo use uid and assert that index is len 1 representing ref to a pin
  :: todo rename ship to author
  ^-  update
  =/  pin-index              (incr-index last-revision-index)
  =/  pin-contents=contents  [(make-pin-contents coords)]
  =|  pin-post=post
  =:  author.pin-post     ship
      index.pin-post      meta-index
      time-sent.pin-post  time-sent
      contents.pin-post   meta-contents
  :+  %0  now
  :+  %add-nodes  [ship name]
  %-  ~(gas by *(map index node))
  ~[pin-index [pin-post [%empty ~]]]
:: deleting a pin from a graph
++  remove-pin-update
  |=  [[=ship name=term] top=@ time-sent=time]  :: todo take in a resource
  ^-  update
  :+  %0  time-sent
  :+  %remove-nodes  [ship name]
  (sy ~[[top ~]])
--
