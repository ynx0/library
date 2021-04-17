/+  store=graph-store, graph, default-agent,
    dbug, verb
::
::  Use case:
::  Every ship can have multiple pinboards stored in their graph store
::  Every ship can want to expose the different pinboards based on some basic permissioning scheme
::  Every ship can want to subscribe to other's pinboards
::  Every ship can want to update to other's pinboards (and their own)
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 counter=@]
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%skeleton initialized successfully'
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
  :: someone is trying to update my local graph store, specifically a pinboard
  :: 1. do some permissions logic,
  :: 2. then if allowed, poke the local graph store with the supplied update
  :: 3. otherwise ?? dunno the std poke nack behaviour
  `this
::
++  on-watch  on-watch:def
::  on watch: someone is trying to subscribe to a pinboard on my local graph-store
::  1. do some basic permissions logic based on the path
::    a. dunno exactly how the paths would work here.
::  2. if it passes, 
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
