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
    ::?>  =((team:title our.bowl src.bowl) )  :: todo allow moons to act as ourselfs
    =+  !<(command vase)
    ?-    -.command
        %update-permissions
      =/  rid    rid.command
      =/  top    top.command
      =/  ship   ship.command
      =/  prm=prim  (~(gut by permissions) rid *prim)  ::  get the prim associated with the given resource
      =.  prm  :: perform the modification then rebind the product to prm
      ?-  operation.command
        %add     (~(put ju prm) top ship)  :: add the ship to the set associated with top
        %remove  (~(del ju prm) top ship)  :: remove the ship to the set associated with top
      ::
      :: todo whats the best way to phrase the following operation?
      =.  permissions  (~(put by permissions) rid prm)      :: replace the old prm with the new one
      [~ this]
    ::
        %add-book
    :: create a graph update and send it to local graph store using the book
    =/  rid     rid.command
    =/  book    book.command
    =/  update  (add-book-update rid src.bowl now.bowl book)
    ::  [delete later] the second item in cell is ~ which is actually the return path we want the poke-ack to 
    ::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
      %remove-book
    :: create a graph update to remove the book based on the index and send it to local graph store 
    =/  update  (remove-book-update rid.command top.command now.bowl)
    [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
    ::
    ::
      %library-proxy-action
    =+  !<(action vase)
    ?-    -.action
        %add-comment
      =/  rid  rid.action
      =/  top  top.action
      =/  prm=prim  (~(got by permissions) rid)  ::  get the prim associated with the given resource
      ?>  (~(has ju prm) top author)             ::  assert that the ship created the comment
      :: extract out above to core
      =/  =comment:library  comment.action
      =/  update  (add-comment-update rid top src.bowl now.bowl comment)
      [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
      ::
        %remove-comment
      ::  TODO how do we only allow author of comment to remove their own comment
      ::  get old node, see if it the same author as src.bowl, only then allow removal
      ::  only allow deletion of own comment
      =/  rid            rid.action
      =/  comment-index  index.action
      =/  prim  (~(got by permissions) rid)
      =/  update  .^(update:store %gx /graph-store/node/[rid]/[comment-index]/something)  ::  scry graph store for the index
      ?>(%| -.mp.update)
      =/  post ...
      =/  comment-author  ~
      ?>  =(comment-author src.bowl)
      ::  assert the author of comment to match src.bowl
      ::  extract above to permissions core
      =/  update  (remove-comment-update rid comment-index now.bowl)
      [[%pass ~ %agent [our %graph-store] %poke %graph-update-1+!>(update)] this]
      ::
  ==
  [cards this]
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  :::: (in this model. each ship is responsible soley for sending out updates of resources it owns, and no one else.
  :::: as a result, we simply trust updates (after imposter check) from a given ship; that is, it is the sole source of truth).
  ::  CHECK dap.bowl , if graph store then we know its local, if proxy then we know someone else is
  ::  also check src.bowl

  :: if it is graph store update from local graph-store
  :: check if it is a resource we own. if it is not, do not send out any updates for it
  :: if it is, build a list of ships that deserve to get the update (potentially taking into account its type and stuff)
  :: then send the updates out.

  :: if it is graph store update from foreign proxy
  :: assert that the resource of the update matches the src.bowl (i.e. disallow updates from imposter)
  :: ingest the update by poking the local graph store with it.

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
