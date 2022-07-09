Clothing API
============


Global callbacks
----------------

### function on\_update(player)
  player -> player object

Called when clothing texture is updated.

Use ***clothing:register_on_update(fucntion)*** to register it.

### function on\_load(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when any item from player clothing inventory is loaded.
It happens when player is joined to server.

Use ***clothing:register_on_load(fucntion)*** to register it.

### function on\_equip(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when any item is put into player clothing inventory.

Use ***clothing:register_on_equip(fucntion)*** to register it.

### function on\_unequip(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when any item is take from player clothing inventory.

Use ***clothing:register_on_unequip(fucntion)*** to register it.

Clothes callbacks
-----------------

Defined in clothes item definition stored in ***minetest.registered\_items***.

### function on\_load(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when specific item is loaded into player clothing inventory.
It happens when player is joined to server.

Use ***item\_def.on\_load(function)*** field in item definition to use this function.

### function on\_equip(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when specific item is put into player clothing inventory.

Use ***item\_def.on\_equip(function)*** field in item definition to use this function.

### function on\_unequip(player, index, stack)
  player -> player object
  index -> index in inventory
  stack -> ItemStack item

Called when specific item is take from player clothing inventory.

Use ***item\_def.on\_unequip(function)*** field in item definition to use this function.
