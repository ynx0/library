/-  *post, graph=graph-store
=>
|%
++  is-title-valid
  |=  [title=cord]
  ^-  ?
  %.y
++  is-isbn-valid  :: we could do https://github.com/xlcnd/isbnlib/blob/41f59c74a69a2675c3f1/isbnlib/_core.py#L52
  |=  [isbn=cord]
  ^-  ?
  =/  len  (met 3 isbn)
  ?|(=(len 10) =(len 13))
--
|_  i=indexed-post
++  grow
  |%
  ++  noun  i
  ::
  ++  notification-kind  `[%message [0 1] %count %none]
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
      =/  title  +.i.contents.p.i
      ?>  (is-title-valid title)
      =/  isbn   +.i.t.contents.p.i
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
      :: we could allow any content
      ::?>  ?=(* contents.p.i)  :: any content is allowed.
      ?>  ?=([[%text *] ~] contents.p.i)  :: only a single %text content is allowed
      =/  contents  contents.p.i
      i
    ==
  --
++  grab
  |%
  ++  noun  indexed-post
  --
++  grad  %noun
--
