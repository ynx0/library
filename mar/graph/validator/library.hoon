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
  ++  graph-permissions-add
    |=  vip=vip-metadata:met
    ^-  permissions:graph
    !!
  ::
  ++  graph-permissions-remove
    |=  vip=vip-metadata:met
    ^-  permissions:graph
    !!
    ::==
  ++  transform-add-nodes
    |=  [=index =post =atom was-parent-modified=?]
    :: todo this needs to be implemented properly
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
  ++  noun
    |=  p=*
    =/  ip  ;;(indexed-post p)
    ?+    index.p.ip  !!
    ::  top level node: book
    ::  structural node with no content
    ::
        [@ ~]
      ~|  "top level book node should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  metadata revision container
    ::  structural node with no content
    ::
        [@ %meta ~]
      ~|  "metadata revision container should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  single metadata revision
    ::  content node. first %text element is treated as title,
    ::  second is treated as isbn
    ::
        [@ %meta @ ~]
      =/  contents  contents.p.ip
      ?>  ?=([[%text *] [%text *] ~] contents.p.ip)
      =/  title  (trip +.i.contents.p.ip)
      ?>  (is-title-valid title)
      =/  isbn  (trip +.i.t.contents.p.ip)
      ?>  (is-isbn-valid isbn)
      ip
    ::  comments section container
    ::  structural node with no content
    ::
        [@ %comments ~]
      ~|  "comments section container should be empty!"
      ?>  ?=(~ contents.p.ip)
      ip
    ::  comment
    ::
        [@ %comments @ ~]
      :: we could allow any content eventually
      ::?>  ?=(* contents.p.ip)  :: any content is allowed.
      ?>  ?=([[%text *] ~] contents.p.ip)  :: only a single %text content is allowed
      =/  contents  contents.p.ip
      ip
    ==
  --
++  grad  %noun
--
