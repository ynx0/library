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
    =readers:library
    =policies:library
  ==
::
+$  card  card:agent:gall
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
  [[%pass /local-store %agent [our.bowl %graph-store] [%watch /updates]]~ this]
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
    ?>  (team:title our.bowl src.bowl)  :: allow ourselves and moons to use this poke
    =+  !<(=command:library vase)
    (handle-command:hc command)
  ::
      %library-action
    =+  !<(=action:library vase)
    (handle-action:hc action)
  ==
  [cards this]
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  :: (in this model. each ship is responsible solely for sending out updates of resources it owns, and no one else.
  :: as a result, we simply trust updates (after imposter check) from a given ship; that is, it is the sole source of truth).
  ?+    -.sign  (on-agent:def wire sign)
      %kick
    ~&  >>>  "kicked from graph store subscription"
    `this
  ::
      %fact
    =^  cards  state
      ?+    p.cage.sign  `state
          %graph-update-2
        =+  !<(=update:store q.cage.sign)
        ~&  wire
        ?:  =(src.bowl our.bowl)
          (handle-graph-update-outgoing:hc update)
        (handle-graph-update-incoming:hc update)
      ==
    [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =^  cards  state
  `state
  ::?+    path  (on-watch:def path)
  ::    [%updates resource ship ~]
  ::  ::  path format: /updates/[rid]/[ship]
  ::  =/  name  i.t.t.path
  ::  =/  ship  (slav %p (snag 2 path))
  ::  ?>  =(src.bowl ship)  :: check for imposter (sus)
  ::  =/  policy  (~(got by policies) [our.bowl name])
  ::  =/  is-allowed=?
  ::  ?-  -.policy
  ::      %open       %.y
  ::      %children   (team:title our.bowl src.bowl)
  ::      %whitelist  (~(has in ships.policy) ship)
  ::  ==
  ::  ?>  is-allowed
  ::  =/  cards=(list card)  ~
  ::  :: no "initial" update, no being added to readers.
  ::  :: readers are whos actually interested, and wants to hear updates
  ::  :: implicitly, having a successful subscription means you have permission, not necessarily are interested in hearing about anything yet.
  ::  [~ state]
  ::  ::
  ::==
  [cards this]
++  on-leave  on-leave:def
:: todo surface available books in peek
++  on-peek
  |=  pax=path
  ^-  (unit (unit cage))
  ?+    pax  (on-peek:def pax)
      [%x %libraries ~]
    ::  1. scry for all graph keys in our local graph store
    =/  keys  
      =/  key-update  .^(update:store %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/keys/noun)
      ?>  ?=(%keys -.q.key-update)
      resources.q.key-update
    =/  library-keys
      %+  skim  ~(tap in keys)
      |=  [key=resource]
      ::  invariant: entity.key == our.bowl
      =/  mark  .^((unit @tas) %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/graph-mark/(scot %p entity.key)/[name.key]/noun)
      =([~ %graph-validator-library] mark)
    ::  alternatively, return key:by policies
    ::  todo should this be %noun or (set resource)
    ``noun+!>(library-keys)
    ::      
      [%x %books @ ~]
    =/  name  i.t.t.path
    ::  for a given library name,
    ::  scry our local graph store /graph/OUR/NAME
      ::.^((unit @tas) %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/graph/(scot %p our)/[path]/noun)
    ::  return key:orm:store for the atoms
    ``noun+!>(~)
    ::
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  General Comment: the second item in cell of all the cards below is ~ which is actually the return wire we want the poke-ack to 
::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
::  i think it may be important when there is a poke-nack or smtn and you want to keep track of it
|_  bowl=bowl:gall
++  handle-command
  |=  [=command:library]
  ^-  (quip card _state)
  =^  cards  state
  ?-    -.command
      %create-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =/  policy     policy.command
    =/  update     (create-library-update rid time-sent)
    =.  policies   (~(put by policies) rid policy)  :: set the policy for the given rid into the actual state
    [(poke-local-store update) state]
  ::
      %remove-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =/  update     (remove-library-update rid time-sent)
    =.  readers  
      %-  ~(run by readers)
      |=([prm=prim:library] (~(put by prm) rid *(set ship)))  :: clear the library from any existing readers
    =.  policies   (~(del by policies) rid)                   ::  remove the policy for the given rid from
    [(poke-local-store update) state]
  ::
      %add-book
    =/  rid           rid.command
    =/  author        src.bowl
    =/  time-sent     now.bowl
    =/  book          book.command
    =/  update        (add-book-update rid author time-sent book)
    [(poke-local-store update) state]
  ::
      %remove-book
    =/  rid        rid.command
    =/  top        top.command
    =/  time-sent  now.bowl
    =/  update     (remove-book-update rid top time-sent)
    =.  readers
      %-  ~(run by readers)
      |=([prm=prim:library] (~(del ju prm) rid top))  ::  stop tracking any readers for this book
    [(poke-local-store update) state]
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
    =/  prm        (~(get by readers) author)
    ::                                      ::  commenter must be either:
    ?>  ?|  (team:title our.bowl author)    ::  us or our moon
            (~(has ju (need prm)) rid top)  ::  someone with permissions
        ==
    =/  update     (add-comment-update rid top author time-sent comment)
    [(poke-local-store update) state]
  ::
      %remove-comment
    =/  rid            rid.action
    =/  comment-index  index.action
    ?>  =([@ %comments @ ~] comment-index)  ::  ensure index is of proper form
    ::  TODO convert to tall form
    ::  TODO refactor out
    ::  scry for node at that index
    =/  prev-comment-update  
      .^(update:store %gx (weld /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/node/(scot %p our.bowl)/[name.rid] (snoc `path`(turn comment-index (cury scot %ud)) %noun)))
    =/  prev-post
      ?>  ?=(%add-nodes -.q.prev-comment-update)
      =/  comment-node  (~(got by nodes.q.prev-comment-update) comment-index)
      ?>  ?=(%.y -.post.comment-node)
      p.post.comment-node
    =/  prev-author  author.prev-post
    ::  assert the person trying to delete is actually the author of node. TODO what abt ((team:title our.bowl) ?)
    ?>  =(prev-author src.bowl)
    =/  remove-update  (remove-comment-update rid comment-index now.bowl)
    [(poke-local-store remove-update) state]
  ::
      %get-book
    =/  rid    rid.action
    =/  index  book-index.action
    :: should only be able to do this if we are NOT the host. otherwise, we already have the book
    ?<  =(our.bowl src.bowl)
    ::  todo if dap is foreign app, then assert that it is also a %library-proxy
    :: 1. add the person to readers
    =/  prm  (fall (~(get by readers) src.bowl) *prim:library)
    =.  prm  (~(put ju prm) rid index)
    =.  readers  (~(put by readers) src.bowl prm)
    :: 2. send them the graph update
    =/  update  .^(update:store %gx (weld /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/node/(scot %p our.bowl)/[name.rid] (snoc `path`(turn comment-index (cury scot %ud)) %noun)))
    [[%give %fact ~[/updates/(scot %p src.bowl)/[entity.rid]/[name.rid]] [%graph-update-2 !>(update)]]~ state]
  ==
  [cards state]
++  handle-graph-update-outgoing
  |=  [=update:store]
  ^-  (quip card _state)
  ::  this is where we forward any graph store updates to any subscriber of ours
  ~&  "got graph update"
  ~&  update
  ~&  "unsafe forwarding enabled!"
  =^  cards  state
  =/  res  (resource-for-update:graph !>(update))
  ?~  res  `state  :: if theres no resource, we don't forward
  ::?>  =(our.bowl entity.resource.q.update)  :: we only forward updates for resources we own (todo we shouldn't for our moons right? idk)
  =.  cards
    %+  murn  ~(tap by readers)  :: for each reader, prim in readers
    |=  [a=(pair ship prim)]
    =/  ship  p.a
    =/  prim  q.a
    %+  turn  ~(tap by prim)     :: for each rid, set of book-indexes in prim
    |=  [b=(pair resource (set atom))]
    =/  rid           p.b
    =/  book-indexes  q.b
    %+  turn  ~(tap in book-indexes)
    |=  [book-index=atom]        :: for each book index in book-indexes
    ::  if the update 
    [%give %fact ~[/updates/(scot %p src.bowl)/[name.rid]] [%graph-update-2 !>(update)]
  [cards state]
::
++  handle-graph-update-incoming
  |=  [=update:store]
  ^-  (quip card _state)
  ~&  "got foreign graph update {<update>} from {<src.bowl>}"
  =^  cards  state
  ~&  "warning: handling of incoming graph updates is currently insecure!"
  ::  question: if someone pokes me a graph store update from their proxy (adversarially)
  ::  that is %add-signatures, there is not a resource but a uid.
  ::  should i handle every update and extract the resource from the uid if present?
  ::?>  =(src.bowl entity.resource.q.update)  :: only owners may send graph updates for resources they own
  [(poke-local-store update) state]
  [cards state]
::
++  poke-local-store
  |=  [=update:store]
  ^-  (list card)
  [%pass ~ %agent [our.bowl %graph-store] %poke [%graph-update-2 !>(update)]]~
--
