--_swap tool____________
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
  pos.y = pos.y 
  	local name = minetest.get_node(pos).name
	        if name ~= "default:sand" 
	       and name ~= "default:silver_sand"
	       and name ~= "default:desert_sand" then
		return
	end 
	pos.y = pos.y 
   if puncher:get_wielded_item():get_name() == "summer:rake"
    then
      minetest.remove_node(pos)
          node.name = "summer:sabbia_mare"
           minetest.set_node(pos, node)
          
           minetest.sound_play("summer_n_swap", {
   to_player = "",
   gain = 2.0,})
 
end
 end )


--SABBIA
minetest.register_node("summer:sabbia_mare", {
	description = "Sabbiamare",
	tiles = {"sabbia_mare_2.png"},
	--groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	drop = 'summer:sabbia_mare',
	--legacy_mineral = true,
groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = default.node_sound_sand_defaults(),
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_tool("summer:rake", {
   description = "rake",
   inventory_image = "rake.png",
   [[on_place = function(itemstack, user, pointed_thing)
      minetest.sound_play("summer_n_swap_2", {   
         to_player = user:get_player_name() ,
         gain = 2.0
      })]]
     

 
})
