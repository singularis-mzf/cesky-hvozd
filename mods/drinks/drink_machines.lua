--Craft Recipes

minetest.register_craft({
      output = 'drinks:juice_press',
      recipe = {
         {'default:stick', 'default:steel_ingot', 'default:stick'},
         {'default:stick', 'bucket:bucket_empty', 'default:stick'},
         {'stairs:slab_wood', 'stairs:slab_wood', 'vessels:drinking_glass'},
         }
})

minetest.register_craft({
      output = 'drinks:liquid_barrel',
      recipe = {
         {'group:wood', 'group:wood', 'group:wood'},
         {'group:wood', 'group:wood', 'group:wood'},
         {'stairs:slab_wood', '', 'stairs:slab_wood'},
         }
})

minetest.register_craft({
      output = 'drinks:liquid_silo',
      recipe = {
         {'drinks:liquid_barrel'},
         {'drinks:liquid_barrel'},
         {'drinks:liquid_barrel'}
      }
})

local function drink_to_desc2(drink_id)
	local def = drinks.registered_drinks[drink_id]
	if def then
		return def.drink_desc2 or def.drink_desc or drink_id
	else
		return drink_id
	end
end

local barrel_capacity = 500 -- 50 l
local silo_capacity = 1000 -- 100 l

local update_barrel_formspec

-- BARREL/SILO PUBLIC FUNCTIONS

--[[ If there is a barrel or silo at pos, returns a table, for example:
	{
		capacity = 128,
		drink_id = "pineapple",
		units_stored = 18,
		node_name = "drinks:liquid_barrel",
	}
	If there is no barrel nor silo at pos, returns nil.
]]
function drinks.get_barrel_state(pos)
	local node_name = minetest.get_node(pos).name
	local capacity
	if node_name == "drinks:liquid_barrel" then
		capacity = barrel_capacity
	elseif node_name == "drinks:liquid_silo" then
		capacity = silo_capacity
	else
		print("get_barrel_state: invalid node ("..node_name..")!")
		return nil
	end
	local meta = minetest.get_meta(pos)
	local result = {
		capacity = capacity,
		drink_id = meta:get_string("drink"),
		units_stored = meta:get_int("fullness"),
		node_name = node_name,
	}
	if result.units_stored == 0 or result.drink_id == "empty" then
		result.units_stored = 0
		result.drink_id = nil
	end
	result.units_available = result.capacity - result.units_stored
	return result
end

--[[ If there is a barrel or silo at pos, tries to add or remove units of
a drink. Always returns a table that contains at least "success",
which is true for success and false for other conditions.
	When success is true, the result contains also new_fullness
(units_stored after the change) and capacity (container capacity).
]]
function drinks.try_change_barrel_state(pos, units, drink_id)
	-- print("DEBUG: try_change_barrel_state("..dump2({pos = pos, units = units, drink_id = drink_id})..")")
	local state = drinks.get_barrel_state(pos)
	if not state then
		return { success = false, not_a_barrel = true }
	end
	if units == 0 then
		return { success = true, new_fullness = state.units_stored, capacity = state.capacity } -- no change
	end
	if drink_id and state.drink_id and drink_id ~= state.drink_id then
		return { success = false, different_drinks = true }
	end
	if not drink_id then
		if not state.drink_id then
			return { success = false, unidentified_drink = true }
		end
		drink_id = state.drink_id
	end
	if state.units_stored + units < 0 then
		return { success = false, negative_result = true }
	end
	if state.units_stored + units > state.capacity then
		return { success = false, overflow = state.units_stored + units - capacity }
	end
	local new_fullness = state.units_stored + units
	-- print("DEBUG: fullness: "..state.units_stored.." > "..new_fullness.." (change: "..units..")")
	local word_ending

	if state.node_name == "drinks:liquid_barrel" then
		word_ending = "ý"
	else
		word_ending = "é"
	end

	local meta = minetest.get_meta(pos)
	meta:set_int("fullness", new_fullness)
	if new_fullness > 0 then
		meta:set_string("drink", drink_id)
	else
		meta:set_string("drink", "empty")
	end
	update_barrel_formspec(pos)
	return { success = true, new_fullness = new_fullness, capacity = state.capacity }
end

-- PRIVATE BARREL/SILO FUNCTIONS

local function get_barrel_state_under(pos)
	pos = vector.new(pos.x, pos.y - 1, pos.z)
	local node = minetest.get_node_or_nil(pos)
	if node and node.name == "drinks:liquid_barrel" then
		local result = drinks.get_barrel_state(pos)
		result.position = pos
		return result
	end
	pos.y = pos. y - 1
	node = minetest.get_node_or_nil(pos)
	if node and node.name == "drinks:liquid_silo" then
		local result = drinks.get_barrel_state(pos)
		result.position = pos
		return result
	end
	return nil
end

update_barrel_formspec = function(pos)
	local state = drinks.get_barrel_state(pos)
	if not state then
		return false
	end
	local infotext
	local formspec_parts = {
		-- [1]
		"size[8,8]"..
		"label[0,0;Můžete plnit jedním libovolným typem šťávy či nápoje,]"..
		"label[0,.4;míchání různých nápojů není dovoleno.]"..
		"label[4.5,1.2;Nápoj k uložení ->]"..
		"label[.5,1.2;",
		-- [2]
		"", -- "Ukládám "..drink_desc..".",
		-- [3]
		"]"..
		"label[.5,1.65;",
		-- [4]
		"", -- "Naplnění: "..(fullness).." z "..(max).." dávek.",
		-- [5]
		"]"..
		"label[4.5,2.25;Nádoba k naplnění ->]"..
		"label[2,3.2;(Vylije pryč veškerý obsah)]"..
		"button[0,3;2,1;purge;Vylít vše]"..
		"list[current_name;src;6.5,1;1,1;]"..
		"list[current_name;dst;6.5,2;1,1;]"..
		"list[current_player;main;0,4;8,5;]"
	}
	if state.units_stored == 0 then
		if state.node_name == "drinks:liquid_barrel" then
			infotext = "prázdný sud"
		else
			infotext = "prázdné silo"
		end
		formspec_parts[2] = infotext
	else
		local drink_def = drinks.registered_drinks[state.drink_id]
		local desc2 = (drink_def and (drink_def.drink_desc2 or drink_def.drink_desc)) or "neznámého nápoje"
		local desc4 = (drink_def and (drink_def.drink_desc4 or drink_def.drink_desc)) or "neznámý nápoj"
		local percent = math.floor(100 * state.units_stored / state.capacity)
		if state.node_name == "drinks:liquid_barrel" then
			infotext = string.format("sud z %d %% plný %s", percent, desc2)
		else
			infotext = string.format("silo z %d %% plné %s", percent, desc2)
		end
		formspec_parts[2] = "ukládám "..desc4
	end
	formspec_parts[4] = "obsazeno: "..state.units_stored.." z "..state.capacity.." decilitrů"
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", table.concat(formspec_parts))
	meta:set_string("infotext", infotext)
end

local function barrel_allow_metadata_inventory_put(pos, listname, index, stack, player)
	local barrel_state = drinks.get_barrel_state(pos)
	if not barrel_state then
		minetest.log("info", "not barrel_state at "..minetest.pos_to_string(pos))
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty(listname) then
		minetest.log("info", "list "..listname.." is not empty!")
		return 0
	end
	if listname == "src" then
		local spill_from_result = drinks.spill_from(stack:get_name()) -- { drink_id, units_produced, empty_vessel_item }
		if not spill_from_result then
			minetest.log("info", "no spill result for "..stack:get_name().."!")
			return 0
		end
		if barrel_state.units_stored > 0 and barrel_state.drink_id ~= spill_from_result.drink_id then
			minetest.log("info", "wrong drink_id "..spill_from_result.drink_id.." for barrel with "..barrel_state.units_stored.." units of "..barrel_state.drink_id.."!")
			return 0 -- wrong drink_id
		end
		local result = math.min(stack:get_count(), math.floor((barrel_state.capacity - barrel_state.units_stored) / spill_from_result.units_produced))
		-- print("will return: "..result)
		return result
	elseif listname == "dst" then
		if barrel_state.units_stored == 0 then
			minetest.log("info", "barrel is empty!")
			return 0
		end
		local fill_to_result = drinks.fill_to(barrel_state.drink_id, stack:get_name())
		if not fill_to_result then
			minetest.log("info", "not fill_to_result!")
			return 0
		end
		local result = math.min(stack:get_count(), math.floor(barrel_state.units_stored / fill_to_result.units_required))
		-- print("will return: "..result)
		return result
	else
		return 0
	end
end

local function barrel_on_metadata_inventory_put(pos, listname, index, stack, player)
	local barrel_state = drinks.get_barrel_state(pos)
	if not barrel_state then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "src" then
		local spill_from_result = drinks.spill_from(stack:get_name()) -- { drink_id, units_produced, empty_vessel_item }
		if spill_from_result and drinks.try_change_barrel_state(pos, stack:get_count() * spill_from_result.units_produced, spill_from_result.drink_id).success then
			inv:set_stack("src", 1, ItemStack(spill_from_result.empty_vessel_item.." "..stack:get_count()))
		end
	elseif listname == "dst" then
		local fill_to_result = drinks.fill_to(barrel_state.drink_id, stack:get_name())
		if barrel_state.units_stored > 0 and fill_to_result and drinks.try_change_barrel_state(pos, -stack:get_count() * fill_to_result.units_required, barrel_state.drink_id).success then
			inv:set_stack("dst", 1, ItemStack(fill_to_result.full_vessel_item.." "..stack:get_count()))
		end
	end
end

local function barrel_on_receive_fields(pos, formname, fields, sender)
	if fields.purge then
		local meta = minetest.get_meta(pos)
		meta:set_int("fullness", 0)
		meta:set_string("drink", "empty")
		update_barrel_formspec(pos)
	end
end

-- PRIVATE JUICE PRESS FUNCTIONS
local function set_juice_press_state(pos, state, description, plan)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	local formspec_parts = {
		-- [1]
		"size[8,7]"..
		"label[1.5,0;",
		-- [2]
		"", -- "Lisování probíhá",
		-- [3]
		"]"..
		"label[4.3,.75;sem vložte ovoce ->]"..
		"label[4.1,1.75;sem vložte nádobu ->]"..
		"label[0.2,1.8;",
		-- [4]
		"", -- "zvolená kombinace:",
		-- [5]
		"]"..
		"label[0.2,2.1;",
		-- [6]
		"", -- "není možná",
		-- [7]
		"]"..
		-- "label[0.2,2.4;16 ks/kbelík.]"..
		"button[1,1;2,1;press;spustit lisování]"..
		"list[current_name;src;6.5,.5;1,1;]"..
		"list[current_name;dst;6.5,1.5;1,1;]"..
		"list[current_player;main;0,3;8,4;]"..
		"listring[current_name;dst]"..
		"listring[current_player;main]"..
		"listring[current_name;src]"
	}
	if state == "idle" then
		if not description then
			description = "prázdný lis na ovoce"
		end
		timer:stop()
	elseif state == "running" then
		if not description then
			description = "lis pracuje..."
		end
		if plan then
			meta:set_string("container", plan.vessel)
			meta:set_string("fruitnumber", plan.fruits_to_take)
			timer:start(plan.fruits_to_take)
		end
	elseif state == "error" then
		if not description then
			description = "lis má nedostatek ovoce"
		end
		timer:stop()
	else
		minetest.log("error", "Invalid juice_press state "..state.."!")
		return false
	end

	local inv = meta:get_inventory()
	local src = inv:get_stack("src", 1)
	local dst = inv:get_stack("dst", 1)
	if src:is_empty() or dst:is_empty() then
		formspec_parts[4] = ""
		formspec_parts[6] = ""
	else
		local juice_info = drinks.get_juice(src:get_name())
		local fill_to_result = juice_info and drinks.fill_to(juice_info.drink_id, dst:get_name())
		if fill_to_result then
			formspec_parts[4] = "zvolená kombinace vyžaduje:"
			formspec_parts[6] = math.ceil(fill_to_result.units_required / juice_info.units_produced).." ks/nádobu"
		elseif juice_info and dst:get_name() == "default:papyrus" then
			formspec_parts[4] = "spustí"
			formspec_parts[6] = "automatické lisování"
		else
			formspec_parts[4] = "zvolená kombinace:"
			formspec_parts[6] = "není možná"
		end
	end
	formspec_parts[2] = description
	meta:set_string("infotext", description)
	meta:set_string("formspec", table.concat(formspec_parts))
	return true
end

local function juice_press_on_receive_fields(pos, formname, fields, sender)
	if not fields.press then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local instack = inv:get_stack("src", 1)
	local outstack = inv:get_stack("dst", 1)

	-- check, if we can get any drink from "instack":
	local juice_info = drinks.get_juice(instack:get_name())
	if not juice_info then
		set_juice_press_state(pos, "error", "neumím lisovat tento vstup")
		return
	end
	-- check, if we can fill the drink to the vessel:
	local vessel = outstack:get_name()
	if vessel ~= "default:papyrus" then
		local expected_result = drinks.fill_to(juice_info.drink_id, vessel)
		if not expected_result then
			set_juice_press_state(pos, "error", "vylisovanou šťávu nelze plnit do zvolené nádoby")
		elseif instack:get_count() * juice_info.units_produced >= expected_result.units_required then
			meta:set_string("drink", juice_info.drink_id)
			set_juice_press_state(pos, "running", nil, { fruits_to_take = math.ceil(expected_result.units_required / juice_info.units_produced), vessel = vessel})
		else
			set_juice_press_state(pos, "error", "lis má nedostatek ovoce")
		end
	else
		local barrel_state = get_barrel_state_under(pos)
		if not barrel_state then
			set_juice_press_state(pos, "error", "silo či sud nenalezen")
		elseif barrel_state.drink_id ~= nil and barrel_state.drink_id ~= juice_info.drink_id then
			set_juice_press_state(pos, "error", "míchání nápojů není dovoleno!")
		elseif barrel_state.units_stored + juice_info.units_produced > barrel_state.capacity then
			set_juice_press_state(pos, "error", "silo či sud je plný")
		else
			set_juice_press_state(pos, "running", nil, { fruits_to_take = 1, vessel = "tube" })
		end
	end
end

local function juice_press_on_timer(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local timer = minetest.get_node_timer(pos)
	local container = meta:get_string("container")
	local instack = inv:get_stack("src", 1)
	local outstack = inv:get_stack("dst", 1)
	local drink_id = meta:get_string("drink")
	local fruitnumber = tonumber(meta:get_string("fruitnumber"))
	local fruit_info = drinks.get_juice(instack:get_name())
	if not fruit_info then
		set_juice_press_error(pos)
		return
	end
	local processed_stack = instack:take_item(fruitnumber)
	local units_produced = processed_stack:get_count() * fruit_info.units_produced

	if container == "tube" then
		local barrel_state = get_barrel_state_under(pos)
		if barrel_state.units_available >= units_produced then
			local add_result = drinks.try_change_barrel_state(barrel_state.position, units_produced, fruit_info.drink_id)
			if not add_result.success then
				set_juice_press_state(pos, "error", "Silo či sud je plný "..drink_to_desc2(fruit_info.drink_id)..".")
				return
			end
			inv:set_stack("src", 1, instack)
			if add_result.new_fullness >= add_result.capacity then
				set_juice_press_state(pos, "error", "Silo či sud je plný "..drink_to_desc2(fruit_info.drink_id)..".")
				return
			end
			if instack:get_count() >= 1 then
				timer:start(1)
			else
				set_juice_press_state(pos, "error")
			end
		else
			set_juice_press_state(pos, "error")
		end
	else
		set_juice_press_state(pos, "idle"," Vyjměte hotovou šťávu.")
		inv:set_stack("src", 1, instack)
		local fill_to_result = drinks.fill_to(fruit_info.drink_id, container)
		if fill_to_result then
			inv:set_stack("dst", 1, fill_to_result.full_vessel_item)
		end
	end
end

minetest.register_node('drinks:juice_press', {
   description = 'lis na ovocnou šťávu',
   drawtype = 'mesh',
   mesh = 'drinks_press.obj',
   tiles = {'drinks_press.png'},
   use_texture_alpha = "opaque",
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      set_juice_press_state(pos, "idle")
   end,
   on_receive_fields = juice_press_on_receive_fields,
   on_timer = juice_press_on_timer,
   on_metadata_inventory_take = function(pos, listname, index, stack, player)
      set_juice_press_state(pos, "error", "připraven na další lisování")
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      local meta = minetest.get_meta(pos)
      -- local inv = meta:get_inventory()
      set_juice_press_state(pos, "error", "připraven na lisování")
   end,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      return inv:is_empty("src") and inv:is_empty("dst")
   end,
   allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname ~= "dst" then
			return stack:get_count()
		elseif minetest.get_meta(pos):get_inventory():is_empty("dst") and (stack:get_name() == "default:papyrus" or drinks.registered_vessels[stack:get_name()]) then
			return 1
		else
			return 0
		end
   end,
})

minetest.register_node('drinks:liquid_barrel', {
   description = 'sud na nápoje',
   drawtype = 'mesh',
   mesh = 'drinks_liquid_barrel.obj',
   tiles = {'drinks_barrel.png'},
   use_texture_alpha = "opaque",
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, .5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      meta:set_int("fullness", 0)
      meta:set_string("drink", "empty")
      update_barrel_formspec(pos)
   end,
   on_metadata_inventory_put = barrel_on_metadata_inventory_put,
   on_receive_fields = barrel_on_receive_fields,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      if inv:is_empty("src") and
         inv:is_empty("dst") and
         meta:get_int("fullness") == 0 then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = barrel_allow_metadata_inventory_put,
})

minetest.register_node('drinks:liquid_silo', {
   description = 'silo na nápoje',
   drawtype = 'mesh',
   mesh = 'drinks_silo.obj',
   tiles = {'drinks_silo.png'},
   groups = {choppy=2, dig_immediate=2,},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, 1.5, .5},
      },
   collision_box = {
      type = 'fixed',
      fixed = {-.5, -.5, -.5, .5, 1.5, .5},
      },
   on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size('main', 8*4)
      inv:set_size('src', 1)
      inv:set_size('dst', 1)
      meta:set_int("fullness", 0)
      meta:set_string("drink", "empty")
      update_barrel_formspec(pos)
   end,
   on_metadata_inventory_put = barrel_on_metadata_inventory_put,
   on_receive_fields = barrel_on_receive_fields,
   can_dig = function(pos)
      local meta = minetest.get_meta(pos);
      local inv = meta:get_inventory()
      if inv:is_empty("src") and
         inv:is_empty("dst") and
         meta:get_int('fullness') == 0 then
         return true
      else
         return false
      end
   end,
   allow_metadata_inventory_put = barrel_allow_metadata_inventory_put,
})
