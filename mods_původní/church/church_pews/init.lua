
screwdriver = screwdriver or {}

local pews = {}

----------------------
-- functions for sitting
----------------------
--[[
--sit functions from xdecor mod written by jp
--Copyright (c) 2015-2016 kilbith <jeanpatrick.guerrero@gmail.com>   |
--Code: GPL version 3
--]]

local is_attached = function(player_name)
		return false
	end
local set_attach = function(player_name)
	end
local set_detach = function(player, player_name)
	end

if minetest.get_modpath("player_api") then
	is_attached = function(player_name)
			return player_api.player_attached[player_name]
		end
	set_attach = function(player_name)
			player_api.player_attached[player_name] = true
			minetest.after(0.2, function()
          local player = minetest.get_player_by_name(player_name)
          if player then
					  player_api.set_animation(player, "sit")
          end
				end)
		end
	set_detach = function(player, player_name)
			player_api.player_attached[player_name] = false
			player_api.set_animation(player, "stand")
		end
elseif minetest.get_modpath("hades_player") then
	is_attached = function(player_name)
			return hades_player.player_attached[player_name]
		end
	set_attach = function(player_name)
			hades_player.player_attached[player_name] = true
			minetest.after(0.2, function()
          local player = minetest.get_player_by_name(player_name)
          if player then
					  hades_player.player_set_animation(player, "sit")
          end
				end)
		end
	set_detach = function(player, player_name)
			hades_player.player_attached[player_name] = false
			hades_player.player_set_animation(player, "stand")
		end
end

local players = {}

local function sit(pos, node, clicker)
	local player = clicker:get_player_name()
	if is_attached(player) == true then
		pos.y = pos.y + 0.1
		clicker:set_pos(pos)
		clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		if players[player] then
			clicker:set_physics_override({speed=players[player].speed, jump=players[player].jump})
			players[player] = nil
		end
    set_detach(clicker, player)
	elseif --default.player_attached[player] ~= true and
		clicker:get_velocity().x == 0 and
		clicker:get_velocity().y == 0 and
		clicker:get_velocity().z == 0 and node.param2 <= 3 then

		clicker:set_eye_offset({x=0, y=-3, z=2}, {x=0, y=0, z=0})
    pos.y = pos.y + 0.2
		clicker:set_pos(pos)
		players[player] = clicker:get_physics_override()
  	clicker:set_physics_override({speed=0, jump=0})
    set_attach(player)

		if node.param2 == 0 then
			clicker:set_look_horizontal(3.15)
		elseif node.param2 == 1 then
			clicker:set_look_horizontal(7.9)
		elseif node.param2 == 2 then
			clicker:set_look_horizontal(6.28)
		elseif node.param2 == 3 then
			clicker:set_look_horizontal(4.75)
		end
	end
end

-------------------
-- Register Nodes
-------------------

pews.materials = {}

if minetest.get_modpath("default") then
	table.insert(pews.materials, {"acacia_wood", "Acacia Wood", "default_acacia_wood.png", "default:acacia_wood", "stairs:slab_acacia_wood"})
	table.insert(pews.materials, {"aspen_wood", "Aspen Wood", "default_aspen_wood.png", "default:aspen_wood", "stairs:slab_aspen_wood"})
	table.insert(pews.materials, {"junglewood", "Jungle Wood", "default_junglewood.png", "default:junglewood", "stairs:slab_junglewood"})
	table.insert(pews.materials, {"pine_wood", "Pine Wood", "default_pine_wood.png", "default:pine_wood", "stairs:slab_pine_wood"})
	table.insert(pews.materials, {"wood", "Appletree Wood", "default_wood.png", "default:wood", "stairs:slab_wood"})
end

if minetest.get_modpath("hades_trees") then
	table.insert(pews.materials, {"wood", "Temperate Wood", "default_wood.png", "hades_trees:wood", "hades_stairs:slab_wood"})
	table.insert(pews.materials, {"pale_wood", "Pale Wood", "hades_trees_pale_wood.png", "hades_trees:pale_wood", "hades_stairs:slab_pale_wood"})
	table.insert(pews.materials, {"cream_wood", "Cream Wood", "hades_trees_cream_wood.png", "hades_trees:cream_wood", "hades_stairs:slab_cream_wood"})
	table.insert(pews.materials, {"lush_wood", "Lush Wood", "hades_trees_lush_wood.png", "hades_trees:lush_wood", "hades_stairs:slab_lush_wood"})
	table.insert(pews.materials, {"jungle_wood", "Jungle Wood", "hades_trees_jungle_wood.png", "hades_trees:jungle_wood", "hades_stairs:slab_jungle_wood"})
	table.insert(pews.materials, {"charred_wood", "Charred Wood", "hades_trees_charred_wood.png", "hades_trees:charred_wood", "hades_stairs:slab_charred_wood"})
	table.insert(pews.materials, {"canvas_wood", "Canvas Wood", "hades_trees_canvas_wood.png", "hades_trees:canvas_wood", "hades_stairs:slab_canvas_wood"})
end

local wood_sounds = nil
if minetest.get_modpath("sounds") then
	wood_sounds = sounds.node_wood()
elseif minetest.get_modpath("default") then
	wood_sounds = default.node_sound_wood_defaults()
elseif minetest.get_modpath("hades_sounds") then
	wood_sounds = hades_sounds.node_sound_wood_defaults()
end

for _, row in ipairs(pews.materials) do
	local name = row[1]
	local desc = row[2]
	local tiles = row[3]
	local craft_material = row[4]
  local slab_material = row[5]

	minetest.register_node("church_pews:church_pew_left_"..name, {
		drawtype = "nodebox",
		description = desc.." Pew",
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		groups = {oddly_breakable_by_hand= 3, snappy = 3, choppy = 3, cracky = 3, not_in_creative_inventory = 1},
		sounds = wood_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = 'fixed',
			fixed = {
				{-0.375, -0.375, 0.3125, 0.5, -0.25, 0.375},
				{-0.375, -0.25, 0.375, 0.5, 0.3125, 0.4375},
				{-0.5, -0.5, 0.25, -0.3125, 0.375, 0.5},
				{-0.5, -0.3125, -0.25, -0.3125, -0.0625, 0.25},
				{-0.4375, -0.0625, -0.25, -0.375, 0.125, 0.25},
				{-0.4375, 0.125, -0.125, -0.375, 0.1875, 0.25},
				{-0.5, -0.5, -0.4375, -0.3125, 0.0625, -0.25},
				{-0.4375, 0.125, 0.0625, -0.375, 0.25, 0.3125},
				{-0.3125, -0.25, -0.25, 0.5, -0.1875, 0.3125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.25, 0.5, 0.0, 0.375},
			},
		},
  on_rightclick = function(pos, node, clicker)
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
		for _, p in pairs(objs) do
			if p:get_player_name() ~= clicker:get_player_name() then return end
		end
		pos.y = pos.y -0.25
		sit(pos, node, clicker)
	end,
	can_dig = function(pos, player)
		local pname = player:get_player_name()
		local objs = minetest.get_objects_inside_radius(pos, 0.5)

    for _, p in pairs(objs) do
     if p:get_player_name() ~= nil or
      is_attached(pname) == true or not
      player or not player:is_player() then
      return false
     end
    end
    return true
   end
  })

	minetest.register_node("church_pews:church_pew_right_"..name, {
		drawtype = "nodebox",
		description = desc.." Pew",
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = "",
		groups = {oddly_breakable_by_hand= 3, snappy = 3, choppy = 3, cracky = 3, not_in_creative_inventory = 1},
		sounds = wood_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = 'fixed',
			fixed = {
				{-0.5, -0.375, 0.3125, 0.3125, -0.25, 0.375},
				{-0.5, -0.25, 0.375, 0.3125, 0.3125, 0.4375},
				{0.3125, -0.5, 0.25, 0.5, 0.375, 0.5},
				{0.3125, -0.3125, -0.25, 0.5, -0.0625, 0.25},
				{0.375, -0.0625, -0.25, 0.4375, 0.125, 0.25},
				{0.375, 0.125, -0.125, 0.4375, 0.1875, 0.25},
				{0.3125, -0.5, -0.4375, 0.5, 0.0625, -0.25},
				{0.375, 0.125, 0.0625, 0.4375, 0.25, 0.3125},
				{-0.5, -0.25, -0.25, 0.3125, -0.1875, 0.3125},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.25, 0.5, 0.0, 0.375},
			},
		},
  on_rightclick = function(pos, node, clicker)
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
		for _, p in pairs(objs) do
			if p:get_player_name() ~= clicker:get_player_name() then return end
		end
		pos.y = pos.y -0.25
		sit(pos, node, clicker)
	end,
	can_dig = function(pos, player)
		local pname = player:get_player_name()
		local objs = minetest.get_objects_inside_radius(pos, 0.5)

    for _, p in pairs(objs) do
     if p:get_player_name() ~= nil or
      is_attached(pname) == true or not
      player or not player:is_player() then
      return false
     end
    end
    return true
   end
  })

	minetest.register_node("church_pews:church_pew_" ..name, {
		drawtype = "nodebox",
		description = desc.." Pew",
		--inventory_image = 'pews_' ..name.. '_inv.png',
		tiles = { tiles },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {oddly_breakable_by_hand= 3, snappy = 3, choppy = 3, cracky = 3},
		sounds = wood_sounds,
		on_rotate = screwdriver.rotate_simple,
		node_box = {
			type = 'fixed',
			fixed = {
				{-0.5, -0.375, 0.3125, 0.5, -0.25, 0.375},
				{-0.5, -0.25, 0.375, 0.5, 0.3125, 0.4375},
				{-0.5, -0.25, -0.25, 0.5, -0.1875, 0.375},
			},
		},
		selection_box = {
   type = "fixed",
   fixed = {
    {-0.5, -0.5, -0.25, 0.5, 0.0, 0.375},
   },
	},
  after_place_node =function(pos, placer)
		local wheretoplace = minetest.dir_to_facedir(placer:get_look_dir())
		local p1 = {x=pos.x, y=pos.y, z=pos.z} -- player's left
		local p2 = {x=pos.x, y=pos.y, z=pos.z} -- player's right
		if wheretoplace == 0 then --facing direction z
			p1 = {x=pos.x-1, y=pos.y, z=pos.z}  -- -x
			p2 = {x=pos.x+1, y=pos.y, z=pos.z} -- x
		elseif wheretoplace == 1 then -- facing direction x
			p1 = {x=pos.x, y=pos.y, z=pos.z+1}  -- +z
			p2 = {x=pos.x, y=pos.y, z=pos.z-1} -- -z
		elseif wheretoplace == 2 then -- facing direction -z
			p1 = {x=pos.x+1, y=pos.y, z=pos.z}  -- x
			p2 = {x=pos.x-1, y=pos.y, z=pos.z}  -- -x
		else  -- facing direction -x
			p1 = {x=pos.x, y=pos.y, z=pos.z-1}  -- -z
			p2 = {x=pos.x, y=pos.y, z=pos.z+1}  -- +z
		end
		local n1 = minetest.get_node(p1)
		local n2 = minetest.get_node(p2)
			if n1.name == "air" then
				minetest.add_node(p1,{name="church_pews:church_pew_left_"..name, param2=minetest.dir_to_facedir(placer:get_look_dir())})
			end
			if n2.name == "air" then
				minetest.add_node(p2,{name="church_pews:church_pew_right_"..name, param2=minetest.dir_to_facedir(placer:get_look_dir())})
			end
		end,
  on_rightclick = function(pos, node, clicker)
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
		for _, p in pairs(objs) do
			if p:get_player_name() ~= clicker:get_player_name() then return end
		end
		pos.y = pos.y -0.25
		sit(pos, node, clicker)
	end,
	can_dig = function(pos, player)
		local pname = player:get_player_name()
		local objs = minetest.get_objects_inside_radius(pos, 0.5)

    for _, p in pairs(objs) do
     if p:get_player_name() ~= nil or
      is_attached(pname) == true or not
      player or not player:is_player() then
      return false
     end
    end
    return true
   end
	})


---------------------------
-- Register Craft Recipes
---------------------------
	if craft_material then
		minetest.register_craft({
			output = 'church_pews:church_pew_' ..name.. ' 3',
			recipe = {{slab_material, craft_material, slab_material}}
		})
	end

end
