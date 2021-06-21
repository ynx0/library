/-  *post, resource, library, spider
/+  *graph-store, strandio
|%
++  incr-index
  :: increments the last value in the index by 1
  |=  [=index:post]
  ^-  index:post
  =/  last=@                (sub (lent index) 1)  :: calculate the array index of the last item
  =/  old-revision-count=@  (snag last index)     :: get the last item
  (snap index last (add 1 old-revision-count))    :: replace the value of last item with 1 added to it
++  scry-for
  |*  [=mold =path]
  .^  mold
    %gx
    (scot %p our.bowl)
    %library-proxy
    (scot %da now.bowl)
    (snoc `^path`path %noun)
  ==
::
++  make-meta-contents
  |=  [=book:library]
  ^-  (list content)
  ~[[%text (crip title.book)] [%text (crip isbn.book)]]
++  make-comment-contents
  |=  [comment-text=comment:library]
  ^-  (list content)
  ~[[%text (crip comment-text)]]
::
++  is-allowed
  |=  [requester=ship host=ship =policy:library]
  ^-  ?
  ?:  =(requester host)  :: host is always allowed
    %.y
  ?-  -.policy
      %open       %.y
      %children   (team:title host requester)
      %whitelist  (~(has in ships.policy) requester)
  ==
++  index-to-path
  |=  [idx=index:post]
  ^-  path
  (turn idx (cury scot %ud))
::
::
++  create-library-update
  |=  [[owner=ship name=@tas] time-sent=time]
  ^-  update
  :-  time-sent
  :-  %add-graph
  :*  [owner name]
      *graph  :: the official thread uses (gas:orm ~ ~), which is equivalent
      [~ %graph-validator-library]
      %.n     :: don't overwrite an existing library
  ==
++  remove-library-update
  |=  [[owner=ship name=@tas] time-sent=time]
  ^-  update
  :-  time-sent
  :-  %remove-graph
  [owner name]
++  add-book-update
  |=  [rid=resource author=ship time-sent=time =book:library]
  ^-  update
  =|  blank=post
  =:  author.blank     author
      time-sent.blank  time-sent
      contents.blank   ~
  ==
  =/  meta-contents  (make-meta-contents book)
  ::  todo in scry .^  graph store for last update if doing ascending numeric order
  =/  top  time-sent
  :-  time-sent
  :+  %add-nodes  rid
  %-  ~(gas by *(map index node))
  :~  [~[top] [[%.y blank(index ~[top])] [%empty ~]]]
      [~[top %meta] [[%.y blank(index ~[top %meta])] [%empty ~]]]
      [~[top %meta 1] [[%.y blank(index ~[top %meta 1], contents meta-contents)] [%empty ~]]]
      [~[top %comments] [[%.y blank(index ~[top %comments])] [%empty ~]]]
  ==
::
++  remove-book-update
  |=  [rid=resource top=@ time-sent=time]
  :: todo this could be improved.
  :: right now it clears the post content of the top level structural node
  :: what would be better is to clear all of the indexes
  :: so we need to have a list of the indexes of all [top %meta @] revisions and all [top %comments @]
  :: right now, landscape also just deletes the top level node, using it as a "this post has been marked deleted"
  ::  and just hides the whole. so we can do this for now and have it be ok
  ^-  update
  :-  time-sent
  :+  %remove-posts  rid
  (silt ~[[top ~]])
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
  ?>  ?=([@ %comments @ ~] comment-index)
  :-  time-sent
  :+  %remove-posts  rid
  (silt ~[comment-index])
--