/+  store=graph-store, graph, default-agent,
    dbug, verb
:: todo extract out following to sur/pinboard.hoon
=>
|%
+$  pin-contents
  $:
    title=cord
    body=cord
  ==
::
+$  pin-meta
  $:
    coords=[x=@ud y=@ud]
  ==
::
+$  pin
  $:
    author=ship
    pin-contents
    pin-meta
  ==
::
+$  diff
  $%  [%create-pinboard =path]                        ::  %create: create a pinboard at path
      [%delete-pinboard =path]                        ::  %delete: delete a pinboard at path
      [%add-pin =path =pin]                           ::  %message: add a pin to the pinboard at path
      :: TODO use =reference?
      [%edit-pin-meta =path top=@ =pin-meta]          ::  %edit-pin-meta: edit the metadata of a specific pin
      [%edit-pin-contents =path top=@ =pin-contents]  ::  %edit-pin-contents: edit the contents of a specific pin
  ==
::
+$  action
  $%  ::  %messages: append a list of messages to mailbox
      ::
      ::[%messages =path envelopes=(list envelope)]
      ::[%add-pins =path pins=(list pin)]  :: do we need this?
      diff
  ==
::
+$  update
  $%  [%initial =graphs:store]
      [%keys keys=(set path)]
      ::[%messages =path envelopes=(list envelope)]
      ::[%add-pins =path pins=(list pin)]  :: do we need this?
      diff
  ==
--
::  Use case:
::  Every ship can have multiple pinboards stored in their graph store
::  Every ship can want to expose the different pinboards based on some basic permissioning scheme
::  Every ship can want to subscribe to other's pinboards
::  Every ship can want to update to other's pinboards (and their own)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    WATCHES/SUBSCRIBES
::  ~~/board/(board-name) - subscribers get updates to all updates that happen to the board (i.e. updates to the graph)~~
:: `path` to graph resource, custom permissioning based on the subscribee.
::    ON-AGENT
::  subscribe to and handle updates from subscriptions to other's pinboard-proxys
::     SCRYs
::  /all
::  /keys
::  /pinboards
::  not really a foremost concern rn.
::  mainly just stuff on the local state
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
  :: 1. permissions:
  ::   a. get allowed resources of src.bowl
  ::   b. check if the target resource in allowed resources
  ::   c. reject poke if not
  :: 2. assuming allowed, poke the local graph store with the supplied update, defering to helper arm
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
