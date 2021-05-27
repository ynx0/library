/-  *resource, library
/+  store=graph-store, graph, default-agent,
    dbug, verb, agentio, libr=library
::  TODO use agentio instead of raw cards
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
+*  this        .
    def       ~(. (default-agent this %|) bowl)
    hc        ~(. +> bowl)
    io        ~(. agentio bowl)
    libgraph  ~(. graph bowl)
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
  ::~&  graph
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
  ::`state
  ?+    path  (on-watch:def path)
      [%updates @ @ @ ~]
    ::  path format: /updates/[subscriber-ship]/[entity.rid]/[name.rid]
    ::  entity.rid must always be us, its redundant
    =/  subscriber  (slav %p i.t.path)
    =/  us          (slav %p i.t.t.path)
    =/  name        i.t.t.t.path
    ?>  =(subscriber src.bowl)  :: check for imposter (sus)
    =/  policy  (~(got by policies) [our.bowl name])
    =/  is-allowed=?
    ?-  -.policy
        %open       %.y
        %children   (team:title our.bowl src.bowl)
        %whitelist  (~(has in ships.policy) src.bowl)
    ==
    ?>  is-allowed
    ::  we scry the original graph just to get its original creation time
    ::  otherwise, it is discarded. what is actually sent is an empty graph
    ::  todo refactor for readability
    =/  original-time-sent      p:(scry-for:libgraph update:store /graph/(scot %p our.bowl)/[name])
    =/  initial-library-update  (create-library-update:libr [our.bowl name] original-time-sent)
    :: readers are who's? actually interested, and wants to hear updates
    :: implicitly, having a successful subscription means you have permission, not necessarily are interested in hearing about anything yet.
    ::
    [[%give %fact ~[/updates/(scot %p src.bowl)/(scot %p us)/[name]] [%graph-update-2 !>(initial-library-update)]]~ state]
  ==
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
    ::  this also has the same redundancy
    ::  where the entity.rid is always our.bowl
    =/  library-keys=(set resource)
      %-  silt
      %+  skim  ~(tap in keys)
      |=  [key=resource]
      ::  invariant: entity.key == our.bowl
      =/  mark  .^((unit @tas) %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/graph-mark/(scot %p entity.key)/[name.key]/noun)
      =([~ %graph-validator-library] mark)
    ::  alternatively, return key:by policies, more flakey
    ::  todo should this be %noun or (set resource)
    ``noun+!>(library-keys)
    ::      
      [%x %books @ ~]
    =/  name=@tas  i.t.t.pax
    =/  update  (scry-for:libgraph update:store /graph/(scot %p our.bowl)/[name])
    ?>  ?=(%add-graph -.q.update)
    =/  the-graph  graph.q.update
    =/  book-tops  (silt (turn (tap:orm:store the-graph) head))
    ``noun+!>(`(set atom)`book-tops)
    ::
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  General Comment: the second item in cell of all the cards below is ~ which is actually the return wire we want the poke-ack to 
::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
::  i think it may be important when there is a poke-nack or smtn and you want to keep track of it
|_  bowl=bowl:gall
+*  gra   ~(. graph bowl)
::
++  handle-command
  |=  [=command:library]
  ^-  (quip card _state)
  =^  cards  state
  ?-    -.command
      %create-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =/  policy     policy.command
    =/  update     (create-library-update:libr rid time-sent)
    =.  policies   (~(put by policies) rid policy)  :: set the policy for the given rid into the actual state
    [(poke-local-store update) state]
  ::
      %remove-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =/  update     (remove-library-update:libr rid time-sent)
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
    =/  update        (add-book-update:libr rid author time-sent book)
    [(poke-local-store update) state]
  ::
      %remove-book
    =/  rid        rid.command
    =/  top        top.command
    =/  time-sent  now.bowl
    =/  update     (remove-book-update:libr rid top time-sent)
    =.  readers
      %-  ~(run by readers)
      |=([prm=prim:library] (~(del ju prm) rid top))  ::  stop tracking any readers for this book
    [(poke-local-store update) state]
  ::
      %request-library
    =/  rid        rid.command
    [[%pass ~ %agent [entity.rid %library-proxy] [%watch /updates/(scot %p our.bowl)/(scot %p entity.rid)/[name.rid]]]~ state]
  ::
      %request-book
    =/  rid  rid.command
    =/  top  top.command
    =/  =action:library  [%get-book rid top]
    :: todo crashes if we haven't %request-library'd first. is this ok?
    [[%pass /book-request %agent [entity.rid %library-proxy] %poke [%library-action !>(action)]]~ state]
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
    =/  update     (add-comment-update:libr rid top author time-sent comment)
    [(poke-local-store update) state]
  ::
      %remove-comment
    =/  rid            rid.action
    =/  comment-index  index.action
    ?>  ?=([@ %comments @ ~] comment-index)  ::  ensure index is of proper form
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
    ::  TODO what abt ((team:title our.bowl) ?)
    ::  assert the person trying to delete is:
    ?>  ?|  =(our.bowl src.bowl)     :: the owner of the proxy (us)
            =(prev-author src.bowl)  :: the author of node.
        ==
    =/  remove-update  (remove-comment-update:libr rid comment-index now.bowl)
    [(poke-local-store remove-update) state]
  ::
      %get-book
    =/  rid  rid.action
    =/  top  book-index.action
    :: should only be able to do this if we are NOT the host. otherwise, we already have the book
    ?<  =(our.bowl src.bowl)
    ::  todo if dap is foreign app, then assert that it is also a %library-proxy
    :: 1. add the person to readers
    =/  prm  (fall (~(get by readers) src.bowl) *prim:library)
    =.  prm  (~(put ju prm) rid top)
    =.  readers  (~(put by readers) src.bowl prm)
    :: 2. send them the graph update
    =/  pax  `path`/(scot %p our.bowl)/graph-store/(scot %da now.bowl)/node/(scot %p our.bowl)/[name.rid]/(scot %ud top)/noun
    ~&  pax
    =/  update  .^(update:store %gx pax)
    [[%give %fact ~[/updates/(scot %p src.bowl)/(scot %p entity.rid)/[name.rid]] [%graph-update-2 !>(update)]]~ state]
  ==
  [cards state]
++  handle-graph-update-outgoing
  |=  [=update:store]
  ^-  (quip card _state)
  ::  this is where we forward any graph store updates to any subscriber of ours
  ~&  "got graph update"
  ~&  update
  =^  cards  state
  =/  update-rids  (resource-for-update:gra !>(update))
  ?~  update-rids  `state  :: if theres no resource, we don't forward cause we can't tell if its something based on our own resource
  =/  update-rid   i.update-rids
  ?.  =(our.bowl entity.update-rid)  `state  :: we only forward updates for resources we own (todo we shouldn't for our moons right? idk)
  `state
  ::
  :: we need to switch on type of graph update, most we just forward without any change or special handling
  :: but for %add-nodes we need to be picky about what we send
  =/  cards
  ~
  :: use |^ and name bodies of loops
  :: use ^-  to signal result of turn/murn
  :: split out bottom level check for applicability of this update
  :: build from bottom up
  :: skim the nodes for %add-nodes based 
    ::%-  zing
    ::^-  (list card)
    ::%+  murn  ~(tap by readers)  :: for each reader, prim in readers
    ::|=  [reader-ship=ship prm=prim]
    ::^-  (unit card)
    ::::
    ::%+  murn  ~(tap by prim)     :: for each rid, set of book-indexes in prim
    ::|=  [b=(pair resource (set atom))]
    ::^-  (unit card)
    ::=/  [rid book-indexes]  b
    ::::  if the resource matches nodes.resource
    ::::  and if 
    ::%+  turn  ~(tap in book-indexes)
    ::|=  [book-index=atom]        :: for each book index in book-indexes
    ::^-  (unit card)
    :::: check if top level index of current update is in this update
    ::[%give %fact ~[/updates/(scot %p src.bowl)/[name.rid]] [%graph-update-2 !>(update)]
  [cards state]
::
++  handle-graph-update-incoming
  |=  [=update:store]
  ^-  (quip card _state)
  ~&  "got foreign graph update {<update>} from {<src.bowl>}"
  =^  cards  state
    =/  rids  (resource-for-update:gra !>(update))
    ?~  rids  `state
    =/  rid   i.rids
    ?>  =(src.bowl entity.rid)  :: only owners may send graph updates for resources they own
    [(poke-local-store update) state]
  [cards state]
::
++  poke-local-store
  |=  [=update:store]
  ^-  (list card)
  [%pass ~ %agent [our.bowl %graph-store] %poke [%graph-update-2 !>(update)]]~
--
