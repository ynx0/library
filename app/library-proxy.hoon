/-  *resource, *library
/+  store=graph-store, graph, default-agent,
    dbug, verb, agentio
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 base-state-0]
+$  base-state-0
  $:
    =permissions
  ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this    .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
    io    ~(. agentio bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%library-proxy initialized successfully'
  :: subscribe to graph store updates here
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%library-proxy recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
  ?+    mark  (on-poke:def mark vase)
      %library-proxy-command
    ?>  =(our.bowl src.bowl)  :: only we can poke with a `command`
    =+  !<(command vase)
    ?-    -.command
        %update-permissions
      =/  rid    rid.command
      =/  top    top.command
      =/  ships  ships.command
      =/  prm=prim  (~(gas by *prim) (my top ships))
      =/  new-state
      ?-    operation.command
          %add
        (~(put ju permissions.state) prm)
          %remove
        (~(del ju permissions.state) prm)
      `this(state new-state)
    ::
        %add-book
    :: create a graph update and send it to local graph store using the book
    =/  rid   rid.command
    =/  book  book.command
    =/  update  (add-book-update rid src.bowl now.bowl book)
    ::=/  update  update.command  :: if we're just purely forwarding graph updates
    ::  [delete later] the second item in cell is ~ which is actually the return path we want the poke-ack to 
    ::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
      %remove-book
    :: create a graph update to remove the book based on the index and send it to local graph store 
    =/  update  (remove-book-update rid.command top.command now.bowl)
    ::=/  update  update.command
    ::?>  =(%remove-nodes -.q.update)
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
    ::
      %library-proxy-action
    =/  src  src.bowl
    =+  !<(action vase)
    ?-  -.action
      %add-comment
    :: TODO assert that the person has permissions to the book.
    ?>  %.y
    =/  rid  rid.action
    =/  top  top.action
    =/  =comment:library  comment.action
    =/  update  (add-comment-update rid top src.bowl now.bowl comment)
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
      %remove-comment
    ::  TODO how do we only allow author of comment to remove their own comment
    ::  get old node, see if it the same author as src.bowl, only then allow removal
    ?>  %.y
    =/  rid            rid.action
    =/  comment-index  index.action
    =/  update  (remove-comment-update rid comment-index now.bowl)
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
  ==
  [cards this]
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    ~&  >>>  "kicked from graph store subscription"
    `this
    ::
      %fact
    =^  cards  state
      ?+  p.cage.sign  `state
          %graph-update-1
        :: todo
        ::=+  !<(update:graph q.cage.sign)
        ::(handle-graph-update:hc !<(update:graph q.cage.sign))
        ::
      ==
  [cards this]
  ==

::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =^  cards  state
  ?+  path  (on-watch:def path)
    [%updates ship ~]
    :: check for imposter
    :: only allow ship ~zod to subscribe on /updates/~zod , no one else
    ?>  =(src.bowl +<.path)
    `this
  ==
  [cards this]

::  on watch: someone is trying to subscribe to a pinboard on my local graph-store
::  1. do some basic permissions logic based on the path
::    a. dunno exactly how the paths would work here.
::  2. if it passes, 
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|_  =bowl:gall
++  handle-command
  |=  [=command]
  ^-  (quip card _state)
  =^  cards  state  ~
  !!
++  handle-action
  |=  [*]
  !!
++  handle-graph-update
  |=  [=update:graph]
  ::  this is where we proxy / forward any graph store updates
  ::  to any subscriber based on 
  !!
::
++  poke-graph-store
  |= [*]
  !!
--
