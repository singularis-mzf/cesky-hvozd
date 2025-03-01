ch_base.open_mod(minetest.get_current_modname())
-------------------------------------------------------------------------------------
--    _________               ___.         __________.__                 __        --
--    \_   ___ \  ____   _____\_ |__   ____\______   \  |   ____   ____ |  | __    --
--    /    \  \/ /  _ \ /     \| __ \ /  _ \|    |  _/  |  /  _ \_/ ___\|  |/ /    --
--    \     \___(  <_> )  Y Y  \ \_\ (  <_> )    |   \  |_(  <_> )  \___|    <     --
--     \______  /\____/|__|_|  /___  /\____/|______  /____/\____/ \___  >__|_ \    --
--            \/             \/    \/              \/                 \/     \/    --
--                                                                                 --
--                  Orginally written/created by Pithydon/Pithy                    --
--					           Version 5.5.0.1_CH                                  --
--                first 3 numbers version of minetest created for,                 --
--                   last digit mod version for MT version                         --
--                       This is a fork for Český hvozd                            --
-------------------------------------------------------------------------------------

-- list of allowed combo blocks (do not change order!)
local combos = {
	[1] = {a = "bakedclay:slab_baked_clay_natural", b = "darkage:slab_ors_brick", ts = 64},
	[2] = {a = "moreblocks:slab_cactus_brick", b = "moreblocks:slab_cobble", ts = 64},
	[3] = {a = "darkage:slab_ors_brick", b = "wool:slab_brown", ts = 64},
	[4] = {a = "bakedclay:slab_baked_clay_red", b = "darkage:slab_ors_brick", ts = 64},
	[5] = {a = "bakedclay:slab_baked_clay_brown", b = "darkage:slab_ors_brick", ts = 64},
	[6] = {a = "ch_core:slab_plaster_white", b = "xdecor:slab_wood_tile", ts = 64},
	[7] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_blue", ts = 64},
	[8] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_cyan", ts = 64},
	[9] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_dark_green", ts = 64},
	[10] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_dark_grey", ts = 64},
	[11] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_grey", ts = 64},
	[12] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_medium_amber_s50", ts = 64},
	[13] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_orange", ts = 64},
	[14] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_pink", ts = 64},
	[15] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_red", ts = 64},
	[16] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_green", ts = 64},
	[17] = {a = "ch_core:slab_plaster_white", b = "ch_core:slab_plaster_yellow", ts = 64},
	[18] = {a = "technic:slab_concrete", b = "building_blocks:slab_Tar", ts = 128},
	[19] = {a = "technic:slab_concrete", b = "streets:slab_asphalt_red", ts = 128},
	[20] = {a = "technic:slab_concrete", b = "streets:slab_asphalt_blue", ts = 128},
	[21] = {a = "default:slab_silver_sandstone_block", b = "ch_core:slab_plaster_medium_amber_s50", ts = 64},
	[22] = {a = "moreblocks:slab_gravel", b = "technic:slab_concrete", ts = 128},
	[23] = {a = "ch_extras:slab_railway_gravel", b = "technic:slab_concrete", ts = 128},
	[24] = {a = "ch_extras:slab_railway_gravel", b = "moreblocks:slab_gravel", ts = 64},
}

local function combo_after_change(pos, old_node, new_node, player, nodespec)
	local ndef = core.registered_nodes[old_node.name]
	if ndef ~= nil then
		-- give the other slab to the player
		if new_node.name == ndef.comboblock_v1 then
			player:get_inventory():add_item("main", assert(ndef.comboblock_v2))
		elseif new_node.name == ndef.comboblock_v2 then
			player:get_inventory():add_item("main", assert(ndef.comboblock_v1))
		end
	end
end

local allowed_combos = {}
local shape_selector_groups = {}
for i, v in ipairs(combos) do
	local a, b = assert(v.a), assert(v.b)
	if not a or not b then
		error("allowed_combos: Invalid format for index "..i)
	end
	local n = a.."+"..b
	local x = allowed_combos[n] or allowed_combos[b.."+"..a]
	if x then
		error("allowed_combos: Duplicity at ["..i.."] = ["..x.."] = "..dump2(v))
	end
	allowed_combos[n] = i
	shape_selector_groups[n] = {columns = 4, rows = 1, nodes = {}, after_change = combo_after_change}
end

local ch_help = "Kombinované bloky získáte položením desky (8/16) jednoho typu\nna desku (8/16) druhého typu. Jen některé kombinace jsou dovoleny.\nZáleží na pořadí; při položení v opačném pořadí získáte jiný blok. Výsledný blok lze otáčet."
local ch_help_group = "comboblock"

----------------------------
--        Settings        --
----------------------------
local S = minetest.get_translator(minetest.get_current_modname())
local node_count = 0
local existing_node_count = 0
local to_many_nodes = false
comboblock = {}

local m_name = minetest.get_current_modname()
local m_path = minetest.get_modpath(m_name)
--	dofile(m_path.. "/i_comboblock_letter.lua" )


local groups_to_inherit = {
	"choppy", "crumbly", "snappy", "oddly_breakable_by_hand", "flammable"
}

----------------------------
--       Functions        --
----------------------------
	----------------------------
	-- Add Lowpart and Resize --
	----------------------------
	-- Add "^[lowpart:50:" and resize to all image names
	-- against source node for V2 (bottoms)
	local function add_lowpart(tiles, ts)

		if type(tiles) == "table" then
			tiles = tiles.name
		end
		local name_split = string.split(tiles,"^")
		local new_name = ""
		local i = 1
			while i <= #name_split do

				if string.sub(name_split[i],1,1) == "[" then
					if name_split[i] =="[transformR90" then                -- remove the rotate 90's
						new_name = new_name.."^[transformR180FY"..name_split[i]
					elseif i > 1 and string.sub(name_split[i], 1, 10) == "[multiply:" then
						new_name = new_name.."\\^[multiply\\:"..string.sub(name_split[i],11,-1) -- apply coloring only on lower part
					else
						new_name = new_name.."^"..name_split[i]            -- catch coloring etc
					end
				else
					new_name = new_name..
							   "^[lowpart:50:"..name_split[i]..            -- overlay lower 50%
							   "\\^[resize\\:"..ts.."x"..ts                -- resize image to comboblock scale

				end
				i=i+1
			end
		return new_name                                             -- Output Single image eg ^[lowpart:50:default_cobble.png
	end                                                             -- Output Two or more image eg  ^[lowpart:50:default_cobble.png^[lowpart:50:cracked_cobble.png

	local function preprocess_description(slab_name)
		local material = stairsplus:analyze_shape(slab_name)
		local ndef = material and core.registered_nodes[material]
		local description
		if ndef ~= nil then
			description = ndef.description
			if description ~= nil then
				return "„"..description.."“"
			end
		end
		ndef = core.registered_nodes[slab_name]
		description = ndef.description
		if description ~= nil then
			return "„"..description.."“"
		end
		return "?"
	end

	local function preprocess_tiles(tiles)
		if type(tiles) == "string" then
			return {{name = tiles, backface_culling = true}}
		end
		local result = {}
		for i, t in ipairs(tiles) do
			if type(t) == "string" then
				result[i] = {name = t, backface_culling = true}
			elseif type(t) == "table" then
				result[i] = table.copy(t)
				result[i].backface_culling = true
			else
				-- unsupported case
				minetest.log("warning", "Unexpected tile type "..type(t).." detected!")
				result[i] = {name = "default_cobble.png", backface_culling = true}
			end
		end
		return result
	end

	local function preprocess_tiles_v2(tiles, ts)
		assert(ts)
		tiles = preprocess_tiles(tiles)
		for i = 2, 6, 1 do 											 -- Checks for image names for each side, If not image name
			if not tiles[i] and i <= 2 then						 -- then copy previous image name in: 1 = Top, 2 = Bottom, 3-6 = Sides
				tiles[i] = tiles[i-1]

			elseif i >= 3 then

				if not tiles[i] then
					if type(tiles[i-1]) == "table" then
						tiles[i] = table.copy(tiles[i-1])        	 -- must be table copy as we don't want a pointer
					else
						tiles[i] = { name = tiles[i-1] }
					end
					tiles[i].name = add_lowpart(tiles[i], ts)  	 -- only need to do this once as 4,5,6 are basically copy of 3
				else
					tiles[i].name = add_lowpart(tiles[i], ts)  	  -- If node has images specified for each slot have to add  string to the front of those
				end
			end
		end
		return tiles
	end

	-------------------------
	-- Get Comboblock Name --
	-------------------------
	local function cb_get_name(pla_tar,placer,node_c_name)   -- pas == pot_short_axis

		if not pla_tar.err then
			local first_node_name = pla_tar[1]
			local second_node_name = node_c_name

			if first_node_name == second_node_name then
				local craft_result = minetest.get_craft_result({method = "normal", width = 2, items = {first_node_name, first_node_name}})
				local item = craft_result.item:get_name()
				if not item then
					minetest.log("error", "ComboBlock craft failed for "..first_node_name.."!")
					return first_node_name
				end
				return item
			end

			if pla_tar[1] == "clicked" then
				first_node_name = node_c_name
				second_node_name = pla_tar[1]
			end

			local output = "comboblock:"..first_node_name:split(":")[2].."_onc_"..second_node_name:split(":")[2]
			return output
		else
			minetest.chat_send_player(placer:get_player_name(), pla_tar.err)
		end
	end

	------------------------
	-- Comboblock Raycast --
	------------------------
	local function combo_raycast(placer)
	-- calculation of eye position ripped from builtins 'pointed_thing_to_face_pos'
		local placer_pos = placer:get_pos()
		local eye_height = placer:get_properties().eye_height
		local eye_offset = placer:get_eye_offset()
		placer_pos.y = placer_pos.y + eye_height
		placer_pos = vector.add(placer_pos, eye_offset)

		-- get wielded item range 5 is engine default
		-- order tool/item range >> hand_range >> fallback 5
		local tool_range = placer:get_wielded_item():get_definition().range or nil
		local hand_range
			for key, val in pairs(minetest.registered_items) do
				if key == "" then
					hand_range = val.range or nil
				end
			end
		local wield_range = tool_range or hand_range or 5

		-- determine ray end position
		local look_dir = placer:get_look_dir()
		look_dir = vector.multiply(look_dir, wield_range)
		local end_pos = vector.add(look_dir, placer_pos)

		-- get pointed_thing
		local ray = {}
		local ray = minetest.raycast(placer_pos, end_pos, false, false)
		local ray_pt = ray:next()

		return ray_pt
	end

	--------------------------
	-- Comboblock Give Drop --
	--------------------------
	function comboblock.give_drop(digger, item)
		if not creative.is_enabled_for(digger:get_player_name()) then
			local inv = digger:get_inventory()
			if inv:room_for_item("main", ItemStack(item.." ".. 1)) then
				inv:add_item("main", ItemStack(item.." ".. 1))
			else
				local pos = digger:get_pos()
				minetest.item_drop(ItemStack(item.." ".. 1), digger, pos)
			end
		end
	end

	--------------------
	-- After Dig Node --
	--------------------

	local function cb_after_dig_node(pos, oldnode, oldmetadata, digger)
		-- I know weird I put the node back but otherwise we cant raycast and get exact pos
		-- This avoids having to alter on_dig which is not recommended.
		minetest.swap_node(pos, {name = oldnode.name, param2 = oldnode.param2})

		local pointed = combo_raycast(digger)
		local point = vector.subtract(pointed.intersection_point,pointed.under)
		local normal = pointed.intersection_normal
		local nor_string = tostring(math.abs(normal.x)..math.abs(normal.y)..math.abs(normal.z))
		local exact_nor_string = tostring(normal.x..normal.y..normal.z)
		local v1 = minetest.registered_nodes[oldnode.name].comboblock_v1
		local v2 = minetest.registered_nodes[oldnode.name].comboblock_v2

		-- always lose this thread: https://forum.minetest.net/viewtopic.php?f=47&t=24188
		-- converts axis and param2 into useful values for removal/swap
		local comboblock_p2_axis = {
			["100"]  = {[0] = {"hb",22,0},[1] = {"vl",10,4 },[2] = {"vr",4 ,10},[3] = {"bb",13,13},[4] = {"bt",13,13},[5] = {"ht",0,22}, ["h"] = "z", ["v"] = "y"},  -- +X
			["-100"] = {[0] = {"hb",22,0},[1] = {"vl",10,4 },[2] = {"vr",4 ,10},[3] = {"bb",19,19},[4] = {"bt",19,19},[5] = {"ht",0,22}, ["h"] = "z", ["v"] = "y"},  -- -X
			["010"]  = {[0] = {"bb",22,0},[1] = {"vl",10,4 },[2] = {"vr",4 ,10},[3] = {"hb",19,13},[4] = {"ht",13,19},[5] = {"bt",0,22}, ["h"] = "z", ["v"] = "x"},  -- +Y
			["0-10"] = {[0] = {"bb",22,0},[1] = {"vl",10,4 },[2] = {"vr",4 ,10},[3] = {"hb",19,13},[4] = {"ht",13,19},[5] = {"bt",0,22}, ["h"] = "z", ["v"] = "x"},  -- -Y
			["001"]  = {[0] = {"hb",22,0},[1] = {"bb",4 ,4 },[2] = {"bt",4 ,4 },[3] = {"vl",19,13},[4] = {"vr",13,19},[5] = {"ht",0,22}, ["h"] = "x", ["v"] = "y"},  -- +Z
			["00-1"] = {[0] = {"hb",22,0},[1] = {"bb",10,10},[2] = {"bt",10,10},[3] = {"vl",19,13},[4] = {"vr",13,19},[5] = {"ht",0,22}, ["h"] = "x", ["v"] = "y"}}  -- -Z

		local p2_axis = math.floor(oldnode.param2/4)
		local outcome = comboblock_p2_axis[exact_nor_string][p2_axis][1]
		local o_p2_v1 = comboblock_p2_axis[exact_nor_string][p2_axis][2]
		local o_p2_v2 = comboblock_p2_axis[exact_nor_string][p2_axis][3]

		local hor = comboblock_p2_axis[exact_nor_string]["h"]
		local ver = comboblock_p2_axis[exact_nor_string]["v"]


		-- v1 is always top half v2 is always bottom half - reverse of expected.
		-- Using swap to minimise accidental callback triggering
		if outcome == "hb" then
			if point[ver] >= 0 then
				minetest.swap_node(pos, {name = v2, param2 = o_p2_v2})
				comboblock.give_drop(digger, v1)
			else
				minetest.swap_node(pos, {name = v1, param2 = o_p2_v1})
				comboblock.give_drop(digger, v2)
			end

		elseif outcome == "ht" then
			if point[ver] >= 0 then
				minetest.swap_node(pos, {name = v1, param2 = o_p2_v1})
				comboblock.give_drop(digger, v2)
			else
				minetest.swap_node(pos, {name = v2, param2 = o_p2_v2})
				comboblock.give_drop(digger, v1)
			end

		elseif outcome == "vl" then
			if point[hor] >= 0 then
				minetest.swap_node(pos, {name = v2, param2 = o_p2_v2})
				comboblock.give_drop(digger, v1)
			else
				minetest.swap_node(pos, {name = v1, param2 = o_p2_v1})
				comboblock.give_drop(digger, v2)
			end

		elseif outcome == "vr" then
			if point[hor] >= 0 then
				minetest.swap_node(pos, {name = v1, param2 = o_p2_v1 })
				comboblock.give_drop(digger, v2)
			else
				minetest.swap_node(pos, {name = v2, param2 = o_p2_v2 })
				comboblock.give_drop(digger, v1)
			end

		elseif outcome == "bb" then
			if tonumber(exact_nor_string) == nil or
			   tonumber(exact_nor_string) < 0 then
				minetest.swap_node(pos, {name = v1, param2 =  o_p2_v1 })
				comboblock.give_drop(digger, v2)
			else
				minetest.swap_node(pos, {name = v2, param2 =  o_p2_v2 })
				comboblock.give_drop(digger, v1)
			end

		elseif outcome == "bt" then
			if tonumber(exact_nor_string) == nil or
			   tonumber(exact_nor_string) < 0 then
				minetest.swap_node(pos, {name = v2, param2 =  o_p2_v2})
				comboblock.give_drop(digger, v1)
			else
				minetest.swap_node(pos, {name = v1, param2 =  o_p2_v1 })
				comboblock.give_drop(digger, v2)
			end
		else
			local name = digger:get_player_name()
			minetest.chat_send_player(name ,"Hmm...something has gone wrong, everything has crumbled!?!")
			minetest.swap_node(pos, {name = "air"})
		end
	end

	-----------------------
	-- Comboblock Switch --
	-----------------------

	--[[
	local function cb_on_punch(pos, node, puncher, pointed_thing)
		if puncher and puncher:is_player() then
			local player_name = puncher:get_player_name()
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			local controls = puncher:get_player_control()
			if not controls.aux1 then
				return -- Aux1 must be pressed
			end
		end
		local old_name = node.name
		local ndef = minetest.registered_nodes[old_name]
		if not ndef or not ndef.comboblock_v1 or not ndef.comboblock_v2 then
			-- probably not a comboblock node
			return
		end
		node.name = "comboblock:"..ndef.comboblock_v2:split(":")[2].."_onc_"..ndef.comboblock_v1:split(":")[2]
		if not minetest.registered_nodes[node.name] then
			minetest.log("warning", "cb_on_punch() should set node "..old_name.." at "..minetest.pos_to_string(pos).." to "..node.name..", but it's an unknown node!")
			return
		end
		minetest.set_node(pos, node)
	end
	]]

----------------------------
--       Main Code        --
----------------------------

-- moreblocks code part borrowed from Linuxdirk MT forums
-- Im directly updating these on the fly not using override_item
-- Not the best practice and maybe slower - review later

local mblocks = minetest.get_modpath("moreblocks")                  -- used to establish if moreblocks is loaded

	if mblocks ~= nil then
	minetest.debug("moreblocks present")

		for name, def in pairs(minetest.registered_nodes) do
			 local slab_name = string.sub (def.description, -6)
			if slab_name == "(8/16)" then                           -- The only way Ive found of identifying moreblocks half slabs
				def.groups.slab = 1                                 -- Add any slabs in moreblocks that are 8/16 to the slab group

				for index,_ in pairs (def.tiles)do                  -- Part borrowed from Linuxdirk
					if type(def.tiles[index]) == 'table' then
						def.tiles[index].align_style = 'world'
					else
						def.tiles[index] = {
							name = def.tiles[index],
							align_style = 'world'
										  }
					end
				end
			end
		end
	end

-- creates an index of any node name in the group "slab"
local slab_index = {}
local get_item_group = minetest.get_item_group

for name, _ in pairs(minetest.registered_nodes) do
	if get_item_group(name, "slab") == 8 then
		table.insert(slab_index, name)
		node_count = #slab_index
	end
end

-- Calculate max permutations, this over estimates as we
-- don't mix glass and non-glass - in-built error margin
local max_perm = #slab_index*(#slab_index-1)
local existing_node_count = node_count

for _,v1 in pairs(slab_index) do

	-- set from v2_tiles node registration count
	if to_many_nodes then
		break

	else
		local v1_def = minetest.registered_nodes[v1]                 -- Makes a copy of the relevant node settings
		local v1_groups = ch_core.assembly_groups({}, {comboblock = 1}, v1_def.groups, groups_to_inherit)
		local v1_tiles = preprocess_tiles(v1_def.tiles)              -- v1 tiles table
		-- v1_groups.not_in_creative_inventory = nil
		-- v1_groups.slab = nil
		-- v1_groups.comboblock = 1
		local v1_description = v1_def.description or ""

		for i = 2, 6, 1 do 											 -- Checks for image names for each side, If not image name
			if not v1_tiles[i] then									 -- then copy previous image name in: 1 = Top, 2 = Bottom, 3-6 = Sides
				v1_tiles[i] = v1_tiles[i-1]
			elseif mblocks ~= nil and i >= 5 then
				v1_tiles[i].name = v1_tiles[i].name:gsub("%^%[transformR90", "")  -- v1 R90 not needed as applied at V2 stage needed for moreblocks
			end
		end


		for _,v2 in pairs(slab_index) do							  -- every slab has to be done with every other slab including itself

			--[[ if node_count > 32668 then                                -- Prevent registering more than the max 32768 - limit set 100 less than max
				minetest.debug("WARNING:Comboblock - Max nodes"..
				" registered: "..(max_perm+existing_node_count)-node_count..
				" slab combos not registered")
				to_many_nodes = true                                  -- Outer loop break trigger
				break

			else ]]

				local v2_def = minetest.registered_nodes[v2]       -- this creates a second copy of all slabs and is identical to v1

				-- Register nodes --

				-- Very strange behaviour with orginal mod when placing glass and normal slabs ontop of each other.
				-- Removed the ability to place glass slabs on non-glass slabs.
				-- Original Behaviour summary:
				-- Normal slab on glass slab - slab appears as top slab with some strange graphic overlay, Unknown why - guess drawtype conflict with graphic
				-- Glass slab on normal slab - slab appears as top glass slab ie full glass block, Unknown why - guess drawtype conflict with graphic
				-- For example of above place "glass" slab on "obsidian glass" slab and vice versa this seemed minimal issue so left this combo okay
				-- Glass slab on Glass slab - black box inside this is due to orginal code having drawtype = normal for glassslab on glassslab combo

				local v1_is_glass = string.find(string.lower(tostring(v1)), "glass")                          -- Slabs dont use drawtype "glasslike" in stairs due to nodebox requirement,
				local v2_is_glass = string.find(string.lower(tostring(v2)), "glass")                          -- so using name string match but this pretty unreliable.
																											  -- returns value nil if not otherwise returns integar see lua string.find

				local combo_name = "comboblock:"..v1:split(":")[2].."_onc_"..v2:split(":")[2]
				local allowed_combo_index, allowed_combo_index_suffix, allowed_combo
				allowed_combo_index = allowed_combos[v1.."+"..v2]
				if allowed_combo_index then
					allowed_combo_index_suffix = "A"
					allowed_combo = assert(combos[allowed_combo_index])
					local ss_nodes = shape_selector_groups[v1.."+"..v2].nodes
					ss_nodes[1] = combo_name
					ss_nodes[3] = {name = v1, oneway = true}
					ss_nodes[4] = {name = v2, oneway = true}
				else
					allowed_combo_index = allowed_combos[v2.."+"..v1]
					if allowed_combo_index then
						allowed_combo_index_suffix = "B"
						allowed_combo = assert(combos[allowed_combo_index])
						local ss_nodes = shape_selector_groups[v2.."+"..v1].nodes
						ss_nodes[2] = combo_name
						ss_nodes[3] = {name = v2, oneway = true}
						ss_nodes[4] = {name = v1, oneway = true}
					end
				end
				local ts, v2_tiles
				if allowed_combo ~= nil then
					ts = allowed_combo.ts
					v2_tiles = preprocess_tiles_v2(v2_def.tiles, ts)
				end
				if not allowed_combo_index then
					-- not allowed
				elseif v1_is_glass and v2_is_glass then                                                           -- glass_glass nodes so drawtype = glasslike
						local combo_tiles = {
							v1_tiles[1].name.."^[resize:"..ts.."x"..ts,
							v2_tiles[2].name.."^[resize:"..ts.."x"..ts,
							v1_tiles[3].name.."^[resize:"..ts.."x"..ts..v2_tiles[3].name,                      -- Stairs registers it's tiles slightly differently now
							v1_tiles[4].name.."^[resize:"..ts.."x"..ts..v2_tiles[4].name,                      -- in a nested table structure and now makes use of
							v1_tiles[5].name.."^[resize:"..ts.."x"..ts..v2_tiles[5].name,                      -- align_style = "world" for most slabs....I think
							v1_tiles[6].name.."^[resize:"..ts.."x"..ts..v2_tiles[6].name
						}
						minetest.register_node(combo_name, {  -- registering the new combo node
							description = string.format("%02d", allowed_combo_index).." "..preprocess_description(v1).." na "..preprocess_description(v2),
							_ch_help = ch_help,
							_ch_help_group = ch_help_group,
							tiles = combo_tiles,
							paramtype = "light",
							paramtype2 = "facedir",
							drawtype = "glasslike",
							sounds = v1_def.sounds,
							groups = v1_groups,
							drop = {
								items = {
									{items = {tostring(v1), tostring(v2)}},
								},
							},
							-- on_punch = cb_on_punch,
							comboblock_v1 = tostring(v1),
							comboblock_v2 = tostring(v2)})

						minetest.register_craft({
							output = tostring(v1),
							recipe = {{combo_name}},
							replacements = {{combo_name, tostring(v2)}},
						})
						minetest.register_craft({
							output = combo_name,
							recipe = {
								{tostring(v1), ""},
								{tostring(v2), ""},
							},
						})

				elseif not v1_is_glass and not v2_is_glass then -- normal nodes
						local combo_tiles = {v1_tiles[1].name.."^[resize:"..ts.."x"..ts,
							v2_tiles[2].name.."^[resize:"..ts.."x"..ts,
							v1_tiles[3].name.."^[resize:"..ts.."x"..ts..v2_tiles[3].name,						-- Stairs registers it's tiles slightly differently now
							v1_tiles[4].name.."^[resize:"..ts.."x"..ts..v2_tiles[4].name,						-- in a nested table structure and now makes use of
							v1_tiles[5].name.."^[resize:"..ts.."x"..ts..v2_tiles[5].name,						-- align_style = "world" for most slabs....I think
							v1_tiles[6].name.."^[resize:"..ts.."x"..ts..v2_tiles[6].name
						}
						minetest.register_node(combo_name, {
							description = string.format("%02d", allowed_combo_index).." "..preprocess_description(v1).." na "..preprocess_description(v2),
							_ch_help = ch_help,
							_ch_help_group = ch_help_group,
							tiles = combo_tiles,
							paramtype2 = "facedir",
							drawtype = "normal",
							sounds = v1_def.sounds,
							groups = v1_groups,
							drop = {
								items = {
									{items = {tostring(v1), tostring(v2)}},
								},
							},
							-- on_punch = cb_on_punch,
							comboblock_v1 = tostring(v1),
							comboblock_v2 = tostring(v2)})
						minetest.register_craft({output = tostring(v1), recipe = {{combo_name}}, replacements = {{combo_name, tostring(v2)}}})
						minetest.register_craft({output = combo_name, recipe = {{tostring(v1), ""}, {tostring(v2), ""}}})
				else
					-- Can't have a nodetype as half "glasslike" and half "normal" :(
				end

				node_count = node_count+1
			-- end
		end-- v2_tiles for end


	-- Override all slabs registered on_place function

		minetest.override_item(v1, {

			on_place = function(itemstack, placer, pointed_thing)
						local pos = pointed_thing.under
						local placer_pos = placer:get_pos()
						local err_mix = S("Hmmmm... that wont work I can't mix glass slabs and none glass slabs")-- error txt for mixing glass/not glass
						local err_un = S("Hmmmm... The slab wont fit there, somethings in the way")              -- error txt for unknown/unexpected
						local err_nex = S("Hmmm... This combination does not exist")
						local pla = tostring(itemstack:get_name())
						local pla_is_glass = string.find(string.lower(pla), "glass")  -- itemstack item glass slab (trying to place item) - cant use drawtype as slabs are all type = nodebox
						local node_c = minetest.get_node(pos)                            -- node clicked
						local node_c_is_glass = string.find(string.lower(tostring(node_c.name)), "glass")        -- is node clicked glass
						local allowed_combo_index = allowed_combos[node_c.name.."+"..pla] or allowed_combos[pla.."+"..node_c.name]

						if not allowed_combo_index and node_c.name == pla then
							allowed_combo_index = 0
						end

				-- Setup Truth table
				local pgn = "F"  -- Place is_Glass Node
				local cgn = "F"  -- Click is_Glass Node

				-- Check truth table variables and switch "T"
				if pla_is_glass then pgn = "T" end
				if node_c_is_glass then cgn = "T" end

				local comboblock_truthtable_rel_axis_horiz = {
				-- User clicked top/bottom surface slab and slab is Horizontal
				-- Place Glass, Click Glass
				-- [    T     ,       T   ] - top record table key spaced out
				["TT"] = {itemstack:get_name(), "clicked"},				   	-- New: Outcome Two
				["TF"] = {err = err_mix},                                 	-- New: Error Two
				["FT"] = {err = err_mix},                               	-- New: Error One
				["FF"] = {itemstack:get_name(), "clicked"}} 			  	-- New: Outcome One

				-- Used to identify potential half slab deep axis
				local  comboblock_param_side_offset = {
			  --xyz -- 1st axis = face dir, 2nd two used for placement
				["100"] = {"x","y","z"},
				["010"] = {"y","x","z"},
				["001"] = {"z","y","x"}}

				local comboblock_p2_axis = {
				["100"]  = {l = 4, r = 10, t = 22, b = 0, m = 15},  -- +X
				["-100"] = {l = 10, r = 4, t = 22, b = 0, m = 17},  -- -X
				["010"]  = {l = 4, r = 10, t = 19, b = 13, m = 0},  -- +Y
				["0-10"] = {l = 10, r = 4, t = 19, b = 13, m = 22}, -- -Y
				["001"]  = {l = 13, r = 19, t = 22, b = 0, m = 6},  -- +Z
				["00-1"] = {l = 19, r = 13, t = 22, b = 0, m = 8}}  -- -Z


				-- clicked side for slabs can either be on node boundry or sunk in half
				-- node depth. Need to identify the clicked side and later check if it's
				-- == 0 or not. Doing slabs this way means remaining code can effectively ignore
				-- axis and param2 except for final placement.
				local pointed = combo_raycast(placer)
				local point, normal
				if pointed ~= nil then
					point = vector.subtract(pointed.intersection_point,pointed.under)
					normal = pointed.intersection_normal
				else
					minetest.log("warning", "Raycast failed for "..placer:get_player_name().." at "..minetest.pos_to_string(placer:get_pos()).."!")
					point = pointed_thing.under
					normal = vector.normalize(vector.subtract(pointed_thing.above, pointed_thing.under))
				end
				local nor_string = tostring(math.abs(normal.x)..math.abs(normal.y)..math.abs(normal.z))
				local pot_short_axis = point[comboblock_param_side_offset[nor_string][1]]                   -- When == 0 large flat side is inside node
				local node_ax_pos     = vector.add(pos,normal)
				local node_along_axis = minetest.get_node(node_ax_pos)                        				-- retrieve the node along +- axis for xyz
				local node_ax_is_slab = minetest.get_item_group(node_along_axis.name, "slab") == 8		-- node along axis is a 8/16 slab
				local node_ax_is_build = minetest.registered_nodes[node_along_axis.name].buildable_to       -- true/false
				local node_ax_is_glass = string.find(string.lower(tostring(node_along_axis.name)), "glass") -- is node glass
				local is_prot = minetest.is_protected(pos,placer:get_player_name())
				
				if pot_short_axis == 0 and not is_prot then																	-- Clicked inside existing node with slab
					local outcome
					if allowed_combo_index then
						outcome = comboblock_truthtable_rel_axis_horiz[pgn..cgn]
					else
						outcome = {err = err_nex}
					end

					if outcome.err == nil then 																-- Cant mix glass and normal slabs
						local combo_name = cb_get_name(outcome,placer,node_c.name)
						minetest.swap_node(pos,{name=combo_name, param2=node_c.param2})
						itemstack:take_item(1)
					end

				elseif node_ax_is_build then																-- Clicked surface and node along axis is_buildable
					local hor = comboblock_param_side_offset[nor_string][3]
					local ver = comboblock_param_side_offset[nor_string][2]

					-- Switchs left/right when -/+ axis face clicked
					local multi = normal[comboblock_param_side_offset[nor_string][1]]
					local p2 = 0

					-- top(t)/bot(b)/left(l)/right(r) are fairly meaningless just labels - align on X
					if math.abs(point[hor]) < 0.25 and math.abs(point[ver]) < 0.25 then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["m"]

					elseif multi*point[hor] >= math.abs(point[ver]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["r"]

					elseif multi*-point[hor] >= math.abs(point[ver]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["l"]

					elseif point[ver] >= math.abs(point[hor]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["t"]

					elseif -point[ver] >= math.abs(point[hor]) then
						p2 = comboblock_p2_axis[tostring(normal.x..normal.y..normal.z)]["b"]

					end

					minetest.item_place(itemstack, placer, pointed_thing, p2)

				elseif node_ax_is_slab and not is_prot then																    -- Clicked surface and node along axis is_slab
					-- use node_along_axis instead of node clicked
					-- recalc our clicked glass node true/false using node_along_axis as sub
					if node_ax_is_glass then cgn = "T" end

					-- same process as our 1st if now but sub in node_along_axis details
					local outcome
					if allowed_combo_index then
						outcome = comboblock_truthtable_rel_axis_horiz[pgn..cgn]
					else
						outcome = {err = err_nex}
					end

					if outcome.err == nil then 																-- Cant mix glass and normal slabs
						local combo_name = cb_get_name(outcome,placer,node_along_axis.name)
						minetest.swap_node(node_ax_pos,{name=combo_name, param2=node_along_axis.param2})
						itemstack:take_item(1)
					end

				else													-- Last error catch
					local name = placer:get_player_name()
					minetest.chat_send_player(name ,err_un)     		-- New:Unknown Case

				end

			if not creative.is_enabled_for(placer:get_player_name()) then
				return itemstack
			end
		end })
	end
end

for _, group in pairs(shape_selector_groups) do
	if group.nodes[3] ~= nil then
		ch_core.register_shape_selector_group(group)
	end
end

ch_base.close_mod(minetest.get_current_modname())
