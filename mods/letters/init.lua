print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local S = minetest.get_translator("letters")

letters = {
	register_letters = function(modname, subname, from_node, description, tiles, def)
		return true -- only for API compatibility
	end,
}

local lower_letters = {
	{"al", "a"},
	{"aal", "á"},
	{"ael", "ä"},
	{"bl", "b"},
	{"cl", "c"},
	{"ccl", "č"},
	{"dl", "d"},
	{"ddl", "ď"},
	{"el", "e"},
	{"eel", "é"},
	{"ejel", "ě"},
	{"fl", "f"},
	{"gl", "g"},
	{"hl", "h"},
	{"il", "i"},
	{"iil", "í"},
	{"jl", "j"},
	{"kl", "k"},
	{"ll", "l"},
	{"ldl", "ĺ"},
	{"lml", "ľ"},
	{"ml", "m"},
	{"nl", "n"},
	{"nnl", "ň"},
	{"ol", "o"},
	{"ool", "ó"},
	{"ouol", "ô"},
	{"pl", "p"},
	{"ql", "q"},
	{"rl", "r"},
	{"rrl", "ř"},
	{"rrrl", "ŕ"},
	{"sl", "s"},
	{"ssl", "š"},
	{"tl", "t"},
	{"ttl", "ť"},
	{"ul", "u"},
	{"uul", "ú"},
	{"uoul", "ů"},
	{"vl", "v"},
	{"wl", "w"},
	{"xl", "x"},
	{"yl", "y"},
	{"yyl", "ý"},
	{"zl", "z"},
	{"zzl", "ž"},
	{"dot", ".", "Symbol"},
	{"comma", ",", "Symbol"},
	{"semicolon", ";", "Symbol"},
	{"colon", ":", "Symbol"},
	{"exm", "!", "Symbol"},
	{"qm", "?", "Symbol"},
	{"plus", "+", "Symbol"},
	{"minus", "-", "Symbol"},
	{"star", "*", "Symbol"},
	{"slash", "/", "Symbol"},
	{"bslash", "\\", "Symbol"},
	{"uscore", "_", "Symbol"},
	{"copy", "©", "Symbol"},
}

local upper_letters = {
	{"au", "A"},
	{"aau", "Á"},
	{"aeu", "Ä"},
	{"bu", "B"},
	{"cu", "C"},
	{"ccu", "Č"},
	{"du", "D"},
	{"ddu", "Ď"},
	{"eu", "E"},
	{"eeu", "É"},
	{"ejeu", "Ě"},
	{"fu", "F"},
	{"gu", "G"},
	{"hu", "H"},
	{"iu", "I"},
	{"iiu", "Í"},
	{"ju", "J"},
	{"ku", "K"},
	{"lu", "L"},
	{"ldu", "Ĺ"},
	{"lmu", "Ľ"},
	{"mu", "M"},
	{"nu", "N"},
	{"nnu", "Ň"},
	{"ou", "O"},
	{"oou", "Ó"},
	{"ouou", "Ô"},
	{"pu", "P"},
	{"qu", "Q"},
	{"ru", "R"},
	{"rru", "Ř"},
	{"rrru", "Ŕ"},
	{"su", "S"},
	{"ssu", "Š"},
	{"tu", "T"},
	{"ttu", "Ť"},
	{"uu", "U"},
	{"uuu", "Ú"},
	{"uouu", "Ů"},
	{"vu", "V"},
	{"wu", "W"},
	{"xu", "X"},
	{"yu", "Y"},
	{"yyu", "Ý"},
	{"zu", "Z"},
	{"zzu", "Ž"},
	{"0", "0", "Digit"},
	{"1", "1", "Digit"},
	{"2", "2", "Digit"},
	{"3", "3", "Digit"},
	{"4", "4", "Digit"},
	{"5", "5", "Digit"},
	{"6", "6", "Digit"},
	{"7", "7", "Digit"},
	{"8", "8", "Digit"},
	{"9", "9", "Digit"},
	{"zavinac", "@", "Symbol"},
	{"hash", "#", "Symbol"},
	{"percent", "%", "Symbol"},
	{"eq", "=", "Symbol"},
}

local letter_cutter = {
	known_nodes = {},
}

--[[
letter_cutter.show_item_list = dofile(
	minetest.get_modpath(minetest.get_current_modname())..'/itemlist.lua')
]]

function letters.register_letters(modname, subname, from_node, description, tiles, def)
	return true
end

local def_base = {
	description = "",
	inventory_image = "",
	wield_image = "",
	tiles = {},
	--
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "colorwallmounted",
	palette = "unifieddyes_palette_colorwallmounted.png",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {type = "wallmounted"},
	groups = {
		oddly_breakable_by_hand = 2,
		ud_param2_colorable = 1,
		-- not_in_creative_inventory = 1,
		-- not_in_craft_guide = 1,
	},
	legacy_wallmounted = false,
	on_dig = unifieddyes.on_dig,
}
local def, texture

for _, letters_list in ipairs({lower_letters, upper_letters}) do
	for _, row in ipairs(letters_list) do
		def = table.copy(def_base)
		def.description = S((row[3] or "Letter").." \"@1\"", row[2])
		texture = "letters_pattern.png^letters_" ..row[1].. "_overlay.png^[makealpha:255,126,126"
		def.inventory_image = texture
		def.wield_image = texture
		def.tiles = {texture}
		minetest.register_node("letters:letter_" ..row[1], def)
	end
end

local cost = 0.110

function letter_cutter:get_output_inv_lower(modname, subname, amount, max)

	local list = {}
	if amount < 1 then
		return list
	end

	for i, t in ipairs(lower_letters) do
		table.insert(list, "letters:letter_" ..t[1].." "..math.min(math.floor(amount/cost), max))
	end
	return list
end

function letter_cutter:get_output_inv_upper(modname, subname, amount, max)

	local list = {}
	if amount < 1 then
		return list
	end

	for i, t in ipairs(upper_letters) do
		table.insert(list, "letters:letter_" ..t[1].." "..math.min(math.floor(amount/cost), max))
	end
	return list
end

function letter_cutter:reset_lower(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("output", {})
	meta:set_int("anz", 0)

	meta:set_string("infotext", "Řezačka na malá písmena je prázdná (postavil/a ji "..meta:get_string("owner")..")")
end

function letter_cutter:reset_upper(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("output", {})
	meta:set_int("anz", 0)

	meta:set_string("infotext", "Řezačka na velká písmena je prázdná (postavil/a ji "..meta:get_string("owner")..")")
end

function letter_cutter:update_inventory_lower(pos, amount)
	local meta          = minetest.get_meta(pos)
	local inv           = meta:get_inventory()

	amount = meta:get_int("anz") + amount

	if amount < 1 then -- If the last block is taken out.
		self:reset_lower(pos)
		return
	end

	local stack = inv:get_stack("input",  1)
	if stack:is_empty() then
		self:reset_lower(pos)
		return

	end
	local node_name = stack:get_name() or ""
	local name_parts = letter_cutter.known_nodes[node_name] or ""
	local modname  = name_parts[1] or ""
	local material = name_parts[2] or ""

	inv:set_list("input", {
		node_name.. " " .. math.floor(amount)
	})

	-- Display:
	inv:set_list("output",
		self:get_output_inv_lower(modname, material, amount,
				meta:get_int("max_offered")))
	-- Store how many microblocks are available:
	meta:set_int("anz", amount)

	meta:set_string("infotext",
			"Řezačka na malá písmena pracuje (postavil/a ji "..
				meta:get_string("owner")..")")
end

function letter_cutter:update_inventory_upper(pos, amount)
	local meta          = minetest.get_meta(pos)
	local inv           = meta:get_inventory()

	amount = meta:get_int("anz") + amount

	if amount < 1 then -- If the last block is taken out.
		self:reset_upper(pos)
		return
	end

	local stack = inv:get_stack("input",  1)
	if stack:is_empty() then
		self:reset_upper(pos)
		return

	end
	local node_name = stack:get_name() or ""
	local name_parts = letter_cutter.known_nodes[node_name] or ""
	local modname  = name_parts[1] or ""
	local material = name_parts[2] or ""

	inv:set_list("input", {
		node_name.. " " .. math.floor(amount)
	})

	-- Display:
	inv:set_list("output",
		self:get_output_inv_upper(modname, material, amount,
				meta:get_int("max_offered")))
	-- Store how many microblocks are available:
	meta:set_int("anz", amount)

	meta:set_string("infotext",
			"Řezačka na velká písmena pracuje (postavil/a ji "..
				meta:get_string("owner")..")")
end


function letter_cutter.allow_metadata_inventory_move(
		pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end


-- Only input- and recycle-slot are intended as input slots:
function letter_cutter.allow_metadata_inventory_put(
		pos, listname, index, stack, player)
	-- The player is not allowed to put something in there:
	if listname == "output" then
		return 0
	end

	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	local stackname = stack:get_name()
	local count = stack:get_count()

	-- Only accept certain blocks as input which are known to be craftable into stairs:
	if listname == "input" then
		if not inv:is_empty("input") and inv:get_stack("input", index):get_name() ~= stackname then
			return 0
		end
		local def = minetest.registered_nodes[stackname]
		if def and def.groups and def.groups.bakedclay and inv:room_for_item("input", stack) then
			return count
		end
		return 0
	end
end

function letter_cutter.on_metadata_inventory_put_lower(
		pos, listname, index, stack, player)
	local count = stack:get_count()

	if listname == "input" then
		letter_cutter:update_inventory_lower(pos, count)
	end
end

function letter_cutter.on_metadata_inventory_put_upper(
		pos, listname, index, stack, player)
	local count = stack:get_count()

	if listname == "input" then
		letter_cutter:update_inventory_upper(pos, count)
	end
end

function letter_cutter.on_metadata_inventory_take_lower(
		pos, listname, index, stack, player)
	if listname == "output" then
		-- We do know how much each block at each position costs:
		letter_cutter:update_inventory_lower(pos, 8 * -cost)
	elseif listname == "input" then
		-- Each normal (= full) block taken costs 8 microblocks:
		letter_cutter:update_inventory_lower(pos, 8 * -stack:get_count())
	end
	-- The recycle field plays no role here since it is processed immediately.
end

function letter_cutter.on_metadata_inventory_take_upper(
		pos, listname, index, stack, player)
	if listname == "output" then
		-- We do know how much each block at each position costs:
		letter_cutter:update_inventory_upper(pos, 8 * -cost)
	elseif listname == "input" then
		-- Each normal (= full) block taken costs 8 microblocks:
		letter_cutter:update_inventory_upper(pos, 8 * -stack:get_count())
	end
	-- The recycle field plays no role here since it is processed immediately.
end

function letter_cutter.remove_from_input(pos, origname, count)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	local cutterinv = meta:get_inventory()

	local removed = cutterinv:remove_item("input", origname .. " " .. tostring(count))
	if node.name == "letters:letter_cutter_upper" then
		letter_cutter:update_inventory_upper(pos, -removed:get_count())
	else
		letter_cutter:update_inventory_lower(pos, -removed:get_count())
	end
end

local gui_slots = "listcolors[#606060AA;#808080;#101010;#202020;#FFF]"

local function update_cutter_formspec(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[15,10]" ..gui_slots..
			"label[0,0;Vstupní\nmateriál]" ..
			"list[current_name;input;1.5,0;1,1;]" ..
			"list[current_name;output;2.8,0;12,5;]" ..
			-- "button[0,1;2.5,1;itemlist;Použitelné materiály]" ..
			"list[current_player;main;1.5,6;8,4;]" ..
			"field[0.5,5.3;5,1;text;Zadat text;${text}]" ..
			"button[5.5,5;2,1;make_text;Vyřezat text]" ..
			"label[7.5,5.2;" .. minetest.formspec_escape(meta:get_string("message")) .. "]")
end

local function cut_from_text(pos, input_text, player)
	local playername = player:get_player_name()

	local meta = minetest.get_meta(pos)
    local cuttername = minetest.get_node(pos).name

	local cutterinv = meta:get_inventory()
	local cutterinput = cutterinv:get_list("input")
	local cuttercount = cutterinput[1]:get_count()

	if cuttercount < 1 then
		meta:set_string("message", "Chybí materiál.")
		update_cutter_formspec(pos)
		return
	end

	local origname = cutterinput[1]:get_name()

	local playerinv = player:get_inventory()

	meta:set_string("text", input_text)

	local totalcost = 0
	local throwawayinv = minetest.create_detached_inventory("letter_cutter:throwaway", {}, playername)
	local letter_list = cuttername == "letters:letter_cutter_upper" and upper_letters or lower_letters

	throwawayinv:set_size("main", playerinv:get_size("main"))
	throwawayinv:set_list("main", playerinv:get_list("main"))
    local i = 1
    while i <= #input_text do
        local char = nil
        local lettername = nil
		for j, letter_def in ipairs(letter_list) do
            if string.sub(input_text, i, i + string.len(letter_def[2]) - 1) == letter_def[2] then
                char = letter_def[2]
                lettername = "letters:letter_"..letter_def[1]
				break
            end
        end
        if char then
			if cuttercount < totalcost + cost then
				meta:set_string("message", "Nedostatek materiálu.")
				update_cutter_formspec(pos)

				minetest.remove_detached_inventory("letter_cutter:throwaway")
				return
			end

			if lettername and not throwawayinv:room_for_item("main", lettername) then
				meta:set_string("message", "Nedostatek místa.")
				update_cutter_formspec(pos)

				minetest.remove_detached_inventory("letter_cutter:throwaway")
				return
			end

			totalcost = totalcost + cost

			throwawayinv:add_item("main", lettername)
            i = i + string.len(char)
        else
            i = i + 1
        end
	end

	meta:set_string("message", "Písmena úspěšně přidána do inventáře.")
	update_cutter_formspec(pos)

	letter_cutter.remove_from_input(pos, origname, tostring(math.ceil(totalcost)))
	playerinv:set_list("main", throwawayinv:get_list("main"))

	minetest.remove_detached_inventory("letter_cutter:throwaway")
end

function letter_cutter.on_construct_lower(pos)
	local meta = minetest.get_meta(pos)
	update_cutter_formspec(pos)

	meta:set_int("anz", 0) -- No microblocks inside yet.
	meta:set_string("max_offered", 9) -- How many items of this kind are offered by default?
	meta:set_string("infotext", "Řezačka na malá písmena je prázdná")

	meta:set_string("text", "")
	meta:set_string("message", "")

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("output", 5*12) -- 5x12 versions of stair-parts of material x.

	letter_cutter:reset_lower(pos)
end

function letter_cutter.on_construct_upper(pos)
	local meta = minetest.get_meta(pos)
	update_cutter_formspec(pos)

	meta:set_int("anz", 0) -- No microblocks inside yet.
	meta:set_string("max_offered", 9) -- How many items of this kind are offered by default?
	meta:set_string("infotext", "Řezačka na velká písmena je prázdná")

	meta:set_string("text", "")
	meta:set_string("message", "")

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("output", 5*12) -- 5x12 versions of stair-parts of material x.

	letter_cutter:reset_upper(pos)
end


function letter_cutter.can_dig(pos,player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("input") then
		return false
	end
	return true
end

function letter_cutter.on_receive_fields(pos, formname, fields, sender)
	if fields.make_text and fields.text then
		cut_from_text(pos, fields.text, sender)
		return
	end
end

minetest.register_node("letters:letter_cutter_lower",  {
	description = "řezačka na malá písmena",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, -0.3125, 0.125, -0.3125}, -- NodeBox1
			{-0.4375, -0.5, 0.3125, -0.3125, 0.125, 0.4375}, -- NodeBox2
			{0.3125, -0.5, 0.3125, 0.4375, 0.125, 0.4375}, -- NodeBox3
			{0.3125, -0.5, -0.4375, 0.4375, 0.125, -0.3125}, -- NodeBox4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- NodeBox5
				{-0.125, 0.25, 0.125, 0.125, 0.3125, 0.1875}, -- NodeBox6
			{0.125, 0.25, 0.0625, 0.1875, 0.3125, 0.125}, -- NodeBox7
			{0.1875, 0.25, -0.1875, 0.25, 0.3125, 0.1875}, -- NodeBox8
			{-0.1875, 0.25, 0.0625, -0.125, 0.3125, 0.125}, -- NodeBox9
			{-0.25, 0.25, -0.1875, -0.1875, 0.3125, 0.0625}, -- NodeBox10
			{-0.1875, 0.25, -0.25, -0.125, 0.3125, -0.1875}, -- NodeBox11
			{-0.125, 0.25, -0.3125, 0.125, 0.3125, -0.25}, -- NodeBox12
			{0.125, 0.25, -0.25, 0.375, 0.3125, -0.1875}, -- NodeBox13
			{0.3125, 0.25, -0.1875, 0.375, 0.3125, -0.125}, -- NodeBox14
		},
	},
	tiles = {"letters_letter_cutter_lower_top.png",
		"default_tree.png",
		"letters_letter_cutter_side.png"},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy = 2,oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	on_construct = letter_cutter.on_construct_lower,
	can_dig = letter_cutter.can_dig,
	-- Set the owner of this circular saw.
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local owner = placer and placer:get_player_name() or ""
		meta:set_string("owner",  owner)
		meta:set_string("infotext",
				"Řezačka na malá písmena je prázdná (postavil/a ji "
					..meta:get_string("owner")..")")
	end,
	allow_metadata_inventory_move = letter_cutter.allow_metadata_inventory_move,
	-- Only input- and recycle-slot are intended as input slots:
	allow_metadata_inventory_put = letter_cutter.allow_metadata_inventory_put,
	-- Taking is allowed from all slots (even the internal microblock slot). Moving is forbidden.
	-- Putting something in is slightly more complicated than taking anything because we have to make sure it is of a suitable material:
	on_metadata_inventory_put = letter_cutter.on_metadata_inventory_put_lower,
	on_metadata_inventory_take = letter_cutter.on_metadata_inventory_take_lower,
	on_receive_fields = letter_cutter.on_receive_fields,
})

minetest.register_craft({
	output = "letters:letter_cutter_lower",
	recipe = {
		{"default:tree", "default:tree", "default:tree"},
		{"default:wood", "default:steel_ingot", "default:wood"},
		{"default:tree", "", "default:tree"},
	},
})

minetest.register_node("letters:letter_cutter_upper",  {
	description = "řezačka na velká písmena a číslice",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, -0.3125, 0.125, -0.3125}, -- NodeBox1
			{-0.4375, -0.5, 0.3125, -0.3125, 0.125, 0.4375}, -- NodeBox2
			{0.3125, -0.5, 0.3125, 0.4375, 0.125, 0.4375}, -- NodeBox3
			{0.3125, -0.5, -0.4375, 0.4375, 0.125, -0.3125}, -- NodeBox4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- NodeBox5
			{0.1875, 0.25, -0.125, 0.125, 0.3125, -0.3125}, -- NodeBox6
			{0.125, 0.25, 0.125, 0.0625, 0.3125, -0.125}, -- NodeBox7
			{0.0625, 0.25, 0.3125, -0.0625, 0.3125, 0.0625}, -- NodeBox8
			{-0.0625, 0.25, 0.125, -0.125, 0.3125, -0.125}, -- NodeBox9
			{-0.125, 0.25, -0.125, -0.1875, 0.3125, -0.3125}, -- NodeBox10
			{0.125, 0.25, -0.125, -0.125, 0.3125, -0.1875}, -- NodeBox11
		},
	},
	tiles = {"letters_letter_cutter_upper_top.png",
		"default_tree.png",
		"letters_letter_cutter_side.png"},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy = 2,oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	on_construct = letter_cutter.on_construct_upper,
	can_dig = letter_cutter.can_dig,
	-- Set the owner of this circular saw.
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local owner = placer and placer:get_player_name() or ""
		meta:set_string("owner",  owner)
		meta:set_string("infotext",
				"Řezačka na velká písmena a číslice je prázdná (postavil/a ji "
					..meta:get_string("owner")..")")
	end,
	allow_metadata_inventory_move = letter_cutter.allow_metadata_inventory_move,
	-- Only input- and recycle-slot are intended as input slots:
	allow_metadata_inventory_put = letter_cutter.allow_metadata_inventory_put,
	-- Taking is allowed from all slots (even the internal microblock slot). Moving is forbidden.
	-- Putting something in is slightly more complicated than taking anything because we have to make sure it is of a suitable material:
	on_metadata_inventory_put = letter_cutter.on_metadata_inventory_put_upper,
	on_metadata_inventory_take = letter_cutter.on_metadata_inventory_take_upper,
	on_receive_fields = letter_cutter.on_receive_fields,
})

minetest.register_craft({
	output = "letters:letter_cutter_upper",
	recipe = {
		{"default:tree", "default:tree", "default:tree"},
		{"default:wood", "default:steel_ingot", "default:wood"},
		{"default:tree", "default:steel_ingot", "default:tree"},
	},
})
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
