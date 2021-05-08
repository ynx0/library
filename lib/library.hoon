/-  *post, *resource, library, spider
/+  *graph-store, strandio
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
  ?>  ?=(%add-nodes -.q.update)
  ?>  ?=(^ nodes.q.update)  :: might not work
  =/  out-node  ;;(node +>->.q.update)  :: this is really ugly code. gotta figure out how not to use +>->
  (pure:m out-node)
::
++  get-latest-node
  |=  [=graph]
  ^-  (unit node)
  :: todo proper unit code
  :: todo, make ?> assertions so that you don't have to use lark syntax
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
::
++  incr-index
  :: increments the last value in the index by 1
  |=  [=index:post]
  ^-  index:post
  =/  last=@  (sub (lent index) 1)  :: calculate the array index of the last item
  =/  old-revision-count=atom  (snag last index)  :: get the last item
  (snap index last (add 1 old-revision-count))    :: replace the value of last item with 1 added to it
::
++  make-meta-contents
  |=  [=book:library]
  ^-  (list content)
  ~[[%text (crip title.book)] [%text (crip isbn.book)]]
::
++  make-comment-contents
  |=  [comment-text=comment:library]
  ^-  (list content)
  ~[[%text (crip comment-text)]]
::
::
++  add-book-update
  :: creating a new book under a library
  |=  [rid=resource author=ship time-sent=time =book:library]
  ^-  update
  =|  blank=post
  =:  author.blank     author
      time-sent.blank  time-sent
      contents.blank   ~
  ==
  =/  meta-contents  (make-meta-contents book)
  =/  top  time-sent
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  :~
      [~[top] [[%.y blank(index ~[top])] [%empty ~]]]
      [~[top %meta] [[%.y blank(index ~[top %meta])] [%empty ~]]]
      [~[top %meta 1] [[%.y blank(index ~[top %meta 1], contents meta-contents)] [%empty ~]]]
      [~[top %comments] [[%.y blank(index ~[top %comments])] [%empty ~]]]
  ==
::
++  remove-book-update
  |=  [rid=resource top=@ time-sent=time]
  ^-  update
  :-  time-sent
  :+  %remove-posts  rid
  (sy ~[[top ~]])
::
++  revise-meta-update
  |=  [rid=resource last-revision-index=index author=ship time-sent=time =book:library]
  ^-  update
  =/  meta-index=index:post           (incr-index last-revision-index)
  =/  meta-contents=(list content)    (make-meta-contents book)
  =|  meta-post=post
  =:  author.meta-post     author
      index.meta-post      meta-index
      time-sent.meta-post  time-sent
      contents.meta-post   meta-contents
  ==
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[meta-index [[%.y meta-post] [%empty ~]]]]
::
++  add-comment-update
  :: creating a new comment
  |=  [rid=resource top=@ author=ship time-sent=time =comment:library]
  ^-  update
  =/  comment-index=index  ~[top %comments time-sent]
  =/  comment-contents     (make-comment-contents comment)
  =|  comment-post=post
  =:  author.comment-post     author
      index.comment-post      comment-index
      time-sent.comment-post  time-sent
      contents.comment-post   comment-contents
  ==
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  ~[[comment-index [[%.y comment-post] [%empty ~]]]]
::
++  remove-comment-update
  |=  [rid=resource comment-index=index time-sent=time]
  ^-  update
  ~|  "invalid index {<comment-index>} provided"
  ?>  =((lent comment-index) 3)
  :-  time-sent
  :+  %remove-posts  rid
  (sy ~[comment-index])
--