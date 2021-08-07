/-  *resource, library
/+  store=graph-store, graph, default-agent,
    dbug, verb, agentio, libr=library
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
    ?~  wire  ~|("empty wire, can't resubscribe. this shouldn't happen" `this)
    ::
    ?>  ?=([%request-library @ @ ~] wire)
    =/  host  (slav %p i.t.wire)
    =/  name  `@tas`i.t.t.wire
    [(sub-to-library:hc [host name])^~ this]
  ::
      %watch-ack
    ?~  p.sign
      ~&  >   "subscribed on wire {<wire>} successfully"
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
      [%updates @ @ ~]
    ::  path format:  /updates/[src.bowl]/[name.rid]
    ::  human format: /updates/[subscriber-ship]/[library-name]
    =/  subscriber    `@p`(slav %p i.t.path)
    =/  library-name  `@tas`i.t.t.path
    ?<  (is-owner:hc src.bowl)    :: do not allow ourselves to subscribe, invalid
    ?>  =(subscriber src.bowl)    :: check for imposter (sus)
    =/  policy  (~(got by policies) library-name)
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
    =.  readers  
      %+  ~(put by readers)
        subscriber
      (~(gas by *prim:library) [[library-name *(set atom)] ~])
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
        (scry-for:gra (unit @tas) /graph/(scot %p entity.key)/[name.key]/mark)
      =(`%graph-validator-library mark)
    =/  library-names  (silt (turn ~(tap in library-keys) tail))
    ``noun+!>(`(set @tas)`library-names)
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
    =/  library-name  library-name.command
    =/  time-sent     now.bowl
    =/  policy        policy.command
    =.  policies      (~(put by policies) library-name policy)  :: set the policy for the given rid into the actual state
    (poke-local (create-library:libr [our.bowl library-name] time-sent))
  ::
      %remove-library
    =/  library-name  library-name.command
    =/  time-sent     now.bowl
    =.  policies      (~(del by policies) library-name)       ::  remove the policy for the given rid from
    (poke-local (remove-library:libr [our.bowl library-name] time-sent))
  ::
      %add-book
    =/  library-name  library-name.command
    =/  author        our.bowl
    =/  time-sent     now.bowl
    =/  book          book.command
    (poke-local (add-book:libr [our.bowl library-name] author time-sent book))
  ::
      %revise-book
    =/  library-name  library-name.command
    =/  top           top.command
    =/  new-book      new-book.command
    =/  author        our.bowl
    =/  time-sent     now.bowl
    =/  update  (scry-for:gra update:store /graph/(scot %p our.bowl)/[library-name])
    ?>  ?=(%add-graph -.q.update)
    =/  meta-node         (got-deep:gra graph.q.update ~[top %meta])
    =/  meta-child-graph
      ?>  ?=(%graph -.children.meta-node)  :: invariant: book will always have at least one revision, i.e. the first ever revisoni, i.e. the original book metadata. this could be made more lax, to automatically create one if missing, but i don't think it makes sense to be lax here...
      p.children.meta-node
    =/  latest-revision-node  (need (pry:orm:store meta-child-graph))
    =/  last-revision-index   ~[top %meta key.latest-revision-node]  :: we use this construction instead of doing the index.p.post.node dance because it works even if the post has been deletedd (which it should never but i guess its easier to code)
    =/  new-index             (incr-index:libr last-revision-index)
    (poke-local (revise-book-meta:libr [our.bowl library-name] new-index author time-sent new-book))
  ::
      %remove-book
    =/  library-name  library-name.command
    =/  top           top.command
    =/  time-sent     now.bowl
    ::  removing the book from `readers` is handled during the handling of %remove-graph
    ::  because it needs the metadata to know who to send the update to
    (poke-local (remove-book:libr [our.bowl library-name] top time-sent))
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
    =/  =action:library  [%get-book name.rid top]
    ::  this should crash if we haven't %request-library'd first.
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
      =/  library-name  library-name.action
      =/  top           top.action
      =/  author        src.bowl
      =/  time-sent     now.bowl
      =/  comment       comment.action
      =/  prm           (~(get by readers) author)
      ::                                                   ::  commenter must be either:
      ?>  ?|  (is-owner author)                            ::  us
              (~(has ju (need prm)) library-name top)      ::  someone with permissions
          ==
      =/  update  (add-comment:libr [our.bowl library-name] top author time-sent comment)
      [(poke-local-store update)^~ state]
    ::
        %remove-comment
      =/  library-name   library-name.action
      =/  comment-index  index.action
      ?>  ?=([@ %comments @ ~] comment-index)
      =/  prev-comment-update
        (scry-for:gra update:store (weld /graph/(scot %p our.bowl)/[library-name]/node/index/kith (index-to-path:libr comment-index)))
      ?.  (can-remove-comment src.bowl comment-index prev-comment-update)
        `state  :: if requesting ship cannot remove comment, silently ignore
      =/  remove-update  (remove-comment:libr [our.bowl library-name] comment-index now.bowl)
      [(poke-local-store remove-update)^~ state]
    ::
        %get-book
      =/  library-name  library-name.action
      =/  top           book-index.action
      =/  policy           (~(get by policies) library-name)
      ?~  policy           `state                               :: if there is no policy set for the given rid, it is an invalid request. ignore
      ?.  (is-allowed:libr src.bowl our.bowl u.policy)  `state  :: only give them the books if they are allowed
      ?<  =(our.bowl src.bowl)    :: invalid, disallow ourselves from requesting from our own library
      =/  libraries  (scry-for (set @tas) /libraries)
      ?>  (~(has in libraries) library-name)
      :: 1. add the person to readers
      =/  prm  (fall (~(get by readers) src.bowl) *prim:library)
      =.  prm  (~(put ju prm) library-name top)
      =.  readers  (~(put by readers) src.bowl prm)
      :: 2. send them the graph update
      =/  update  (scry-for:gra update:store /graph/(scot %p our.bowl)/[library-name]/node/index/kith/(scot %ud top))
      :_  state
      :~  (fact:io graph-update-2+!>(update) ~[(incoming-sub-path src.bowl library-name)])
      ==
    ::
        %get-libraries
      =/  libraries  (scry-for (set @tas) /libraries)
      =?  libraries  !(is-owner src.bowl)  :: filter out allowed libraries if requester isn't the owner
        %-  silt
        %+  skim  ~(tap in libraries)
        |=  [library-name=@tas]
        =/  policy  (~(got by policies) library-name)
        (is-allowed:libr src.bowl our.bowl policy)
      :_  state
      :~  (~(poke pass:io /) [src.bowl %library-proxy] library-response+!>(available-libraries+libraries))
      ==
    ::
        %get-books
      ::  todo if/when full-text/extra info is enabled, the resulting data could be a set of book-indexes along with just title and isbn without(!)
      ::  fulltext, so that you only download the fulltext of books that you care about, and you have more metadata to judge by
      =/  library-name     library-name.action
      =/  policy           (~(get by policies) library-name)
      ?~  policy           `state                               :: if there is no policy set for the given rid, it is an invalid request. ignore
      ?.  (is-allowed:libr src.bowl our.bowl u.policy)  `state  :: only give them list of books if they are allowed
      =/  book-indexes  (scry-for (set atom) /books/[library-name])
      :_  state
      :~  (~(poke pass:io /) [src.bowl %library-proxy] library-response+!>(available-books+[library-name book-indexes]))
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
    ~&  library-name.response
    ~&  book-indexes.response
    `state
  ==
++  handle-graph-update-outgoing
  |=  [=update:store]
  |^  ^-  (quip card _state)
  ::  this is where we forward any graph store updates to any subscriber of ours
  =^  cards  state
    :: resource-for-update always returns a list of one (1) resource
    =/  wrapped-rid   (resource-for-update:gra !>(update))
    ?~  wrapped-rid
      `state       :: if theres no resource, we don't forward cause we can't tell if its something based on our own resource
    =/  update-rid    i.wrapped-rid
    ?.  =(our.bowl entity.update-rid)
      `state  :: we only broadcast updates for resources we own
    =/  library-name  name.update-rid
    ?+    -.q.update        ~&("ignoring update {<-.q.update>}" `state)
        %add-graph          `state  :: do not forward add graph to anyone. this gets manually forwarded in on-watch
    ::
        ::  the following pokes should never be forwarded
        %archive-graph      `state
        %unarchive-graph    `state
        %run-updates        `state
    ::
        %add-signatures     [(send-if-tracking-uid update library-name index.uid.q.update) state]
        %remove-signatures  [(send-if-tracking-uid update library-name index.uid.q.update) state]
        %add-tag            [(send-if-tracking-uid update library-name index.uid.q.update) state]
        %remove-tag         [(send-if-tracking-uid update library-name index.uid.q.update) state]
    ::
        %remove-graph
      :_  =/  new-state  (remove-library state library-name)
      new-state
      %-  zing
      ~&  readers
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-libraries  ~(key by prm)
      ?.  (~(has in tracked-libraries) library-name)  ~  :: only send the update if her is tracking this resource
      %-  some
      =/  paths  (incoming-sub-path her library-name)^~
      :~  (fact:io graph-update-2+!>(update) paths)
          (kick-only:io her paths)
      ==
    ::
        %add-nodes
      :_  state
      %-  zing
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-books=(unit (set @))  (~(get by prm) library-name)
      ?~  tracked-books  ~  :: if they aren't tracking any books yet, don't bother making cards
      %-  some
      %+  murn  ~(tap by nodes.q.update)
      |=  [idx=index:store *]
      ?.  (~(has in u.tracked-books) (head idx))  ~  :: only forward this update if they are tracking this book
      `(fact:io graph-update-2+!>(update) (incoming-sub-path her library-name)^~)
    ::
        %remove-posts
      ::  need to clear reader state *after* creating cards, cause we can't create card without state
      :_   =/   new-state  (remove-any-books state library-name indices.q.update)
      new-state
      %+  murn  ~(tap by readers)
      |=  [her=ship prm=prim:library]
      =/  tracked-books=(unit (set @))
        (~(get by prm) library-name)
      :: if no tracked books for this resource, don't bother making any cards
      ?~  tracked-books  ~
      :: ensure that users who receive a remove-posts
      :: only receive it for indices that they would have
      =.  indices.q.update  (filter-indices indices.q.update u.tracked-books)
      `(fact:io graph-update-2+!>(update) (incoming-sub-path her library-name)^~)
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
    |=  [=update:store library-name=@tas idx=index:store]
    ^-  (list card)
    %+  murn  ~(tap by readers)
    |=  [her=ship prm=prim:library]
    =/  tracked-books=(unit (set @))
      (~(get by prm) library-name)
    :: if no tracked books for this resource, don't bother making any cards
    ?~  tracked-books  ~
    ?.  (~(has in u.tracked-books) (head idx))  ~  :: only forward this update if they are tracking this book
    `(fact:io graph-update-2+!>(update) (incoming-sub-path her library-name)^~)
  ++  remove-library
    |=  [old=_state name=@tas]
    ^-  _state
    =/  new-readers
      %-  ~(run by readers.old)
      |=  prm=prim:library
      (~(del by prm) name)
    old(readers new-readers)
  ++  remove-any-books
    ::  if any indexes are pointing to books
    ::  clear them from the state
    |=  [old=_state library-name=@tas indices=(set index:store)]
    ^-  _state
    =/  index-list  ~(tap by indices)
    =/  new-readers
      %-  ~(run by readers.old)
      |=  prm=prim:library
      ^-  prim:library
      |-
      ?~  index-list  prm  :: we've processed all indexes, return the modified prim
      =/  idx=index:store  i.index-list
      ?.  ?=([@ ~] idx)  $(index-list t.index-list)                            ::  the index doesn't match a book to be deleted, so we skip handling it here
      $(index-list t.index-list, prm (~(del ju prm) library-name (head idx)))  ::  stop tracking any readers for this book
    old(readers new-readers)
  --
::
++  handle-graph-update-incoming
  |=  [=update:store]
  ^-  (quip card _state)
  ~&  "got foreign graph update {<-.q.update>} from {<src.bowl>}"
  ::~&  update
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
  (~(poke-our pass:io /) %graph-store graph-update-2+!>(update))
++  sub-to-library
  |=  [rid=resource]
  ^-  card
  =/  wir  /request-library/(scot %p entity.rid)/[name.rid]
  ::  note: agentio prepends "agentio-watch" to the provided wire
  (~(watch pass:io wir) [entity.rid %library-proxy] (outgoing-sub-path name.rid))
::  TODO probably rename to is-host
++  is-owner
  :: is the ship the owner of this proxys
  |=  [=ship]
  =(our.bowl ship)
++  incoming-sub-path
  :: someone is subscribed to us
  |=  [reader=ship library-name=@tas]
  ^-  path
  /updates/(scot %p reader)/[library-name]
++  outgoing-sub-path
  :: we're subscribed to someone else
  |=  [library-name=@tas]
  ^-  path
  /updates/(scot %p our.bowl)/[library-name]
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
