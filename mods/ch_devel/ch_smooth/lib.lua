local ch_smooth = ...

--
-- assert_has(t, fields...)
--[[
	Ověří, že "t" je tabulka a obsahuje hodnoty pro požadované klíče. Vrací "t".
-----------------------------------------------------------------------------
]]
local function assert_has(t, ...)
	if type(t) ~= "table" then
		error("Argument is not a table!")
	end
	for _, name in ipairs({...}) do
		if t[name] == nil then
			error("Argument does not have the required field '"..name.."'!")
		end
	end
	return t
end
ch_smooth.assert_has = assert_has

--
-- assert_is_shape(x)
--[[
	Ověří, že "t" je platná tabulka tvaru (tzn. že obsahuje požadované klíče). Vrací "t".
-----------------------------------------------------------------------------
]]
local function assert_is_shape(t)
	if type(t) ~= "table" then
		error("Argument is not a table!")
	end
	for _, name in ipairs({"vxmzm", "vxpzm", "vxpzp", "vxmzp"}) do
		if t[name] == nil then
			error("Argument is not a shape, because does not have the field '"..name.."'!: "..dump2(t))
		end
	end
	return t
end
ch_smooth.assert_is_shape = assert_is_shape

--
-- assert_is_string(x)
--[[
	Ověří, že x je řetězec; číslo či logickou hodnotu převede na řetězec.
-----------------------------------------------------------------------------
]]
local function assert_is_string(x)
	local t = type(x)
	if t == "string" then
		return t
	elseif t == "number" or t == "boolean" then
		return tostring(t)
	else
		error("Argument is "..t.."!")
	end
end
ch_smooth.assert_is_string = assert_is_string

--
-- shape_id()
--[[
	Ke tvaru "t" vrací jeho textovou reprezentaci.
-----------------------------------------------------------------------------
]]
local function shape_id(t)
	if t == nil then
		minetest.log("warning", "shape_id() called with nil argument!")
		return "nil"
	end
	assert_is_shape(t)
	-- return (t.vxmzm or "nil")..","..(t.vxpzm or "nil")..","..(t.vxpzp or "nil")..","..(t.vxmzp or "nil")
	local result = t.vxmzm..","..t.vxpzm..","..t.vxpzp..","..t.vxmzp
	-- print("shape_id() => "..result)
	return result
end
ch_smooth.shape_id = shape_id

--
-- copy_shape()
--[[
	Vrátí novou tabulku obsahující kopie prvků tvaru.
-----------------------------------------------------------------------------
]]
local function copy_shape(shape)
	return {vxmzm = assert(shape.vxmzm), vxpzm = assert(shape.vxpzm), vxpzp = assert(shape.vxpzp), vxmzp = assert(shape.vxmzp)}
end
ch_smooth.copy_shape = copy_shape

--
-- rotate_shape()
--[[
	Přijímá tvar „shape“ a hodnotu fourdir (4dir) 0..3; vrací tvar otočený podle
	zadané hodnoty.
-----------------------------------------------------------------------------
]]
local rotate_map = {
	[0] = "vxmzm",
	[1] = "vxpzm",
	[2] = "vxpzp",
	[3] = "vxmzp",
}
ch_smooth.rotate_map = rotate_map

local function rotate_shape(shape, fourdir)
	if fourdir == nil or not rotate_map[fourdir] then
		error("rotate_tvar(): invalid fourdir "..(fourdir or "nil"))
	end
	if shape == nil then
		return nil -- accepts nil
	end
	assert_is_shape(shape)
	return {
		vxmzm = shape[rotate_map[(fourdir + 0) % 4]],
		vxpzm = shape[rotate_map[(fourdir + 1) % 4]],
		vxpzp = shape[rotate_map[(fourdir + 2) % 4]],
		vxmzp = shape[rotate_map[(fourdir + 3) % 4]],
	}
end
ch_smooth.rotate_shape = rotate_shape

--
-- visualize_shape()
--[[
	label -- textový popisek pro identifikaci výstupu nebo vektor.
	shape -- tabulka tvaru.
-----------------------------------------------------------------------------
]]
local visualize_shape_line = "+--------------------------------------+"
local function visualize_shape_tostr(x)
	if x == nil then
		return " nil "
	else
		return " "..tostring(x).." "
	end
end
local function visualize_shape(label, shape)
	local a, b, c
	local s1, s2 = visualize_shape_tostr(shape.vxmzm), visualize_shape_tostr(shape.vxpzm)

	if type(label) == "table" then
		label = minetest.pos_to_string(label)
	end
	assert_is_string(label)
	a = label..":\n"..visualize_shape_line:sub(1,2)..s1..visualize_shape_line:sub(3 + #s1, -1)..s2.."\n|\n|"
	if shape.node ~= nil then
		b = " "..shape.node.name.."/"..shape.node.param2
	else
		b = "(nil)"
	end
	s1, s2 = visualize_shape_tostr(shape.vxmzp), visualize_shape_tostr(shape.vxpzp)
	c = "\n|\n"..visualize_shape_line:sub(1,2)..s1..visualize_shape_line:sub(3 + #s1, -1)..s2
	return a..b..c
end
ch_smooth.visualize_shape = visualize_shape

--
-- get_or_add(t, k)
--[[
	Vrátí t[k]. Pokud neexistuje, přiřadí tam prázdnou tabulku a vrátí tu.
-----------------------------------------------------------------------------
]]
local function get_or_add(t, k)
	local result = t[k]
	if result == nil then
		result = {}
		t[k] = result
	end
	return result
end
ch_smooth.get_or_add = get_or_add

--
-- ch_smooth.vyhladit_{zpet,potvrdit}() + příkaz /vyhladit <potvrdit|.|zpět>
-----------------------------------------------------------------------------
local rollback_log = {}

function ch_smooth.vyhladit_potvrdit()
	local count = 0
	local key = next(rollback_log)
	while key ~= nil do
		count = count + 1
		key = next(rollback_log, key)
	end
	rollback_log = {}
	return "Potvrzeno "..count.." změn."
end

function ch_smooth.vyhladit_zpet()
	local count = 0
	local get_position_from_hash = minetest.get_position_from_hash
	local set_node = minetest.set_node
	local swap_node = minetest.swap_node
	for hash, node in pairs(table.copy(rollback_log)) do
		local pos = get_position_from_hash(hash)
		set_node(pos, node)
		rollback_log[hash] = nil
		count = count + 1
	end
	return "Vráceno "..count.." změn."
end

local def = {
	params = "potvrdit|zpět",
	privs = {server = true},
	description = "potvrdí nebo vrátí změny provedené pomocí nástroje vyhlazení",
	func = function(name, param)
		if param == "potvrdit" or param == "." then
			return true, ch_smooth.vyhladit_potvrdit()
		elseif param == "zpět" or param == "zpet" or param == "\\" then
			return true, ch_smooth.vyhladit_zpet()
		else
			return false, "Chybný parametr. Použijte zpět nebo potvrdit."
		end
	end
}
minetest.register_chatcommand("vyhladit", def)

--
-- NodeManipulator
-----------------------------------------------------------------------------
local NodeManipulator = {}

function NodeManipulator:new()
	return setmetatable({data = {}}, {__index = NodeManipulator})
end

local function get_to_cache(nm_data, hash, pos)
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		return nil, nil
	end
	local info = {
		old_name = node.name,
		old_param2 = node.param2,
	}
	nm_data[hash] = info
	return info
end

function NodeManipulator:get(pos) -- => name, param2 or nil, nil
	local hash = minetest.hash_node_position(pos)
	local info = self.data[hash]
	if info == nil then
		info = get_to_cache(self.data, hash, pos)
		print("NM"..minetest.pos_to_string(pos).." got: "..info.old_name.."/"..info.old_param2)
	else
		print("NM"..minetest.pos_to_string(pos).." cached: "..info.old_name.."/"..info.old_param2)
	end
	return info.old_name, info.old_param2
end

function NodeManipulator:set(pos, name, param2)
	local hash = minetest.hash_node_position(pos)
	local info = self.data[hash]
	if info == nil then
		info = get_to_cache(self.data, hash, pos) or {}
	end
	print("NM set "..minetest.pos_to_string(pos).." from "..info.old_name.."/"..info.old_param2.." to "..name.."/"..param2)
	info.new_name = assert(name)
	info.new_param2 = assert(param2)
end

function NodeManipulator:commit()
	local counter = 0
	local get_position_from_hash = minetest.get_position_from_hash
	local set_node = minetest.set_node
	local swap_node = minetest.swap_node
	for hash, info in pairs(self.data) do
		if info.new_name ~= nil then
			local pos = get_position_from_hash(hash)
			if info.new_name ~= nil and info.new_name ~= info.old_name then
				print("DEBUG: will set "..minetest.pos_to_string(pos).." from "..(info.old_name or "nil").."/"..(info.old_param2 or "nil").." to "..(info.new_name or "nil").."/"..(info.new_param2).." (c="..(counter + 1)..")")
				if rollback_log[hash] == nil then
					rollback_log[hash] = {name = assert(info.old_name), param2 = info.old_param2}
				end
				set_node(pos, {name = info.new_name, param2 = info.new_param2})
				counter = counter + 1
			elseif info.old_param2 ~= info.new_param2 then
				print("DEBUG: will swap "..minetest.pos_to_string(pos).." from "..(info.old_name or "nil").."/"..(info.old_param2 or "nil").." to "..(info.new_name or "nil").."/"..(info.new_param2).." (c="..(counter + 1)..")")
				if rollback_log[hash] == nil then
					rollback_log[hash] = {name = assert(info.old_name), param2 = info.old_param2}
				end
				swap_node(pos, {name = info.new_name, param2 = info.new_param2})
				counter = counter + 1
			end
			info.old_name = info.new_name
			info.old_param2 = info.new_param2
			info.new_name = nil
			info.new_param2 = nil
		end
	end
	return counter
end

ch_smooth.NodeManipulator = NodeManipulator
