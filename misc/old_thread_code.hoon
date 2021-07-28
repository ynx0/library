:: old thread based scry function
:: beware: moldy code
|%
:: Thread Only Functions: Can only be called as a strand/ in a spider context
++  scry-for
  :: unholy child of
  :: https://github.com/urbit/urbit/blob/9c9446d77f0969846b1cebd12f6290d513375ad4/pkg/arvo/lib/graph.hoon#L4
  :: and https://github.com/urbit/urbit/blob/ab4356ea88f531788845dd47efe0b571dd1ae446/pkg/arvo/ted/graph/add-nodes.hoon#L6
  |*  [=mold =path]
  =/  m  (strand:spider ,mold)
  ^-  form:m
  ;<  result=mold   bind:m
    %+  scry:strandio  mold  (weld /gx/graph-store (snoc `^path`path %noun))
  (pure:m result)
::
++  got-node
  ::  based off of https://github.com/urbit/urbit/blob/master/pkg/arvo/lib/graph.hoon#L65-L67
  |=  [res=resource =index]
  =/  m  (strand:spider ,node)
  ^-  form:m
  ;<  =update  bind:m  (scry-for update (weld /node/(scot %p entity.res)/[name.res] (turn index (cury scot %ud))))
  ?>  ?=(%add-nodes -.q.update)
  ?>  ?=(^ nodes.q.update)  :: might not work
  =/  out-node  ;;(node +>->.q.update)  :: this is really ugly code. gotta figure out how not to use +>->
  (pure:m out-node)
::
++  get-latest-node
  |=  [=graph]
  ^-  (unit node)
  :: todo proper unit code
  :: todo, make ?> assertions so that you don't have to use lark syntax
  :: unwrapped: given a revision container node:
  :: 1. get its children, which nets a graph of all revisions
  :: 2. discard the leading %graph term
  :: 3. listify the children, with greatest key first
  :: 4. get the first element of the list
  :: 5. get the value from key/value pair of key = index fragment, val = node
  ::=/  revisions  +.children.rev-container-node
  =/  node-list=(list (pair atom node))  (tap:orm graph)
  ::?~  node-list  ~  :: why doesn't this line work????? i literally had it working like 2 seconds ago AHhhh
  =/  latest-node  (snag 0 node-list)
  [~ +:latest-node]
--