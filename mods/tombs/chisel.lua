minetest.register_tool('tombs:chisel', {
   description = 'rydlo na náhrobky',
   inventory_image = 'tombs_chisel.png',
   wield_image = 'tombs_chisel.png',
})

minetest.register_craft({
   output = 'tombs:chisel',
   recipe = {
      {'default:steel_ingot', ''},
      {'', 'default:tin_ingot'},
   }
})
