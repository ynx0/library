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
  [[%pass ~ %agent [our.bowl %graph-store] [%watch /updates]]~ this]
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
      ?+    p.cage.sign  `state
          %graph-update-2
        =+  !<(=update:store q.cage.sign)
        ~&  wire
        :: check src.bowl
        :: if ourselves, send the graph update to all subscribers
        :: if its someone else, then ingest it into our graph store
        ?:  =(src.bowl our.bowl)
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
:: todo sufrace available books in peek
++  on-peek   on-peek:def
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
      [(poke-graph-store update) state]
    ::
        %remove-library
      =/  rid        rid.command
      =/  time-sent  now.bowl
      =/  update     (remove-library-update rid time-sent)
      =.  readers  
        %-  ~(run by readers)
        |=([prm=prim:library] (~(put by prm) rid *(set ship)))  :: clear the library from any existing readers
      =.  policies   (~(del by policies) rid)                   ::  remove the policy for the given rid from
      [(poke-graph-store update) state]
    ::
        %add-book
      =/  rid           rid.command
      =/  author        src.bowl
      =/  time-sent     now.bowl
      =/  book          book.command
      =/  update        (add-book-update rid author time-sent book)
      [(poke-graph-store update) state]
    ::
        %remove-book
      =/  rid        rid.command
      =/  top        top.command
      =/  time-sent  now.bowl
      =/  update     (remove-book-update rid top time-sent)
      =.  readers
        %-  ~(run by readers)
        |=([prm=prim:library] (~(del ju prm) rid top))  ::  stop tracking any readers for this book
      [(poke-graph-store update) state]
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
      ::  commenter must be either:
      =/  prm        (~(get by readers) author)
      ?>  ?|  (team:title our.bowl author)  ::  us or our moon
              (~(has ju (need prm)) rid top)       :: someone with permissions
          ==
      =/  update     (add-comment-update rid top author time-sent comment)
      [(poke-graph-store update) state]
      ::
        %remove-comment
      ::  TODO how do we only allow author of comment to remove their own comment
      ::  get old node, see if it the same author as src.bowl, only then allow removal
      ::  only allow deletion of own comment, or by owner
      =/  rid            rid.action
      =/  comment-index  index.action
      ::  1. ensure index is of proper form (i.e. [@ %comments @])
      ?>  =([@ %comments @ ~] index)
      ::  2. scry for node at that index
        ::=/  prev-comment-update  .^(=update:store %gx (weld /graph-store/node/(scot %p entity.rid)/[name.rid] (snoc `path`comment-index %noun))) 
      ::  3. assert author of node is src.bowl or (team:title our.bowl)
        ::?>  =(-.update %add-nodes)
        ::=/  node  (snag 0 nodes.update)
        ::=/  post  ?~(post.node !! p.post.node)
        ::=/  comment-author  author.post
        ::?>  =(comment-author src.bowl)
        ::=/  remove-update  (remove-comment-update rid comment-index now.bowl)
        ::[(poke-graph-store remove-update) state]
      ~|  "%remove-comment is unimplemented"
      !!
       %get-book
      =/  rid    rid.action
      =/  index  book-index.action
      :: should only be able to do this if we are NOT the host. otherwise, we already have the book
      :: 1. add the person to readers
      ::  =/  prm  ?~  *prim  (~(get by readers) author)
      ::  =.  prm  (~(put ju prm) rid index)
      ::  =.  readers  (~(put by readers) rid prm)
      :: 2. send them the graph update
      ::=/  update  .^ scry for the node at the requested index
      ::[[%pass /updates/[src.bowl]/[rid] %agent [src.bowl %library-proxy] %poke [%graph-update-2 !>(update)]]~ state]
      !!
    ==
    [cards state]
++  handle-graph-update-outgoing
  |=  [update=update:store]
  ^-  (quip card _state)
  ~&  "got graph update {<update>}"
  =^  cards  state
  ::  this is where we forward any graph store updates to any subscriber of ours
  ::?>  =(our.bowl entity.resource.q.update)  :: we only forward updates for resources we own (todo we shouldn't for our moons right? idk)
  ::  for each ship and prim in tap:by readers
  ::  for each rid and indexes=(set atom) in prim
  ::  [%pass /updates/[ship]/[rid] %agent [ship %library-proxy] %poke [%graph-update-2 !>(update)]]~
  `state
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
  [(poke-graph-store update) state]
  [cards state]
::
++  poke-graph-store
  |=  [=update:store]
  ^-  (list card)
  [%pass ~ %agent [our.bowl %graph-store] %poke [%graph-update-2 !>(update)]]~
--
