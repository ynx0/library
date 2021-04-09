# pinboard

Dead simple pinboard app

---

Using this application, you will be able to:

1. Create a pinboard
2. Create a pin
3. Delete a pin
4. Modify a pin's content
5. Modify a pin's position


First, create a group.

```
-group-create [%create %my-group [%open *(set rank:title) *(set ship)] 'pin group' 'a group mainly about pins']
```

You can look at the current state of a given agent using the syntax `:<the-agent> +dbug`

Verify that the group was created.

```
:group-store +dbug [%state 'groups']
>   { [ p=[entity=~zod name=%my-group]
    q=[members={~zod} tags={[p=%admin q={~zod}]} policy=[%open ban-ranks={} banned={}] hidden=%.n]
  ]
}
```


Then, create a new graph using the pinboard validator.

```
-graph-create [%create [our %pinboard-1] 'The First Pinboard' 'the first pinboard to exist' `%graph-validator-pinboard [%group [our %my-group]] '']
```

Verify that the graph was properly created.
```
:graph-store +dbug [%state 'graphs']
>   {[p=[entity=~zod name=%pinboard-1] q=[p={} q=[~ %graph-validator-pinboard]]]}
```

Create and add a new pin to the pinboard, specifying its title text, body text, and coordinates
```
-pinboard-create-pin [our %pinboard-1] 'Chores' 'Buy groceries' [x=5 y=10]
```

Verify that the pin was created successfully.
```
:graph-store +dbug [%state 'graphs']
```


Edit the contents by adding a new revision.
```
-pinboard-edit-contents [our %pinboard-1] 1 'Chores' 'Buy groceries. Eat lunch.'
```

Verify that a revision node was created successfully.
```
:graph-store +dbug [%state 'graphs']
```

Edit the metadata by adding a new revision, specifying the index of the pin.
```
-pinboard-edit-metadata [our %pinboard-1] 1 [x=15 y=20]
```

Verify that a revision node was created successfully.
```
:graph-store +dbug [%state 'graphs']
```

Delete the pin, specifying it's index.
```
-pinboard-delete-pin [our %pinboard-1] 1
```

Verify that a revision node was created successfully.
```
:graph-store +dbug [%state 'graphs']
```

