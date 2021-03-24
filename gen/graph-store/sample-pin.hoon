/-  *graph-store
=>
|%
++  article-text
  'Sample text здесь'
--
:-  %say
|=  $:  [now=@da eny=@uvJ =beak]
        [[[our=ship name=term] top=@ title=cord ~] ~]
    ==
=|  blank=post
=:  author.blank     our
    time-sent.blank  now
    contents.blank   ~
==
=/  section-contents
  ~[[%text article-text]]
:-  %graph-update
^-  update
:+  %0  now
:+  %add-nodes  [our name]
%-  ~(gas by *(map index node))
:~
    [~[top] [blank(index ~[top], contents ~[[%text title]]) [%empty ~]]]
    [~[top %sections] [blank(index ~[top %sections]) [%empty ~]]]
    [~[top %sections 1] [blank(index ~[top %sections 1], contents section-contents) [%empty ~]]]
::    [~[top %chapters] [blank(index ~[top %chapters]) [%empty ~]]]
::    [~[top %chapters 1] [blank(index ~[top %chapters 1], contents chapter-contents) [%empty ~]]]
==
