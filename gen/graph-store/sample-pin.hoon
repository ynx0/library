/-  *graph-store
=>
|%
++  pin-text
  'This is some sample pin text.'
++  coordinates  [x=0 y=0]
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
=/  pin-contents
  ~[[%text title] [%text pin-text]]
::~&  pin-text
::~&  coordinates
=/  meta-contents
  ~[[%text 0] [%text 0]]
:-  %graph-update
^-  update
:+  %0  now
:+  %add-nodes  [our name]
%-  ~(gas by *(map index node))
:~
    [~[top] [blank(index ~[top]) [%empty ~]]]
    [~[top %meta] [blank(index ~[top %meta]) [%empty ~]]]
::    [~[top %meta 1] [blank(index ~[top %meta 1], contents ~[[%text '0']]) [%empty ~]]]
    [~[top %pin] [blank(index ~[top %pin]) [%empty ~]]]
::    [~[top %pin 1] [blank(index ~[top %pin 1], contents pin-contents) [%empty ~]]]
==
