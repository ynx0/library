/-  *post, met=metadata-store, graph=graph-store
=>
|%
++  is-title-valid
  |=  [title=tape]
  ^-  ?
  %.y
++  is-isbn-valid  :: we could do https://github.com/xlcnd/isbnlib/blob/41f59c74a69a2675c3f135431e9785f9ae502a7e/isbnlib/_core.py#L52
  |=  [isbn=tape]
  ^-  ?
  =/  len  (lent isbn)
  ?>  ?|(=(len 10) =(len 13))
  %.y
--
|_  i=indexed-post
++  grow
  |%
  ++  noun  i
  ::
  ++  graph-indexed-post
    ^-  indexed-post
    ?+    index.p.i  !!
    ::  top level node: book
    ::  structural node with no content
    ::
        [@ ~]
      ~|  "top level book node should be empty!"
      ?>  ?=(~ contents.p.i)
      i
    ::  metadata revision container
    ::  structural node with no content
    ::
        [@ %meta ~]
      ~|  "metadata revision container should be empty!"
      ?>  ?=(~ contents.p.i)
      i
    ::  single metadata revision
    ::  content node. first %text element is treated as title,
    ::  second is treated as isbn
    ::
        [@ %meta @ ~]
      =/  contents  contents.p.i
      ?>  ?=([[%text *] [%text *] ~] contents.p.i)
      =/  title  (trip +.i.contents.p.i)
      ?>  (is-title-valid title)
      =/  isbn  (trip +.i.t.contents.p.i)
      ?>  (is-isbn-valid isbn)
      i
    ::  comments section container
    ::  structural node with no content
    ::
        [@ %comments ~]
      ~|  "comments section container should be empty!"
      ?>  ?=(~ contents.p.i)
      i
    ::  comment
    ::
        [@ %comments @ ~]
      :: we could allow any content eventually
      ::?>  ?=(* contents.p.i)  :: any content is allowed.
      ?>  ?=([[%text *] ~] contents.p.i)  :: only a single %text content is allowed
      =/  contents  contents.p.i
      i
    ==
  ::  optional arm used mainly by graph-push-hook.
  ++  transform-add-nodes
    |=  [=index =post =atom was-parent-modified=?]
    :: todo this needs to be implemented properly (?)
    :: based off of publish, doesn't take parent-modified into account
    ^-  [^index ^post]
    :: trust all incoming indexes by default, don't modify them
    :: we could also do something with the post if we wanted, like forcing all coords to be valid
    ::=/  transformed-index
    ::  ?+    index  ~|(transform+[index post] !!)
    ::      [@ ~]          index
    ::      [@ %meta ~]    index
    ::      [@ %pin ~]     index
    ::      [@ %meta @ ~]  index
    ::      [@ %pin @ ~]   index
    ::  ==
    ::[transformed-index post(index transformed-index)]
    [index post]
  ::
  ++  notification-kind  `[%message [0 1] %count %none]
  ::
  --
++  grab
  |%
  ++  noun  indexed-post
  --
++  grad  %noun
--
