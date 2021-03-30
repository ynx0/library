/-  *graph-store, post
|%
:: extract shared logic into a core with inferior/nested arms?
:: we need arms for:
:: * creating a new pin
++  add-pin
  |=  [top=@ author=ship time-sent=time title=cord body=cord coords=[x=cord y=cord]]
  ^- (map index node)
  =|  blank=post
  =:  author.blank     author
      time-sent.blank  time-sent
      contents.blank   ~
  ==
  =/  pin-contents
    ~[[%text title] [%text body]]
  =/  meta-contents
    ~[[%text x:coords] [%text y:coords]]
  %-  ~(gas by *(map index node))
  :~
      [~[top] [blank(index ~[top]) [%empty ~]]]
      [~[top %meta] [blank(index ~[top %meta]) [%empty ~]]]
      [~[top %meta 1] [blank(index ~[top %meta 1], contents meta-contents) [%empty ~]]]
      [~[top %pin] [blank(index ~[top %pin]) [%empty ~]]]
      [~[top %pin 1] [blank(index ~[top %pin 1], contents pin-contents) [%empty ~]]]
  ==
::
:: * creating a new metadata revision
++  meta-rev  
  |=  [top=@ coords=[x=cord y=cord]]
  !!
:: * creating a new content revision
++  pin-rev
  |= [=uid]
  !!
:: * deleting a pin from a graph
++  remove-pin
--
