# railroad_paraphernalia
This mod introduces railroad equipment, mostly from the 1986 signaling manual for the USSR railways.

## Point levers
An accessory that makes a railroad switch look professional. Also helps
users of advtrains without train_operator privilege to operate switches in style.

The point levers are actually nothing but mesecon switches which look fancy.

### With black&white arrow:
```
{'dye:black', 'dye:white', 'dye:black'},
{'', 'default:stick', 'default:stick'},
{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
```

### With blue&yellow signal lamp:
```
{'dye:grey', 'dye:yellow', 'dye:white'},
{'', 'default:stick', 'default:stick'},
{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
```

While it should be a light source, the details of the model cannot be seen even when it
emits the minimal amount of light.

## Track Blocker
Prevents a train from passing a track segment by placing a "block" in its
way. Isn't synced with advtrains ndb, so works only with manned trains for now.
```
{'dye:white', 'dye:black', 'dye:white'},
{'', 'default:stick', ''},
{'dye:red', 'default:steel_ingot', 'default:steel_ingot'},
```

## Shunting signal
A small signal for shunting operations. Blue = shunting prohibited, white = shunting allowed.
```
{'', 'dye:white', ''},
{'', 'dye:blue', ''},
{'', 'default:stone', ''},
```

It accepts mesecon signals (on = switch to white, off = switch to blue)

## Delimiting post: 
It is placed near switches to show the point past which the locomotive may
not be parked, since it would collide with the train on the other track.
```
{'', 'dye:black', ''},
{'', 'dye:white', ''},
{'', 'default:stone', ''},
```