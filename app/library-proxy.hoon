/-  *resource, library
/+  store=graph-store, graph, default-agent,
    dbug, verb, agentio, *library
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  [%0 base-state-0]
+$  base-state-0
  $:
    =permissions:library
  ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
=<
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
  ::
  ::[[[%pass /graph-updates/(scot %p our.bowl) [%agent [our.bowl %graph-store] [%watch /updates]]] ~] this]  :: maybe we don't need the wire...
  [[[%pass ~ [%agent [our.bowl %graph-store] [%watch /updates]]] ~] this]
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
      %library-command
    ::?>  =(our.bowl src.bowl)          :: allow only ourselves to use this poke
    ?>  (team:title our.bowl src.bowl)  :: allow ourselves and moons to use this poke
    =+  !<(=command:library vase)
    (handle-command:hc command)
    ::
      %library-action
    =+  !<(=action:library vase)
    (handle-action:hc action)
  ==
  [cards this]
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  :::: (in this model. each ship is responsible solely for sending out updates of resources it owns, and no one else.
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
          %graph-update-2
        =+  !<(=update:store q.cage.sign)
        ~&  wire
        :: check src.bowl
        :: if ourselves, send the graph update to all subscribers
        :: if its someone else, then ingest it into our graph store
        ?:  =(src.bowl our.bowl)
          :: this is outgoign
          (handle-graph-update-outgoing:hc update)
        (handle-graph-update-incoming:hc update)
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
    `state
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
::  General Commetn: the second item in cell of all the cards below is ~ which is actually the return wire we want the poke-ack to 
::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
|_  bowl=bowl:gall
++  handle-command
  |=  [=command:library]
  ^-  (quip card _state)
  =^  cards  state
  ?-    -.command
        %create-library
      =/  rid        rid.command
      =/  time-sent  now.bowl
      =/  update     (create-library-update rid time-sent)
      =.  permissions.state  (~(put by permissions) rid *prim:library)  ::  init the prim based on the new library to create
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
    ::
        %remove-library
      =/  rid        rid.command
      =/  time-sent  now.bowl
      =/  update     (remove-library-update rid time-sent)
      =.  permissions.state  (~(del by permissions) rid)  ::  remove the prim for the library to be deleted by clearing it
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
    ::
        %add-book
      =/  rid           rid.command
      =/  author        src.bowl
      =/  time-sent     now.bowl
      =/  book          book.command
      =/  update  (add-book-update rid author time-sent book)
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
    ::
        %remove-book
      =/  rid        rid.command 
      =/  top        top.command
      =/  time-sent  now.bowl
      =/  update     (remove-book-update rid top time-sent)
      ::  delete any permissions for this book
      =/  prm  (~(got by permissions) rid)
      =.  prm  (~(del by prm) top)
      =.  permissions.state  (~(put by permissions) rid prm)
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
    ::
        %update-permissions
      ::  ensure that we don't add ourselves or our moon to the permissions
      ::  because we always have permissions by definition
      =/  rid    rid.command
      =/  top    top.command
      =/  ship   ship.command
      ?<  (team:title our.bowl ship.command)
      ::  todo debug printf ~|([dap.bowl "tried to update permissions for non-existent rid" rid] !!)
      =/  prm  (~(got by permissions) rid)  ::  get the prim associated with the given resource
      =.  prm  :: perform the modification then rebind the product to prm
        ?-  operation.command
          %add     (~(put ju prm) top ship)  :: add the ship to the set associated with top
          %remove  (~(del ju prm) top ship)  :: remove the ship to the set associated with top
        ==
      [~ state(permissions (~(put by permissions) rid prm))]  :: replace the old prm with the new one
    ::

  ==
  [cards state]
++  handle-action
  |=  [=action:library]
  ^-  (quip card _state)
  =^  cards  state
  ?-    -.action
        %add-comment
      =/  rid        rid.action
      =/  top        top.action
      =/  author     src.bowl
      =/  time-sent  now.bowl
      =/  comment    comment.action
      =/  prm        (~(got by permissions) rid)
      ?>  ?|                               :: commenter must be either:
            =(team:title our.bowl author)  :: us or our moon
            (~(has ju prm) top author)     :: someone with permissions
          ==
      =/  update     (add-comment-update rid top author time-sent comment)
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
      ::
        %remove-comment
      ::  TODO how do we only allow author of comment to remove their own comment
      ::  get old node, see if it the same author as src.bowl, only then allow removal
      ::  only allow deletion of own comment
      =/  rid            rid.action
      =/  comment-index  index.action
      =/  prim  (~(got by permissions) rid)
      ~|  "%remove-comment is unimplemented"
      !!
      =/  prev-comment-update  .^(update:store %gx /graph-store/node/[rid]/[comment-index]/something)  ::  scry graph store for the index
      ::?>(%& -.mp.prev-comment-update)
      ::=/  post ...
      =/  comment-author=ship  ~zod
      ?>  =(comment-author src.bowl)
      ::  assert the author of comment to match src.bowl
      ::  extract above to permissions core
      =/  update  (remove-comment-update rid comment-index now.bowl)
      [[[%pass ~ %agent [our.bowl %graph-store] %poke %graph-update-2 !>(update)] ~] state]
    ==
    [cards state]
++  handle-graph-update-outgoing
  |=  [update=update:store]
  ^-  (quip card _state)
  =^  cards  state
  ::  this is where we forward any graph store updates to any subscriber of ours
  ~&  "got graph update {<update>}"
  `state
  [cards state]
::
++  handle-graph-update-incoming
  |=  [update=update:store]
  ^-  (quip card _state)
  =^  cards  state
  ::  this is where we ingest a graph store update
  ::  from a foreign proxy that we've subscribed to
  ~&  "got graph update {<update>}"
  `state
  [cards state]
::
++  poke-graph-store
  |=  *
  !!
--
