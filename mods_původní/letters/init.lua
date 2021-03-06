letters = {
	{"al", "au", "a", "A"},
	{"bl", "bu", "b", "B"},
	{"cl", "cu", "c", "C"},
	{"dl", "du", "d", "D"},
	{"el", "eu", "e", "E"},
	{"fl", "fu", "f", "F"},
	{"gl", "gu", "g", "G"},
	{"hl", "hu", "h", "H"},
	{"il", "iu", "i", "I"},
	{"jl", "ju", "j", "J"},
	{"kl", "ku", "k", "K"},
	{"ll", "lu", "l", "L"},
	{"ml", "mu", "m", "M"},
	{"nl", "nu", "n", "N"},
	{"ol", "ou", "o", "O"},
	{"pl", "pu", "p", "P"},
	{"ql", "qu", "q", "Q"},
	{"rl", "ru", "r", "R"},
	{"sl", "su", "s", "S"},
	{"tl", "tu", "t", "T"},
	{"ul", "uu", "u", "U"},
	{"vl", "vu", "v", "V"},
	{"wl", "wu", "w", "W"},
	{"xl", "xu", "x", "X"},
	{"yl", "yu", "y", "Y"},
	{"zl", "zu", "z", "Z"},
}

local letters_reversed = {}

for i, t in ipairs(letters) do
	letters_reversed[t[3]] = i
end

local letter_cutter = {}
letter_cutter.known_nodes = {}

letter_cutter.show_item_list = dofile(
	minetest.get_modpath(minetest.get_current_modname())..'/itemlist.lua')

function letters.register_letters(modname, subname, from_node, description, tiles, def)

	def = def and table.copy(def) or {}

	--default node
	def.drawtype = "signlike"
	def.paramtype = "light"
	def.paramtype2 = def.paramtype2 or "wallmounted"
	def.sunlight_propagates = true
	def.is_ground_content = false
	def.walkable = false
	def.selection_box = {
		type = "wallmounted"
		--wall_top = <default>
		--wall_bottom = <default>
		--wall_side = <default>
	}
	def.groups = def.groups or {
		not_in_creative_inventory = 1,
		not_in_craft_guide = 1,
		oddly_breakable_by_hand = 1,
		attached_node = 1
	}
	def.legacy_wallmounted = false


	for _, row in ipairs(letters) do

		def = table.copy(def)
		def.description = description.. " " ..row[3]
		def.inventory_image = tiles.. "^letters_" ..row[1].. "_overlay.png^[makealpha:255,126,126"
		def.wield_image = def.inventory_image
		def.tiles = {def.inventory_image}

		minetest.register_node(":" ..modname..":"..subname.. "_letter_" ..row[1],def)

		def = table.copy(def)
		def.description = description.. " " ..row[4]
		def.inventory_image = tiles.. "^letters_" ..row[2].. "_overlay.png^[makealpha:255,126,126"
		def.wield_image = def.inventory_image
		def.tiles = {def.inventory_image}

		minetest.register_node(":" ..modname..":"..subname.. "_letter_" ..row[2], def)

		--[[minetest.register_craft({
			output = from_node,
			recipe = {
				{modname..":"..name, modname..":"..name, modname..":"..name},
				{modname..":"..name, modname..":"..name, modname..":"..name},
				{modname..":"..name, modname..":"..name, modname..":"..name},
			},
		})--]]
	end
	letter_cutter.known_nodes[from_node] = {modname, subname}
end

local cost = 0.110

letter_cutter.names_lower = {
	{"letter_al"},
	{"letter_bl"},
	{"letter_cl"},
	{"letter_dl"},
	{"letter_el"},
	{"letter_fl"},
	{"letter_gl"},
	{"letter_hl"},
	{"letter_il"},
	{"letter_jl"},
	{"letter_kl"},
	{"letter_ll"},
	{"letter_ml"},
	{"letter_nl"},
	{"letter_ol"},
	{"letter_pl"},
	{"letter_ql"},
	{"letter_rl"},
	{"letter_sl"},
	{"letter_tl"},
	{"letter_ul"},
	{"letter_vl"},
	{"letter_wl"},
	{"letter_xl"},
	{"letter_yl"},
	{"letter_zl"},
}

letter_cutter.names_upper = {
	{"letter_au"},
	{"letter_bu"},
	{"letter_cu"},
	{"letter_du"},
	{"letter_eu"},
	{"letter_fu"},
	{"letter_gu"},
	{"letter_hu"},
	{"letter_iu"},
	{"letter_ju"},
	{"letter_ku"},
	{"letter_lu"},
	{"letter_mu"},
	{"letter_nu"},
	{"letter_ou"},
	{"letter_pu"},
	{"letter_qu"},
	{"letter_ru"},
	{"letter_su"},
	{"letter_tu"},
	{"letter_uu"},
	{"letter_vu"},
	{"letter_wu"},
	{"letter_xu"},
	{"letter_yu"},
	{"letter_zu"},
}

function letter_cutter:get_output_inv_lower(modname, subname, amount, max)

	local list = {}
	if amount < 1 then
		return list
	end

	for i, t in ipairs(letter_cutter.names_lower) do
		table.insert(list, modname .. ":" .. subname .. "_" .. t[1]
			.. " " .. math.min(math.floor(amount/cost), max))
	end
	return list
end

function letter_cutter:get_output_inv_upper(modname, subname, amount, max)

	local list = {}
	if amount < 1 then
		return list
	end

	for i, t in ipairs(letter_cutter.names_upper) do
		table.insert(list, modname .. ":" .. subname .. "_" .. t[1]
			.. " " .. math.min(math.floor(amount/cost), max))
	end
	return list
end

function letter_cutter:reset_lower(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("output", {})
	meta:set_int("anz", 0)

	meta:set_string("infotext",
			"Letter Cutter (Lower) is empty (owned by "..
				meta:get_string("owner")..")")
end

function letter_cutter:reset_upper(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("output", {})
	meta:set_int("anz", 0)

	meta:set_string("infotext",
			"Letter Cutter (Upper) is empty (owned by "..
				meta:get_string("owner")..")")
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
			"Letter Cutter (Lower) is working (owned by "..
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
			"Letter Cutter (Upper) is working (owned by "..
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
		if not inv:is_empty("input") and
				inv:get_stack("input", index):get_name() ~= stackname then
			return 0
		end
		for name, t in pairs(letter_cutter.known_nodes) do
			if name == stackname and inv:room_for_item("input", stack) then
				return count
			end
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
	meta:set_string("formspec", "size[11,9]" ..gui_slots..
			"label[0,0;Input\nmaterial]" ..
			"list[current_name;input;1.5,0;1,1;]" ..
			"list[current_name;output;2.8,0;8,4;]" ..
			"button[0,1;2.5,1;itemlist;Cuttable materials]" ..
			"list[current_player;main;1.5,5;8,4;]" ..
			"field[0.5,4.3;3,1;text;Enter text;${text}]" ..
			"button[3.5,4;2,1;make_text;Make text]" ..
			"label[5.5,4.2;" .. minetest.formspec_escape(meta:get_string("message")) .. "]")
end

local function cut_from_text(pos, input_text, player)
	local playername = player:get_player_name()

	local meta = minetest.get_meta(pos)

	local cutterinv = meta:get_inventory()
	local cutterinput = cutterinv:get_list("input")
	local cuttercount = cutterinput[1]:get_count()

	if cuttercount < 1 then
		meta:set_string("message", "No materials.")
		update_cutter_formspec(pos)
		return
	end

	local origname = cutterinput[1]:get_name()

	local playerinv = player:get_inventory()

	meta:set_string("text", input_text)

	local totalcost = 0
	local throwawayinv = minetest.create_detached_inventory("letter_cutter:throwaway", {}, playername)

	throwawayinv:set_size("main", playerinv:get_size("main"))
	throwawayinv:set_list("main", playerinv:get_list("main"))

	for i = 1, #input_text do
		local char = input_text:sub(i, i)

		if char:match("[%u%l]") then
			local isupper = char == char:upper()
			local charset = isupper and letter_cutter.names_upper or letter_cutter.names_lower
			local lettername = origname .. "_" .. charset[letters_reversed[char:lower()]][1]

			if cuttercount < totalcost + cost then
				meta:set_string("message", "Not enough materials.")
				update_cutter_formspec(pos)

				minetest.remove_detached_inventory("letter_cutter:throwaway")
				return
			end

			if lettername and not throwawayinv:room_for_item("main", lettername) then
				meta:set_string("message", "Not enough room.")
				update_cutter_formspec(pos)

				minetest.remove_detached_inventory("letter_cutter:throwaway")
				return
			end

			totalcost = totalcost + cost

			throwawayinv:add_item("main", lettername)
		end
	end

	meta:set_string("message", "Successfully added letters to inventory.")
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
	meta:set_string("infotext", "Letter Cutter (Lower) is empty")

	meta:set_string("text", "")
	meta:set_string("message", "")

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("output", 4*8) -- 4x8 versions of stair-parts of material x.

	letter_cutter:reset_lower(pos)
end

function letter_cutter.on_construct_upper(pos)
	local meta = minetest.get_meta(pos)
	update_cutter_formspec(pos)

	meta:set_int("anz", 0) -- No microblocks inside yet.
	meta:set_string("max_offered", 9) -- How many items of this kind are offered by default?
	meta:set_string("infotext", "Letter Cutter (Upper) is empty")

	meta:set_string("text", "")
	meta:set_string("message", "")

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("output", 4*8) -- 4x8 versions of stair-parts of material x.

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
	if fields.itemlist then
		local list = {}
		for name, t in pairs(letter_cutter.known_nodes) do
			list[#list+1] = name
		end
		letter_cutter.show_item_list(sender, 'Cuttable materials', list, pos)
		return
	end

	if fields.make_text and fields.text then
		cut_from_text(pos, fields.text, sender)
		return
	end
end

minetest.register_node("letters:letter_cutter_lower",  {
	description = "Lower Case Leter Cutter",
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
				"Letter Cutter (Lower) is empty (owned by "
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
	description = "Upper Case Leter Cutter",
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
				"Letter Cutter (Upper) is empty (owned by "
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

dofile(minetest.get_modpath("letters").."/registrations.lua")
