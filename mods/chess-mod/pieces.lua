local colors = chess.colors

local figures = {
	pawn = {
		mesh = "chess_pawn.obj",
		description = "ý pěšec",
		abbr = "",
		box = {type = "fixed", fixed = {-0.184059, -0.500000, -0.184059, 0.184059, 0.670019, 0.184059}},
	},
	rook = {
		mesh = "chess_rook.obj",
		description = "á věž",
		abbr = "V",
		box = {type = "fixed", fixed = {-0.24, -0.500000, -0.245412, 0.24, 0.891890, 0.245412}},
	},
	knight = {
		mesh = "chess_knight.obj",
		description = "ý jezdec",
		abbr = "J",
		box = {type = "fixed", fixed = {-0.234362, -0.500000, -0.239197, 0.234362, 0.943670, 0.234362}},
	},
	bishop = {
		mesh = "chess_bishop.obj",
		description = "ý střelec",
		abbr = "S",
		box = {type = "fixed", fixed = {-0.242909, -0.500000, -0.242908, 0.242909, 1.270763, 0.242909}},
	},
	queen = {
		mesh = "chess_queen.obj",
		description = "á dáma",
		abbr = "D",
		box = {type = "fixed", fixed = {-0.24153, -0.504964, -0.241529, 0.24153, 1.919890, 0.24153}},
	},
	king = {
		mesh = "chess_king.obj",
		description = "ý král",
		abbr = "K",
		box = {type = "fixed", fixed = {-0.266521, -0.505478, -0.266521, 0.266521, 1.451586, 0.266521}},
	},
}

local function find_chess_spawn(figure_pos)
	local pos_under = vector.offset(figure_pos, 0, -1, 0)
	local node_under = minetest.get_node(pos_under)
	if node_under.name == "chess:board_white" or node_under.name == "chess:board_black" then
		local meta = minetest.get_meta(pos_under)
		local spawn_pos = vector.offset(figure_pos, -meta:get_int("chess_offset_x"), -1, -meta:get_int("chess_offset_z"))
		local node = minetest.get_node(spawn_pos)
		if node.name == "chess:spawn" then
			return spawn_pos
		end
	end
end

local function get_field_description(spawn_pos, figure_pos)
	local letter = chess.letters[figure_pos.x - spawn_pos.x]
	local digit = figure_pos.z - spawn_pos.z
	local result
	if letter ~= nil and 1 <= digit and digit <= 8 then
		result = letter..digit
	end
	return result
end

local function process_figure_changed(spawn_pos, figure_pos, old_figure_node, new_figure_node, player)
	if spawn_pos == nil or (old_figure_node == nil and new_figure_node == nil) then
		return
	end
	local meta = minetest.get_meta(spawn_pos)
	local fdesc = get_field_description(spawn_pos, figure_pos) or "??"
	local color, figure, abbr, message
	if old_figure_node == nil then
		local nfndef = minetest.registered_nodes[new_figure_node.name]
		local figure = nfndef._chess_figure
		abbr = figures[figure].abbr
		color = nfndef._chess_color
		-- figurka byla umístěna
		-- minetest.log("action", "Figure "..color.." "..figure.." placed at "..fdesc)
		local last_abbr, last_pos = meta:get_string(color.."_last_type"), meta:get_string(color.."_last_pos")
		if last_pos == "" then
			-- předchozí pozice neznámá
			message = abbr.."??-"..fdesc
		elseif last_pos == fdesc then
			message = nil -- pozice se nezměnila => neoznamovat
		elseif last_abbr == figures[figure].abbr then
			-- stejný typ
			message = last_abbr..last_pos.."-"..fdesc
		else
			-- rozdílný typ
			message = last_abbr..last_pos.."-"..abbr..fdesc
		end
	elseif new_figure_node == nil then
		local ofndef = minetest.registered_nodes[old_figure_node.name]
		color, figure = ofndef._chess_color, ofndef._chess_figure
		abbr = figures[figure].abbr
		-- figurka byla vzata bez náhrady (do ruky)
		-- minetest.log("action", "Figure "..ofndef._chess_color.." "..ofndef._chess_figure.." dug at "..fdesc)
		meta:set_string(color.."_last_type", abbr)
		meta:set_string(color.."_last_pos", fdesc)
		message = abbr..fdesc.."-..."
	else
		local ofndef = minetest.registered_nodes[old_figure_node.name]
		local nfndef = minetest.registered_nodes[new_figure_node.name]
		color = nfndef._chess_color
		local nlastabbr = meta:get_string(color.."_last_type")
		local nlastpos = meta:get_string(color.."_last_pos")
		-- figurka byla vzata jinou figurkou
		-- minetest.log("action", "Figure "..ofndef._chess_color.." "..ofndef._chess_figure.." replaced at "..fdesc.." by "..nfndef._chess_color.." "..nfndef._chess_figure)
		local nabbr = figures[nfndef._chess_figure].abbr
		local oabbr = figures[ofndef._chess_figure].abbr
		if nlastpos == "" then
			-- předchozí pozice neznámá
			message = nabbr.."??x"..fdesc
		elseif nlastabbr == nabbr then
			message = nabbr..nlastpos.."x"..fdesc
		else
			message = nlastabbr..nlastpos.."->"..nabbr.."x"..fdesc
		end
	end

	if message ~= nil then
		local tah = meta:get_int("tah")
		if color == "white" then
			tah = tah + 1
			meta:set_int("tah", tah)
			message = tah..". "..message
		elseif color == "black" then
			message = tah..". ... "..message
		else
			message = tah..". *** "..message
		end
		minetest.log("action", minetest.pos_to_string(spawn_pos).." "..message)

		for _, player2 in pairs(minetest.get_connected_players()) do
			local player_pos = player2:get_pos()
			if spawn_pos.x - 10 <= player_pos.x and player_pos.x <= spawn_pos.x + 20
				and spawn_pos.y - 5 <= player_pos.y and player_pos.y <= spawn_pos.y + 5
				and spawn_pos.z - 10 <= player_pos.z and player_pos.z <= spawn_pos.z + 20 then
				ch_core.systemovy_kanal(player2:get_player_name(), message)
			end
		end
	end
end

local figure_replacements = {}

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	if digger == nil or not digger:is_player() then
		return
	end
	local spawn_pos = find_chess_spawn(pos)
	if spawn_pos == nil then
		return
	end
	local wielded_item = digger:get_wielded_item()
	if not wielded_item:is_empty() then
		local item_name = wielded_item:get_name()
		if minetest.get_item_group(item_name, "chess_figure") > 0 and item_name ~= oldnode.name then
			-- dug by another figure => place it
			local pos_hash = minetest.hash_node_position(pos)
			figure_replacements[pos_hash] = {
				oldnode = oldnode,
			}
			local leftover = minetest.item_place(wielded_item, digger, {type = "node", under = vector.offset(pos, 0, -1, 0), above = pos})
			if leftover ~= nil then
				digger:set_wielded_item(leftover)
			end
			local new_node = minetest.get_node(pos)
			if figure_replacements[pos_hash] == nil then
				return -- successfully exchanged
			end
			figure_replacements[pos_hash] = nil -- placement failed
		end
	end
	process_figure_changed(spawn_pos, pos, oldnode, nil, digger)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	if placer == nil or not placer:is_player() then
		return
	end
	local spawn_pos = find_chess_spawn(pos)
	if spawn_pos == nil then
		return
	end
	local pos_hash = minetest.hash_node_position(pos)
	local oldnode
	if figure_replacements[pos_hash] ~= nil then
		oldnode = figure_replacements[pos_hash].oldnode
		figure_replacements[pos_hash] = nil
	end
	process_figure_changed(spawn_pos, pos, oldnode, minetest.get_node(pos), placer)
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef ~= nil then
		meta:set_string("infotext", ndef.description)
	end
end

local function on_secondary_use(itemstack, user, pointed_thing)
	itemstack:take_item()
	return itemstack
end

local _ch_help = "Šachové figury vznikají z ničeho při postavení nebo resetu šachovnice.\nLze je vzít do inventáře levým klikem a položit pravým klikem (i mimo šachovnici).\nBraní se dělá tak, že vezmete do ruky figuru, kterou chcete brát, a levým klikem vytěžíte branou figuru.\nDržená figura se umístí na šachovnici namísto vzaté.\nNepotřebné figury se můžete zbavit pravým klikem do vzduchu.\nNové figury získáte po vyresetování šachovnice nebo je lze vykouzlit.\nPěšce lze proměnit v jinou figuru přes výrobní mřížku (viz knihu receptů)."
local _ch_help_group = "chess_figure"

for color_name, color_def in pairs(colors) do
	for figure_name, figure_def in pairs(figures) do
		local groups = {
			snappy = 3,
			chess_figure = 1,
			oddly_breakable_by_hand = 3,
		}
		groups["chess_figure_"..color_name] = 1
		groups["chess_figure_"..figure_name] = 1
		local def = {
			description = color_def.description..figure_def.description,
			drawtype = "mesh",
			mesh = figure_def.mesh,
			tiles = {{name = color_def.texture, backface_culling = true}},
			selection_box = figure_def.box,
			collision_box = figure_def.box,
			sunlight_propagates = true,
			paramtype = "light",
			paramtype2 = "facedir",
			place_param2 = color_def.place_param2,
			-- light_source = 6,
			groups = groups,
			sounds = default.node_sound_wood_defaults(),
			_chess_color = color_name,
			_chess_figure = figure_name,
			_ch_help = _ch_help,
			_ch_help_group = _ch_help_group,

			on_construct = on_construct,
			on_secondary_use = on_secondary_use,
			after_dig_node = after_dig_node,
			after_place_node = after_place_node,
		}
		minetest.register_node("chess:"..figure_name.."_"..color_name, def)
	end
end
