/-  *resource, library
/+  store=graph-store, graph, default-agent,
    dbug, verb, agentio, libr=library
::  TODO i still don't know what wires to put for my `%watch`s
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
    gra       ~(. graph bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%library-proxy initialized successfully'
  [(~(watch-our pass:io /local-store) %graph-store /updates)^~ this]
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
    ::?>  (team:title our.bowl src.bowl)  :: allow ourselves and moons to use this poke
    ?>  (is-owner:hc src.bowl)  :: only allow ourselves to use this poke
    =+  !<(=command:library vase)
    (handle-command:hc command)
  ::
      %library-action
    =+  !<(=action:library vase)
    (handle-action:hc action)
  ::
      %library-response
    =+  !<(=response:library vase)
    (handle-response:hc response)
  ==
  [cards this]
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  :: (in this model. each ship is responsible solely for sending out updates of resources it owns, and no one else.
  :: as a result, we simply trust updates (after imposter check) from a given ship; that is, it is the sole source of truth).
  :: type reference https://github.com/urbit/urbit/blob/85fdd6b190479030d2e763b326060ce8020fa9ae/pkg/arvo/sys/lull.hoon#L1689
  ?+    -.sign  (on-agent:def wire sign)
      %kick
    :: a %kick doesn't always mean the publisher has voluntarily terminated the subscription.
    :: it can also mean that there is network traffic cloggage
    :: thus, we must try to resubscribe here, and then once that goes through if we then get a failing watch ack only then do we give up
    ~&  >>  "kicked from subscription {<wire>}"
    ~&  >>  "attempting to resubscribe"
    ?~  wire  ~|("empty wire, can't resubscribe. this shouldn't happen" `this)  :: todo do we need this or can we do with just the assertion
    ::
    ?>  ?=([%request-library @ @ ~] wire)
    =/  host  (slav %p i.t.wire)
    =/  name  `@tas`i.t.t.wire
    [(sub-to-library:hc [host name])^~ this]
  ::
      %watch-ack
    ?~  p.sign
      ~&  >   "resubscribed on wire {<wire>} successfully"
      `this  :: no error, subscription was successful
    ~&  >>>  "subscribe on wire {<wire>} failed"
    `this    :: we have truly been kicked. a sad day
  ::
      %fact
    =^  cards  state
      ?+    p.cage.sign  `state
          %graph-update-2
        =+  !<(=update:store q.cage.sign)
        ?:  (is-owner:hc src.bowl)
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
  ?+    path  (on-watch:def path)
  ::  TODO potenially do readable type alias for watch path wing (is there any perf hit to a bunch of aliases)
  ::  or maybe just a comment
  ::  +$  subscriber-ship  atom
  ::  +$  us               atom
  ::  +$  name             atom
      [%updates @ @ @ ~]
    ::  path format:  /updates/[src.bowl]/[entity.rid]/[name.rid]
    ::  human format: /updates/[subscriber-ship]/[host-ship]/[library-name]
    ::  host-ship must always be us, its redundant
    =/  subscriber    `@p`(slav %p i.t.path)
    =/  host-ship     `@p`(slav %p i.t.t.path)
    =/  library-name  `@tas`i.t.t.t.path
    ?<  (is-owner:hc src.bowl)    :: do not allow ourselves to subscribe, invalid
    ?>  =(subscriber src.bowl)    :: check for imposter (sus)
    =/  policy  (~(got by policies) [our.bowl library-name])
    ?>  (is-allowed:libr subscriber our.bowl policy)
    ::  we scry the original graph just to get its original creation time
    ::  otherwise, it is discarded. what is actually sent is an empty graph
    ::  todo refactor for readability
    =/  original-time-sent      p:(scry-for:gra update:store /graph/(scot %p our.bowl)/[library-name])
    =/  initial-library-update  (create-library:libr [our.bowl library-name] original-time-sent)
    :: readers are who's actually interested, and wants to hear updates
    :: implicitly, having a successful subscription means you have permission, 
    :: not necessarily that you are interested in hearing about anything yet.
    ::  todo refactor following state modif
    =.  readers  (~(put by readers) subscriber (~(gas by *prim:library) [[[our.bowl library-name] *(set atom)] ~]))
    :_  state
    :~  (fact:io graph-update-2+!>(initial-library-update) (incoming-sub-path subscriber library-name)^~)
    ==
  ==
  [cards this]
++  on-peek
  |=  pax=path
  ^-  (unit (unit cage))
  ?+    pax  (on-peek:def pax)
      [%x %libraries ~]
    ::  1. scry for all graph keys in our local graph store
    =/  keys
      =/  key-update  (scry-for:gra update:store /keys)
      ?>  ?=(%keys -.q.key-update)
      resources.q.key-update
    ::  this also has the redundancy where the entity.rid is always our.bowl
    =/  library-keys=(set resource)
      %-  silt
      %+  skim  ~(tap in keys)
      |=  [key=resource]
      ^-  ?
      =/  mark  ::  invariant: entity.key == our.bowl
        (scry-for:gra (unit @tas) /graph-mark/(scot %p entity.key)/[name.key])
      =(`%graph-validator-library mark)
    ``noun+!>(library-keys)
  ::      
      [%x %books @ ~]
    =/  name=@tas  i.t.t.pax
    =/  update  (scry-for:gra update:store /graph/(scot %p our.bowl)/[name])
    ?>  ?=(%add-graph -.q.update)
    =/  the-graph  graph.q.update
    =/  book-tops  (silt (turn (tap:orm:store the-graph) head))
    ``noun+!>(`(set atom)`book-tops)
  ==
++  on-leave  on-leave:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  General Comment: the second item in cell of all the cards below is ~ which is actually the return wire we want the poke-ack to 
::  be sent on, but, we don't really care about it i don't think so we'll leave it null for now
::  i think it may be important when there is a poke-nack or smtn and you want to keep track of it
|_  bowl=bowl:gall
+*  gra  ~(. graph bowl)
    io   ~(. agentio bowl)
::
++  handle-command
  |=  [=command:library]
  |^  ^-  (quip card _state)
  =^  cards  state
  ?-    -.command
      %create-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =/  policy     policy.command
    =.  policies   (~(put by policies) rid policy)  :: set the policy for the given rid into the actual state
    (poke-local (create-library:libr rid time-sent))
  ::
      %remove-library
    =/  rid        rid.command
    =/  time-sent  now.bowl
    =.  policies   (~(del by policies) rid)       ::  remove the policy for the given rid from
    (poke-local (remove-library:libr rid time-sent))
  ::
      %add-book
    =/  rid           rid.command
    =/  author        src.bowl
    =/  time-sent     now.bowl
    =/  book          book.command
    (poke-local (add-book:libr rid author time-sent book))
  ::
      %remove-book
    =/  rid        rid.command
    =/  top        top.command
    =/  time-sent  now.bowl
    ::  removing the book from `readers` is handled during the handling of %remove-graph
    ::  because it needs the metadata to know who to send the update to
    (poke-local (remove-book:libr rid top time-sent))
  ::
      %request-library
    =/  rid  rid.command
    ~|  "tried to request access to library that we own"
    ?<  (is-owner entity.rid)  :: invalid. we should never request our own library, this may cause a loop
    [(sub-to-library rid)^~ state]
  ::
      %request-book
    =/  rid  rid.command
    =/  top  top.command
    ?:  (is-owner entity.rid)
      ~|("tried to request access to library that we own" !!)
    =/  =action:library  [%get-book rid top]
    :: i'm pretty sure this crashes if we haven't %request-library'd first. this is probably ok
    :_  state
    (~(poke pass:io /book-request) [entity.rid %library-proxy] library-action+!>(action))^~
  ==
  [cards state]
  ::
  ++  poke-local
    |=  [=update:store]
    ^-  (quip card _state)
    [(poke-local-store update)^~ state]
  --
++  handle-action
  |=  [=action:library]
  |^  ^-  (quip card _state)
  =^  cards  state
    ?-    -.action
        %add-comment
      =/  rid        rid.action
      =/  top        top.action
      =/  author     src.bowl
      =/  time-sent  now.bowl
      =/  comment    comment.action
      =/  prm        (~(get by readers) author)
      ::                                          ::  commenter must be either:
      ?>  ?|  (is-owner author)                   ::  us
              ::  (team:title our.bowl author)    ::  us or our moon
              (~(has ju (need prm)) rid top)      ::  someone with permissions
          ==
      =/  update     (add-comment:libr rid top author time-sent comment)
      [(poke-local-store update)^~ state]
    ::
        %remove-comment
      =/  rid            rid.action
      =/  comment-index  index.action
      ?>  ?=([@ %comments @ ~] comment-index)
      =/  prev-comment-update
        (scry-for:gra update:store (weld /node/(scot %p our.bowl)/[name.rid] (index-to-path:libr comment-index)))
      ?.  (can-remove-comment src.bowl comment-index prev-comment-update)
        `state  :: if requesting ship cannot remove comment, silently ignore
      =/  remove-update  (remove-comment:libr rid comment-index now.bowl)
      [(poke-local-store remove-update)^~ state]
    ::
        %get-book
      =/  rid  rid.action
      =/  top  book-index.action
      ?<  =(our.bowl src.bowl)    :: invalid, disallow ourselves from requesting from our own library
      ?>  =(entity.rid our.bowl)  :: assert that the library is one that we (potentially) own
      :: 1. add the person to readers
      =/  prm  (fall (~(get by readers) src.bowl) *prim:library)
      =.  prm  (~(put ju prm) rid top)
      =.  readers  (~(put by readers) src.bowl prm)
      :: 2. send them the graph update
      =/  update  (scry-for:gra update:store /node/(scot %p our.bowl)/[name.rid]/(scot %ud top))
      :_  state
      :~  (fact:io graph-update-2+!>(update) ~[(incoming-sub-path src.bowl name.rid)])
      ==
    ::
        %get-libraries
      =/  libraries  (scry-for (set resource) /libraries)
      =?  libraries  !(is-owner src.bowl)  :: filter out allowed libraries if requester isn't the owner
        %-  silt
        %+  skim  ~(tap in libraries)
        |=  [rid=resource]
        =/  policy  (~(got by policies) rid)
        (is-allowed:libr src.bowl our.bowl policy)
      :_  state
      :~  (~(poke pass:io /) [src.bowl %library-proxy] library-response+!>(available-libraries+libraries))
      ==
    ::
        %get-books
      ::  todo if/when full-text/extra info is enabled, the resulting data could be a set of book-indexes along with just title and isbn without(!)
      ::  fulltext, so that you only download the fulltext of books that you care about, and you have more metadata to judge by
      =/  rid  rid.action
      =/  policy  (~(get by policies) rid)
      ?~  policy  `state                               :: if there is no policy set for the given rid, it is an invalid request. ignore
      ?.  (is-allowed:libr src.bowl our.bowl u.policy)  `state  :: only give them list of books if they are allowed
      =/  book-indexes  (scry-for (set atom) /books/[name.rid])
      :_  state
      :~  (~(poke pass:io /) [src.bowl %library-proxy] library-response+!>(available-books+[rid book-indexes]))
      ==
    ==
  [cards state]
  ::
  ++  can-remove-comment
    |=  [=ship comment-index=index:store comment-update=update:store]
    ^-  ?
    ?>  ?=(%add-nodes -.q.comment-update)
    =/  comment-node  (~(got by nodes.q.comment-update) comment-index)
    ?.  ?=(%.y -.post.comment-node)  
      %.n  :: cannot remove already deleted comment
    =/  prev-post    p.post.comment-node
    =/  prev-author  author.prev-post
    ::  you may remove a comment if you are:
    ?|   (is-owner src.bowl)     :: the owner of the proxy
        =(prev-author src.bowl)  :: the author of comment
    ==
  --
++  handle-response
  |=  [=response:library]
  ^-  (quip card _state)
  ?-    -.response
      %available-libraries
    ~&  libraries.response
    `state
  ::
      %available-books
    ~&  rid.response
    ~&  book-indexes.response
    `state
  ==
++  handle-graph-update-outgoing
  |=  [=update:store]
  |^  ^-  (quip card _state)
  ::  this is where we forward any graph store updates to any subscriber of ours
  =^  cards  state
    :: resource-for-update always returns a list of one (1) resource
    =/  update-rid-wrapped  (resource-for-update:gra !>(update))
    ?~  update-rid-wrapped  `state             :: if theres no resource, we don't forward cause we can't tell if its something based on our own resource
    =/  update-rid          i.update-rid-wrapped
    ?.  =(our.bowl entity.update-rid)  `state  :: we only broadcast updates for resources we own
    ?+    -.q.update        ~&("ignoring update {<-.q.update>}" `state)
        %add-graph          `state  :: do not forward add graph to anyone. this gets manually forwarded in on-watch
    ::
        ::  i think the following pokes are only meant to be sent by the local user to his local graph-store
        %archive-graph      `state
        %unarchive-graph    `state
        %run-updates        `state
    ::
        %add-signatures     [(send-if-tracking-uid update update-rid index.uid.q.update) state]
        %remove-signatures  [(send-if-tracking-uid update update-rid index.uid.q.update) state]
        %add-tag            [(send-if-tracking-uid update update-rid index.uid.q.update) state]
        %remove-tag         [(send-if-tracking-uid update update-rid index.uid.q.update) state]
    ::
        %remove-graph
      ::  todo this style and code sucks please someone help lol
      :_  =.  state  (remove-library state update-rid)
      state
      %-  zing
      ~&  readers
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-libraries  ~(key by prm)  :: if her is not tracking this resource, don't send the update
      ?.  (~(has in tracked-libraries) update-rid)  ~
      %-  some
      :~  (fact:io graph-update-2+!>(update) (incoming-sub-path her name.update-rid)^~)
          (kick-only:io her paths)
      ==
    ::
        %add-nodes
      :_  state
      %-  zing
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-books=(unit (set @))  (~(get by prm) update-rid)
      ?~  tracked-books  ~  :: if no tracked books for this resource, don't bother making any cards
      %-  some
      %+  murn  ~(tap by nodes.q.update)
      |=  [idx=index:store *]
      ?.  (~(has in u.tracked-books) (head idx))  ~  :: only forward this update if they are tracking this book
      `(fact:io graph-update-2+!>(update) (incoming-sub-path her name.update-rid)^~)
    ::
        %remove-posts
      ::  need to clear reader state *after* creating cards, cause we can't create card without state
      ::  todo this style and code sucks please someone help lol
      :_   =.  state  (remove-book state update-rid indices.q.update)
      state
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-books=(unit (set @))
        (~(get by prm) update-rid)
      :: if no tracked books for this resource, don't bother making any cards
      ?~  tracked-books  ~
      :: ensure that users who receive a remove-posts
      :: only receive it for indices that they would have
      =.  indices.q.update  (filter-indices indices.q.update u.tracked-books)
      `(fact:io graph-update-2+!>(update) (incoming-sub-path her name.update-rid)^~)
    ==
  [cards state]
  ::
  ++  filter-indices
    |=  [indices=(set index:store) tracked-books=(set @)]
    ::  return indices that only pertain to the books that are being tracked
    ^-  (set index:store)
    %-  silt
    %+  skim  ~(tap in indices)
    |=  [idx=index:store]
    (~(has in tracked-books) (head idx))
  ++  send-if-tracking-uid
    |=  [=update:store update-rid=resource idx=index:store]
    ^-  (list card)
    %+  murn  ~(tap by readers)
    |=  [her=ship prm=prim:library]
    =/  tracked-books=(unit (set @))
      (~(get by prm) update-rid)
    :: if no tracked books for this resource, don't bother making any cards
    ?~  tracked-books  ~
    ?.  (~(has in u.tracked-books) (head idx))  ~  :: only forward this update if they are tracking this book
    `(fact:io graph-update-2+!>(update) (incoming-sub-path her name.update-rid)^~)
  ++  remove-library
    |=  [old=_state rid=resource]
    ^-  _state
    =/  new-readers
      %-  ~(run by readers.old)
      |=  prm=prim:library
      (~(del by prm) rid)
    old(readers new-readers)
  ++  remove-book
    ::  todo rename
    |=  [old=_state rid=resource indices=(set index:store)]
    ^-  _state
    =/  index-list  ~(tap by indices)
    =/  new-readers
      %-  ~(run by readers.old)
      |=  prm=prim:library
      ^-  prim:library
      |-
      ?~  index-list  prm  :: we've processed all indexes, return the modified prim
      =/  idx=index:store  i.index-list
      ?.  ?=([@ ~] idx)  $(index-list t.index-list)                   ::  this isn't a book to be deleted, so we don't handle it here
      $(index-list t.index-list, prm (~(del ju prm) rid (head idx)))  ::  stop tracking any readers for this book
    old(readers new-readers)
  --
::
++  handle-graph-update-incoming
  |=  [=update:store]
  ^-  (quip card _state)
  ~&  "got foreign graph update {<-.q.update>} from {<src.bowl>}"
  ~&  update
  =^  cards  state
    =/  wrapped-rid  (resource-for-update:gra !>(update))
    ?~  wrapped-rid  `state
    =/  rid          i.wrapped-rid
    ?>  =(src.bowl entity.rid)  :: only owners may send graph updates for resources they own
    [(poke-local-store update)^~ state]
  [cards state]
::
++  poke-local-store
  |=  [=update:store]
  ^-  card
  :: this is using a ~ wire. again, is this ok?
  (~(poke-our pass:io /) %graph-store graph-update-2+!>(update))
++  sub-to-library
  |=  [rid=resource]
  ^-  card
  =/  wir  /request-library/(scot %p entity.rid)/[name.rid]
  ::  note: agentio prepends "agentio-watch" to the provided wire
  (~(watch pass:io wir) [entity.rid %library-proxy] (outgoing-sub-path rid))
::  TODO probably rename to is-host
++  is-owner
  :: is the ship the owner of this proxys
  |=  [=ship]
  =(our.bowl ship)
::  also the naming is a bit confusing even for me
++  incoming-sub-path
  :: someone is subscribed to us
  |=  [reader=ship library-name=@tas]
  ^-  path
  /updates/(scot %p reader)/(scot %p our.bowl)/[library-name]
++  outgoing-sub-path
  :: we're subscribed to someone else
  |=  [rid=resource]
  ^-  path
  /updates/(scot %p our.bowl)/(scot %p entity.rid)/[name.rid]
++  scry-for
  |*  [=mold =path]
  .^  mold
    %gx
    (scot %p our.bowl)
    %library-proxy
    (scot %da now.bowl)
    (snoc `^path`path %noun)
  ==
--
