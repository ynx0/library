/+  store=graph-store, graph, default-agent,
    dbug, verb
:: todo extract out following to sur/library.hoon
=>
|%
+$  book
  $:
    !!
  ==
::
+$  command
  $%  [%update-permissions top=@ ships=(set ship)] ::  only our can poke
      [%add-book =book]                            :: only our can poke
      [%remove-book top=@]                         :: only our can poke
  ==
::
+$  action
  $%  [%add-annotation =annotation]                :: anyone (based on permissions)
      [%remove-annotation =index]                :: anyone (based on permissions)
  ==
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-null  ~
+$  base-state-0
  $:
    allowed-users=(map ship (set resource))
  ==
::
+$  state-0  [%0 base-state-0]
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
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%skeleton initialized successfully'
  :: subscribe to graph store updates here
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%skeleton recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %library-proxy-command
    ?>  =(our.bowl src.bowl)
    (handle-command:hc !<(command vase))
    ::
      %library-proxy-action
    (handle-action:hc !<(action vase))
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
      :: todo
          %graph-update-1
        (handle-graph-update:hc !<(update:graph q.cage.sign))
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
    ?>  =(src.bowl +<.path)  :: check for imposter
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
  ?-  -.command
    %update-permissions
  :: add the ship to the jug by key of top
    %add-book
  :: create a graph update and send it to local graph store using the book
    %remove-book
  :: create a graph update to remove the book based on the index and send it to local graph store 
  --

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