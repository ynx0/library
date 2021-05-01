# pinboard

Dead simple pinboard app

---

Using this application, you will be able to:

1. Create a library
1.5 have anothe ship subscribe
2. Add a book
	a. see the book in the other ship 
3. Add a comment to a book (from the other ship)
4. Revise the contents of a book
	a. see this in the other ship
5. Remove a comment (from the other ship)
6. Remove the book
7. Remove the library




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

