ch_base.open_mod(core.get_current_modname())

local modpath = assert(core.get_modpath(core.get_current_modname()))
local smooth3x3, err_msg

smooth3x3, err_msg = loadfile(modpath.."/smooth3x3.lua")
if smooth3x3 == nil then
	error(err_msg)
end
smooth3x3 = smooth3x3()

-- smooth3x3(x, z, input, options) => output

-- local dofile = assert(ch_core.compile_dofile({ch_smooth}))

-- Imports from [ch_core]:
local ifthenelse = assert(ch_core.ifthenelse)

-- Imports from [moreblocks]:
local function analyze_shape(item) -- => craftitem, category, alternate
	return stairsplus:analyze_shape(item)
end
local function is_recipeitem(item)
	return stairsplus:is_recipeitem(item)
end
local function get_mb_shape(recipeitem, category, alternate)
	return stairsplus:get_shape(recipeitem, category, alternate)
end

-- definuje, které tvarovatelné materiály bude dovoleno tvarovat v rámci rovnání terénu
local terrain_materials = {
	["default:desert_sand"] = true,
	["default:dirt"] = true,
	["default:dirt_with_coniferous_litter"] = true,
	["default:dirt_with_grass"] = true,
	["default:dirt_with_rainforest_litter"] = true,
	-- {item = "default:dirt_with_snow"},
	-- {item = "default:dry_dirt_with_dry_grass"},
	["default:gravel"] = true,
	["default:sand"] = true,
	["default:silver_sand"] = true,
	["default:snowblock"] = true,
}

-- seznam dovolených tvarů
local shape_ids = {
    [""] = { full_node = true },
    ["slab/"] = { category = "slab", alternate = "" },
    ["slope/"] = { category = "slope", alternate = "" },
    ["slope/_half"] = { category = "slope", alternate = "_half" },
    ["slope/_half_raised"] = { category = "slope", alternate = "_half_raised" },
    ["slope/_inner"] = { category = "slope", alternate = "_inner" },
    ["slope/_outer"] = { category = "slope", alternate = "_outer" },
    ["slope/_cut"] = { category = "slope", alternate = "_cut" },
    ["slope/_inner_cut"] = { category = "slope", alternate = "_inner_cut", upper_alternate = "_outer_cut" },
    ["slope/_inner_half"] = { category = "slope", alternate = "_inner_half" },
    ["slope/_inner_half_raised"] = { category = "slope", alternate = "_inner_half_raised" },
    ["slope/_inner_cut_half_raised"] = {
		category = "slope", alternate = "_inner_cut_half_raised", upper_alternate = "_outer_cut_half"
	},
    ["slope/_outer_half"] = { category = "slope", alternate = "_outer_half" },
}
local upper_shape_to_lower_shape = {
	["slope/_outer_cut"] = "slope/_inner_cut",
	["slope/_outer_cut_half"] = "slope/_inner_cut_half_raised",
}
--[[
local lower_shape_to_upper_shape = {}
for k, v in pairs(upper_shape_to_lower_shape) do
	lower_shape_to_upper_shape[v] = k
end
]]

local get_node_category_cache = {
	[""] = "other",
	["air"] = "air",
	["ignore"] = "other",
}

-- get_node_category(name) => air|water|terrain|other
--[[
	name -- Itemstring bloku.
	
	air = prázdný blok nebo attached (např. květina, pochodeň)
	water = kapalina libovolného druhu
	terrain = tvarovatelný materiál
	other = jiný blok (nebo neznámý)
]]
-----------------------------------------------------------------------------
local function get_node_category_inner(name)
	local ndef = core.registered_nodes[name]
	if ndef == nil then
		return "other" -- unknown node
	elseif ndef.liquidtype ~= nil and ndef.liquidtype ~= "none" then
		return "water"
	elseif ndef.drawtype == "airlike" or (ndef.groups == nil or (ndef.groups.attached_node or 0) > 0) then
		return "air"
	else
		local recipeitem
		if is_recipeitem(name) then
			recipeitem = name
		else
			recipeitem = analyze_shape(name)
		end
		if recipeitem == nil then
			return "other" -- netvarovatelný materiál
		else
			return "terrain" -- tvarovatelný materiál
		end
	end
end
local function get_node_category(name)
	local result = get_node_category_cache[name or ""]
	if result == nil then
		result = get_node_category_inner(name)
		get_node_category_cache[name] = result
	end
	return result
end

--
-- Pokusí se rozpoznat tvar a rotaci bloku na pozici pos; je-li to potřeba, načte ještě
-- blok o 1 níže.
local recognize_shape_cache = {}
local recognize_shape_cache_empty_item = {}
local function recognize_shape_inner(pos) -- => shape_id, rotation, y, material
	local node = core.get_node(pos)
	local cache_key = node.name.."/"..node.param2
	local cache_value = recognize_shape_cache[cache_key]
	if cache_value ~= nil then
		return cache_value.shape, cache_value.rotation, pos.y, cache_value.material
	end
	if node.param2 == nil or node.param2 > 3 then
		recognize_shape_cache[cache_key] = recognize_shape_cache_empty_item
		return nil, nil, pos.y, nil -- no shape for param2 > 3
	end
	if is_recipeitem(node.name) then
		-- plný blok (tvarovatelný materiál)
		recognize_shape_cache[cache_key] = {shape = "", rotation = 0, material = node.name}
		return "", 0, pos.y, node.name
	end
	local recipeitem, category, alternate = analyze_shape(node.name)
	if recipeitem == nil then
		-- netvarovatelný materiál
		recognize_shape_cache[cache_key] = recognize_shape_cache_empty_item
		return nil, nil, pos.y, nil
	end
	local is_bank_slope = category == "bank_slope"
	local upper_shape = upper_shape_to_lower_shape[category.."/"..alternate]
	if upper_shape ~= nil then
		-- dvojitý blok; rozpoznat pouze, pokud má společný param2; nepoužívat keš!
		local node_under = core.get_node(vector.offset(pos, 0, -1, 0))
		if node_under.param2 ~= node.param2 then
			return nil, nil, pos.y, nil -- spodní tvar má odlišný param2; nerozpoznat
		end
		local ri_under, c_under, a_under = analyze_shape(node_under.name)
		if ri_under == nil or c_under.."/"..a_under ~= upper_shape then
			return nil, nil, pos.y, nil
		end
		-- hlavní tvar je ten spodní
		assert(shape_ids[c_under.."/"..a_under])
		return c_under.."/"..a_under, node.param2, pos.y - 1, assert(ri_under)
	end
	if is_bank_slope then
		category = "slope"
	end
	if shape_ids[category.."/"..alternate] == nil then
		recognize_shape_cache[cache_key] = recognize_shape_cache_empty_item
		return nil, nil, nil, nil -- nepodporovaný tvar
	end
	if is_bank_slope then
		-- nepoužít keš pro pobřežní bloky (kvůli rozdílu v pos.y)
		return "slope/"..alternate, node.param2, pos.y + 1, assert(recipeitem) -- pro bank_slopy je základní y o 1 výš
	else
		recognize_shape_cache[cache_key] = {
			shape = category.."/"..alternate,
			rotation = node.param2,
			material = recipeitem,
		}
		return category.."/"..alternate, node.param2, pos.y, recipeitem
	end
end
local function recognize_shape(pos)
	local orig_node = core.get_node(pos)
	local shape_id, rotation, y, material = recognize_shape_inner(pos)
	if shape_id == nil then
		print("DEBUG: node at ("..pos.x..",*,"..pos.z..") ("..orig_node.name.."/"..orig_node.param2..") NOT recognized.")
	else
		print("DEBUG: node at "..pos.x..","..y..","..pos.z..") ("..orig_node.name.."/"..orig_node.param2..") recognized as shape \""..shape_id.."\"/"..rotation.." of material "..(material or "nil")..".")
	end
	return shape_id, rotation, y, material
end
recognize_shape = recognize_shape_inner -- will disable debugging


--
--
--[[
]]
-----------------------------------------------------------------------------
local function get_xz_node(pos)
	local under_water = false
	pos = vector.copy(pos)
	for y = pos.y + 2, pos.y - 2, -1 do
		pos.y = y
		local node = core.get_node(pos)
		local category = get_node_category(node.name)
		if category == "air" then
			under_water = false
		elseif category == "water" then
			under_water = true
		elseif category == "other" then
			-- narazili jsme na netvarovatelný blok; raději vrátíme nil
			return nil
		elseif category == "terrain" then
			local shape_id, rotation, base_y, material = recognize_shape(pos)
			if shape_id == nil then
				-- neznámý tvar, nemůžeme s ním pracovat
				return nil
			end
			return {
				material = assert(material),
				shape = assert(shape_id),
				rotation = assert(rotation),
				y = base_y,
				fixed = not terrain_materials[material],
				under = ifthenelse(under_water, "water", "air"),
			}
		else
			error("Unexpected invalid node category '"..category.."'!")
		end
	end
	return nil -- nothing found
end

--
-- ch_smooth.vyhladit_{zpet,potvrdit}() + příkaz /vyhladit <potvrdit|.|zpět>
-----------------------------------------------------------------------------
local rollback_log = {}
local rollback_log_count = 0

local function vyhladit_potvrdit()
	local count = 0
	local key = next(rollback_log)
	while key ~= nil do
		count = count + 1
		key = next(rollback_log, key)
	end
	rollback_log = {}
	rollback_log_count = 0
	return "Potvrzeno "..count.." změn."
end

local function vyhladit_zpet()
	local count = 0
	local get_position_from_hash = core.get_position_from_hash
	local set_node = core.set_node
	for hash, node in pairs(table.copy(rollback_log)) do
		local pos = get_position_from_hash(hash)
		set_node(pos, node)
		rollback_log[hash] = nil
		rollback_log_count = rollback_log_count - 1
		count = count + 1
	end
	return "Vráceno "..count.." změn."
end

local function set_node_rollbackable(pos, node)
	local hash = core.hash_node_position(pos)
	local old_node = core.get_node_or_nil(pos)
	if rollback_log[hash] == nil then
		rollback_log[hash] = core.get_node_or_nil(pos)
		if rollback_log[hash] ~= nil then
			rollback_log_count = rollback_log_count + 1
		end
	end
	if old_node ~= nil then
		core.log("action", "[ch_smooth] Will set node at "..core.pos_to_string(pos).." from "..old_node.name.."/"..old_node.param2.." to "..
			(node.name or "nil").."/"..(node.param2 or "nil")..".")
	end
	local result = core.set_node(pos, node)
	core.check_for_falling(pos)
	return result
end

local function apply_change(orig_node, change)
	local pos = vector.new(change.x, change.y, change.z)
	-- shape, rotation
	local material = assert(orig_node.material)
	assert(change.shape)
	local shape_desc = assert(shape_ids[change.shape])
	if change.y == orig_node.y - 1 then
		-- nový tvar je pod původním; nutno původní nejdřív smazat
		set_node_rollbackable(vector.new(change.x, orig_node.y, change.z), {name = "air", param2 = 0})
	end
	if shape_desc.full_node then
		set_node_rollbackable(pos, {name = material, param2 = 0})
		return true
	elseif shape_desc.upper_alternate ~= nil then
		-- dvoublokový tvar
		local upper_node_name = get_mb_shape(material, shape_desc.category, shape_desc.upper_alternate)
		local node_name = get_mb_shape(material, shape_desc.category, shape_desc.alternate)
		if upper_node_name == nil or node_name == nil then
			core.log("error", dump2({material = material, change = change, }))
			error("Two-node shape not found!")
		end
		set_node_rollbackable(pos, {name = node_name, param2 = change.rotation})
		pos.y = pos.y + 1
		set_node_rollbackable(pos, {name = upper_node_name, param2 = change.rotation})
		return true
	else
		assert(shape_desc.alternate)
		local node_name = get_mb_shape(material, shape_desc.category, shape_desc.alternate)
		if node_name == nil then
			core.log("error", dump2({material = material, change = change, }))
			error("One-node shape not found!")
		end
		if orig_node ~= nil and orig_node.under == "water" and shape_desc.category == "slope" then
			-- pod vodou se pokusit použít pobřežní svah
			local suggestion = node_name:gsub(":", ":bank_", 1)
			if core.registered_nodes[suggestion] ~= nil then
				node_name = suggestion
				set_node_rollbackable(pos, {name = "air", param2 = 0}) -- remove the old node
				pos.y = pos.y - 1
			end
		end
		set_node_rollbackable(pos, {name = node_name, param2 = change.rotation})
		return true
	end
end

local function lze_vyhladit(pos) -- => new_pos
	local node_above = core.get_node(vector.offset(pos, 0, 1, 0))
	local node_above_category = get_node_category(node_above.name)
	if node_above_category ~= "air" and node_above_category ~= "water" then
		return nil
	end
	local central_node = get_xz_node(pos)
	if central_node ~= nil and not central_node.fixed then
		return vector.new(pos.x, central_node.y, pos.z)
	else
		return nil
	end
end

local function vyhladit(pos)
	local node_above = core.get_node(vector.offset(pos, 0, 1, 0))
	local node_above_category = get_node_category(node_above.name)
	if node_above_category ~= "air" and node_above_category ~= "water" then
		return nil
	end
	local central_node = get_xz_node(pos)
	if central_node == nil or central_node.fixed then
		local node = core.get_node(pos)
		return false, "Blok "..node.name.."/"..node.param2.." není vhodný pro vyhlazení."
	end
	local central_node_pos = lze_vyhladit(pos)
	if central_node_pos ~= nil then
		print("DEBUG: central_node_pos = "..core.pos_to_string(central_node_pos).." (pos = "..core.pos_to_string(pos)..")")
	else
		print("DEBUG: central_node_pos = nil (pos = "..core.pos_to_string(pos)..")")
	end
	local x, y, z = pos.x, pos.y, pos.z
	local input = {
		[x - 1] = {},
		[x] = {[z] = central_node},
		[x + 1] = {},
	}
	pos = vector.copy(pos)
	pos.x = x - 1
	input[x - 1][z] = get_xz_node(pos)
	pos.x = x + 1
	input[x + 1][z] = get_xz_node(pos)
	-- the rest
	for zz = z - 1, z + 1, 2 do
		pos.z = zz
		for xx = x - 1, x + 1, 1 do
			pos.x = xx
			input[xx][zz] = get_xz_node(pos)
		end
	end
	print("DEBUG: smoothing started...")
	local output = smooth3x3(x, z, input, {})
	print("DEBUG: smoothing finished")
	if output == nil then
		return false, "Vyhlazování selhalo."
	end
	print("DEBUG: smoothing output = "..dump2(output))
	if #output == 0 then
		return true, "Vyhlazování neprovedlo žádné změny."
	end
	for _, change in ipairs(output) do
		local x, z = change.x, change.z
		apply_change((input[x] or {})[z], change)
	end
	return true, "Vyhlazování: "..#output.." změn. Výsledná velikost zpětné databáze: "..rollback_log_count
end

local function on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if not player_name then
		return
	end
	if not core.check_player_privs(player_name, "server") then
		ch_core.systemovy_kanal(player_name, "Chyba: tuto hůlku smí používat jen Administrace.")
		return
	end
	if pointed_thing.type ~= "node" then
		ch_core.systemovy_kanal(player_name, "Nutno kliknout na blok.")
		return
	end
	local result, msg = vyhladit(pointed_thing.under)
	if msg ~= nil then
		ch_core.systemovy_kanal(player_name, msg)
	end
end

local def = {
	description = "hůlka vyhlazení [EXPERIMENTÁLNÍ]",
	inventory_image = "ch_extras_creative_inv.png",
	wield_image = "ch_extras_creative_inv.png",
	on_use = on_use,
	groups = {tools = 1},
}

core.register_tool("ch_smooth:wand", def)

def = {
	params = "potvrdit|zpět",
	privs = {server = true},
	description = "potvrdí nebo vrátí změny provedené pomocí nástroje vyhlazení",
	func = function(_name, param)
		if param == "potvrdit" or param == "." then
			return true, vyhladit_potvrdit()
		elseif param == "zpět" or param == "zpet" or param == "\\" then
			return true, vyhladit_zpet()
		else
			return false, "Chybný parametr. Použijte zpět nebo potvrdit."
		end
	end
}
core.register_chatcommand("vyhladit", def)

ch_smooth = {
	vyhladit = vyhladit,
}

ch_base.close_mod(core.get_current_modname())
