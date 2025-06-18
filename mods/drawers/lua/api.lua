--[[
Minetest Mod Storage Drawers - A Mod adding storage drawers

Copyright (C) 2017-2020 Linus Jahn <lnj@kaidan.im>
Copyright (C) 2016 Mango Tango <mtango688@gmail.com>

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-- Load support for intllib.
local MP = core.get_modpath(core.get_current_modname())
local S = minetest.get_translator("drawers")
local NS = S

local has_wrench = minetest.get_modpath("wrench")

drawers.node_box_simple = {
	{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5},
	{-0.5, -0.5, -0.5, -0.4375, 0.5, -0.4375},
	{0.4375, -0.5, -0.5, 0.5, 0.5, -0.4375},
	{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375},
	{-0.4375, -0.5, -0.5, 0.4375, -0.4375, -0.4375},
}

drawers.drawer_formspec = "size[9,7]" ..
	"list[context;upgrades;2,0.5;1,1;]" ..
	"list[current_player;main;0,3;9,4;]" ..
	drawers.gui_bg ..
	drawers.gui_bg_img ..
	drawers.gui_slots ..
	drawers.get_upgrade_slots_bg(2, 0.5)

local wrench_defs

if has_wrench then
	wrench_defs = {}

	for _, i in ipairs({1, 2, 4}) do
		local metas = {formspec = wrench.META_TYPE_IGNORE, owner = wrench.META_TYPE_STRING}
		for j = 1, i do
			local s
			if i == 1 then
				s = ""
			else
				s = tostring(j)
			end
			metas["name"..s] = wrench.META_TYPE_STRING
			metas["count"..s] = wrench.META_TYPE_INT
			metas["max_count"..s] = wrench.META_TYPE_INT
			metas["base_stack_max"..s] = wrench.META_TYPE_INT
			metas["entity_infotext"..s] = wrench.META_TYPE_STRING
			metas["stack_max_factor"..s] = wrench.META_TYPE_INT
		end
		wrench_defs[i] = {
			lists = {"upgrades"},
			metas = metas,
			after_place = drawers.spawn_visuals,
			owned = true,
		}
	end
end
drawers.wrench_defs = wrench_defs

-- construct drawer
function drawers.drawer_on_construct(pos)
	local node = core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local drawerType = ndef.groups.drawer

	local base_stack_max = 100
	local stack_max_factor = ndef.drawer_stack_max_factor or 36 -- 4x8
	stack_max_factor = math.floor(stack_max_factor / drawerType) -- drawerType => number of drawers in node

	-- meta
	local meta = core.get_meta(pos)

	local i = 1
	while i <= drawerType do
		local vid = i
		-- 1x1 drawers don't have numbers in the meta fields
		if drawerType == 1 then vid = "" end
		meta:set_string("name"..vid, "")
		meta:set_int("count"..vid, 0)
		meta:set_int("max_count"..vid, base_stack_max * stack_max_factor)
		meta:set_int("base_stack_max"..vid, base_stack_max)
		--[[ meta:set_string("entity_infotext"..vid, drawers.gen_info_text(S("Empty"), 0,
			stack_max_factor, base_stack_max)) ]]
		meta:set_int("stack_max_factor"..vid, stack_max_factor)

		i = i + 1
	end

	-- spawn all visuals
	core.after(0.25, function(npos, nname)
		if core.get_item_group(core.get_node(npos).name, "drawer") ~= 0 then
			drawers.spawn_visuals(npos)
			for i = 1, drawerType do
				local v = drawers.get_visual(npos, i)
				if v ~= nil then
					v:updateInfotext()
				end
			end
		end
	end, pos)

	-- create drawer upgrade inventory
	meta:get_inventory():set_size("upgrades", 1)

	-- set the formspec
	-- meta:set_string("formspec", drawers.drawer_formspec)
end

-- destruct drawer
function drawers.drawer_on_destruct(pos)
	drawers.remove_visuals(pos)

	-- clean up visual cache
	if drawers.drawer_visuals[core.hash_node_position(pos)] then
		drawers.drawer_visuals[core.hash_node_position(pos)] = nil
	end
end

-- drop all items
function drawers.drawer_on_dig(pos, node, player)
	local drawerType = 1
	if core.registered_nodes[node.name] then
		drawerType = core.registered_nodes[node.name].groups.drawer
	end
	if core.is_protected(pos,player:get_player_name()) then
	   core.record_protection_violation(pos,player:get_player_name())
	   return 0
	end
	local meta = core.get_meta(pos)

	local k = 1
	while k <= drawerType do
		-- don't add a number in meta fields for 1x1 drawers
		local vid = tostring(k)
		if drawerType == 1 then vid = "" end
		local count = meta:get_int("count"..vid)
		local name = meta:get_string("name"..vid)

		-- drop the items
		local stack_max = ItemStack(name):get_stack_max()

		local j = math.floor(count / stack_max) + 1
		local i = 1
		while i <= j do
			local rndpos = drawers.randomize_pos(pos)
			if not (i == j) then
				core.add_item(rndpos, name .. " " .. stack_max)
			else
				core.add_item(rndpos, name .. " " .. count % stack_max)
			end
			i = i + 1
		end
		k = k + 1
	end

	-- drop all drawer upgrades
	local upgrades = meta:get_inventory():get_list("upgrades")
	if upgrades then
		for _,itemStack in pairs(upgrades) do
			if itemStack:get_count() > 0 then
				local rndpos = drawers.randomize_pos(pos)
				core.add_item(rndpos, itemStack)
			end
		end
	end

	-- remove node
	core.node_dig(pos, node, player)
end

function drawers.drawer_allow_metadata_inventory_put(pos, listname, index, stack, player)
	local drawer_meta = core.get_meta(pos)
	local owner = drawer_meta:get_string("owner")
	local player_name = player:get_player_name()
	if owner ~= "" and owner ~= player_name and not core.check_player_privs(player_name, "protection_bypass") then
		return 0
	end
	if not minetest.check_player_privs(player_name, "ch_registered_player") or core.is_protected(pos, player_name) then
	   core.record_protection_violation(pos, player_name)
	   return 0
	end
	if listname ~= "upgrades" then
		return 0
	end
	if core.get_item_group(stack:get_name(), "drawer") < 1 then
		return 0
	end
	if stack:get_count() > 100 then
		return 100
	else
		return stack:get_count()
	end
end

function drawers.add_drawer_upgrade(pos, listname, index, stack, player)
	-- only do anything if adding to upgrades
	if listname ~= "upgrades" then return end

	drawers.update_drawer_upgrades(pos)
end

function drawers.remove_drawer_upgrade(pos, listname, index, stack, player)
	-- only do anything if adding to upgrades
	if listname ~= "upgrades" then return end

	drawers.update_drawer_upgrades(pos)
end

--[[
	Inserts an incoming stack into a specific slot of a drawer.
]]
function drawers.drawer_insert_object(pos, stack, visualid)
	local visual = drawers.get_visual(pos, visualid)
	if not visual then
		return stack
	end

	return visual:try_insert_stack(stack, true)
end

--[[
	Inserts an incoming stack into a drawer and uses all slots.
]]
function drawers.drawer_insert_object_from_tube(pos, node, stack, direction)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then
        return stack
    end

	-- first try to insert in the correct slot (if there are already items)
	local leftover = stack
	for _, visual in pairs(drawer_visuals) do
		if visual.itemName == stack:get_name() then
			leftover = visual:try_insert_stack(leftover, true)
		end
	end

	-- if there's still something left, also use other slots
	if leftover:get_count() > 0 then
		for _, visual in pairs(drawer_visuals) do
			leftover = visual:try_insert_stack(leftover, true)
		end
	end
	return leftover
end

--[[
	Returns how much (count) of a stack can be inserted to a drawer slot.
]]
function drawers.drawer_can_insert_stack(pos, stack, visualid)
	local visual = drawers.get_visual(pos, visualid)
	if not visual then
		return 0
	end

	return visual:can_insert_stack(stack)
end

--[[
	Returns whether a stack can be (partially) inserted to any slot of a drawer.
]]
function drawers.drawer_can_insert_stack_from_tube(pos, node, stack, direction)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]
	if not drawer_visuals then
		return false
	end

	for _, visual in pairs(drawer_visuals) do
	   if visual:can_insert_stack(stack) > 0 then
	      return true
	   end
	end
	return false
end

function drawers.drawer_take_item(pos, itemstack)
	local drawer_visuals = drawers.drawer_visuals[core.hash_node_position(pos)]

	if not drawer_visuals then
		return ItemStack("")
	end

	-- check for max count
	if itemstack:get_count() > itemstack:get_stack_max() then
		itemstack:set_count(itemstack:get_stack_max())
	end

	for _, visual in pairs(drawer_visuals) do
		if visual.itemName == itemstack:get_name() then
			return visual:take_items(itemstack:get_count())
		end
	end

	return ItemStack()
end

--[[
	Returns the content of a drawer slot.
]]
function drawers.drawer_get_content(pos, visualid)
	local drawer_meta = core.get_meta(pos)

	return {
		name = drawer_meta:get_string("name" .. visualid),
		count = drawer_meta:get_int("count" .. visualid),
		maxCount = drawer_meta:get_int("max_count" .. visualid),
		owner = drawer_meta:get_string("owner"),
	}
end

if core.get_modpath("pipeworks") and pipeworks ~= nil then
	function drawers.drawer_after_place_node(pos, placer, itemstack, pointed_thing)
		local drawer_meta = core.get_meta(pos)
		if drawer_meta:get_string("owner") == "" and placer ~= nil then
			drawer_meta:set_string("owner", placer:get_player_name())
		end
		return pipeworks.after_place(pos, placer, itemstack, pointed_thing)
	end
else
	function drawers.drawer_after_place_node(pos, placer, itemstack, pointed_thing)
		local drawer_meta = core.get_meta(pos)
		if drawer_meta:get_string("owner") == "" and placer ~= nil then
			drawer_meta:set_string("owner", placer:get_player_name())
		end
	end
end



function drawers.register_drawer(name, def)
	def.description = def.description or S("Wooden")
	def.drawtype = "nodebox"
	def.node_box = {type = "fixed", fixed = drawers.node_box_simple}
	def.collision_box = {type = "regular"}
	def.selection_box = {type = "fixed", fixed = drawers.node_box_simple}
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.groups = def.groups or {}
	def.drawer_stack_max_factor = def.drawer_stack_max_factor or 24

	-- events
	def.on_construct = drawers.drawer_on_construct
	def.on_destruct = drawers.drawer_on_destruct
	def.on_dig = drawers.drawer_on_dig
	def.after_place_node = drawers.drawer_after_place_node
	def.allow_metadata_inventory_put = drawers.drawer_allow_metadata_inventory_put
	def.allow_metadata_inventory_take = drawers.drawer_allow_metadata_inventory_put
	def.on_metadata_inventory_put = drawers.add_drawer_upgrade
	def.on_metadata_inventory_take = drawers.remove_drawer_upgrade

	if minetest.get_modpath("screwdriver") and screwdriver then
		def.on_rotate = def.on_rotate or screwdriver.disallow
	end

	if minetest.get_modpath("pipeworks") and pipeworks then
		def.groups.tubedevice = 1
		def.groups.tubedevice_receiver = 1
		def.tube = def.tube or {}
		def.tube.insert_object = def.tube.insert_object or
		   drawers.drawer_insert_object_from_tube
		def.tube.can_insert = def.tube.can_insert or
		   drawers.drawer_can_insert_stack_from_tube

		def.tube.connect_sides = {left = 1, right = 1, back = 1, top = 1,
			bottom = 1}
		-- def.after_place_node = pipeworks.after_place
		def.after_dig_node = pipeworks.after_dig
	end

	def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if core.is_player(clicker) then
			drawers.show_formspec(clicker, pos, node, core.get_meta(pos))
		end
	end

	local has_mesecons_mvps = minetest.get_modpath("mesecons_mvps")

	if drawers.enable_1x1 then
		-- normal drawer 1x1 = 1
		local def1 = table.copy(def)
		def1.description = S("@1 Drawer", def.description)
		def1.tiles = def.tiles or def.tiles1
		def1.tiles1 = nil
		def1.tiles2 = nil
		def1.tiles4 = nil
		def1.groups.drawer = 1
		core.register_node(name .. "1", def1)
		core.register_alias(name, name .. "1") -- 1x1 drawer is the default one
		if has_mesecons_mvps then
			-- don't let drawers be moved by pistons, visual glitches and
			-- possible duplication bugs occur otherwise
			mesecon.register_mvps_stopper(name .. "1")
		end
		if has_wrench then
			wrench.register_node(name .. "1", wrench_defs[1])
		end
	end

	if drawers.enable_1x2 then
		-- 1x2 = 2
		local def2 = table.copy(def)
		def2.description = S("@1 Drawers (1x2)", def.description)
		def2.tiles = def.tiles2
		def2.tiles1 = nil
		def2.tiles2 = nil
		def2.tiles4 = nil
		def2.groups.drawer = 2
		core.register_node(name .. "2", def2)
		if has_mesecons_mvps then
			mesecon.register_mvps_stopper(name .. "2")
		end
		if has_wrench then
			wrench.register_node(name .. "2", wrench_defs[2])
		end
	end

	if drawers.enable_2x2 then
		-- 2x2 = 4
		local def4 = table.copy(def)
		def4.description = S("@1 Drawers (2x2)", def.description)
		def4.tiles = def.tiles4
		def4.tiles1 = nil
		def4.tiles2 = nil
		def4.tiles4 = nil
		def4.groups.drawer = 4
		core.register_node(name .. "4", def4)
		if has_mesecons_mvps then
			mesecon.register_mvps_stopper(name .. "4")
		end
		if has_wrench then
			wrench.register_node(name .. "4", wrench_defs[4])
		end
	end

	if (not def.no_craft) and def.material then
		if drawers.enable_1x1 then
			core.register_craft({
				output = name .. "1",
				recipe = {
					{def.material, def.material, def.material},
					{    "", drawers.CHEST_ITEMSTRING,  ""   },
					{def.material, def.material, def.material}
				}
			})
		end
		if drawers.enable_1x2 then
			core.register_craft({
				output = name .. "2 2",
				recipe = {
					{def.material, drawers.CHEST_ITEMSTRING, def.material},
					{def.material,       def.material,       def.material},
					{def.material, drawers.CHEST_ITEMSTRING, def.material}
				}
			})
		end
		if drawers.enable_2x2 then
			core.register_craft({
				output = name .. "4 4",
				recipe = {
					{drawers.CHEST_ITEMSTRING, def.material, drawers.CHEST_ITEMSTRING},
					{      def.material,       def.material,       def.material      },
					{drawers.CHEST_ITEMSTRING, def.material, drawers.CHEST_ITEMSTRING}
				}
			})
		end
	end
end

function drawers.register_drawer_upgrade(name, def)
	--[[
	def.groups = def.groups or {}
	def.groups.drawer_upgrade = def.groups.drawer_upgrade or 100
	def.inventory_image = def.inventory_image or "drawers_upgrade_template.png"
	def.stack_max = 1

	local recipe_item = def.recipe_item or "air"
	def.recipe_item = nil

	core.register_craftitem(name, def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{recipe_item, "group:stick", recipe_item},
				{"group:stick", "drawers:upgrade_template", "group:stick"},
				{recipe_item, "group:stick", recipe_item}
			}
		})
	end
	]]
end

core.register_lbm({
	label = "Upgrade drawers 2",
	name = "drawers:upgrade_drawers_ch_2",
	nodenames = {"group:drawer"},
	action = function(pos, node, dtime_s)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		local original_meta
		if inv:get_size("upgrades") == 5 then
			original_meta = meta:to_table()
			inv:set_size("upgrades", 5)
			inv:set_stack("upgrades", 1, "drawers:colorable1_0 3")
		end
		if meta:get_string("formspec") ~= "" then
			if original_meta == nil then
				original_meta = meta:to_table()
			end
			meta:set_string("formspec", "")
		end
		if original_meta ~= nil then
			drawers.update_drawer_upgrades(pos)
			core.log("action", "LBM upgraded a drawer "..node.name.." at "..core.pos_to_string(pos).." with the original metadata:\n"..dump2(original_meta.fields))
		end
	end,
})
