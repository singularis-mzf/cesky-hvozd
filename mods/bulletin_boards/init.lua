-- TODO:
-- There's potential race conditions in here if two players have the board open
-- and a culling happens or they otherwise diddle around with it. For now just
-- make sure it doesn't crash

local F = minetest.formspec_escape
local S = minetest.get_translator(minetest.get_current_modname())

--[[
Formát příspěvků:
	{
		owner = player_name,
		title = string,
		text = string,
		icon = int (0..7),
		timestamp = minetest.get_gametime(),
		date = string ("24. 12."),
		valid_until = string("2025-12-31"),
	}
Příspěvky jsou řazeny od nejstaršího a číslovány od 1;
zobrazují se od nejnovějšího, číslování od 1.
]]

local bulletin_max = 56
local validity_max = 2999
local max_text_size = 5000 -- half a book
local max_title_size = 120

local date_color = "#cccccc"
local player_name_color = "#66cc66"
local title_color = "#ffffff"

local bulletin_boards = {
	board_def = {},
	global_boards = {},
	global_boards_metadata = {},
	player_state = {},
}

-- default icon set
local base_icons = {
	"bulletin_boards_document_comment_above.png",
	"bulletin_boards_document_back.png",
	"bulletin_boards_document_next.png",
	"bulletin_boards_document_image.png",
	"bulletin_boards_document_signature.png",
	"bulletin_boards_to_do_list.png",
	"bulletin_boards_documents_email.png",
	"bulletin_boards_receipt_invoice.png",
}

local boards_colors = {0, 176, 152, 72, 128, 144, 248, 16, 232, 112, 96, 184, 136, 216, 40, 224, 160, 8, 168, 120, 192, 104, 200, 88, 32, 24, 80, 64, 240, 48, 208, 56}

local path = minetest.get_worldpath() .. "/bulletin_boards.lua"
local f, e = loadfile(path);
if f then
	local serialized_data = f()
	if serialized_data.global_boards ~= nil then
		bulletin_boards.global_boards = serialized_data.global_boards
		bulletin_boards.global_boards_metadata = serialized_data.global_boards_metadata
	end
end

local function get_current_date()
	local cas = ch_core.aktualni_cas()
	local dfmt = "%04d-%02d-%02d"
	return dfmt:format(cas.rok, cas.mesic, cas.den)
end

local function get_date_after_n_days(n)
	local dfmt = "%04d-%02d-%02d"
	local cas = ch_core.aktualni_cas()
	local ch_date = dfmt:format(cas.rok, cas.mesic, cas.den)
	local tm = os.time()
	local t = os.date("!*t", tm)
	local date = dfmt:format(t.year, t.month, t.day)
	local shifts_minus, shifts_plus = 0, 0
	while date < ch_date do
		tm = tm - 12 * 3600
		t = os.date("!*t", tm)
		date = dfmt:format(t.year, t.month, t.day)
		shifts_minus = shifts_minus + 1
	end
	while date > ch_date do
		tm = tm + 12 * 3600
		t = os.date("!*t", tm)
		date = dfmt:format(t.year, t.month, t.day)
		shifts_plus = shifts_plus + 1
	end
	if shifts_minus > 0 or shifts_plus > 0 then
		minetest.log("warning", "[bulletin_boards] get_date_after_n_days() had to do shifts: minus="..shifts_minus..", plus="..shifts_plus)
	end
	tm = tm + 86400 * n
	t = os.date("!*t", tm)
	return dfmt:format(t.year, t.month, t.day)
end

local function save_boards()
	local file, e = io.open(path, "w");
	if not file then
		return error(e);
	end
	local data_to_serialize = {
		global_boards = bulletin_boards.global_boards,
		global_boards_metadata = bulletin_boards.global_boards_metadata,
	}
	file:write(minetest.serialize(data_to_serialize))
	file:close()
end

-- gets the bulletins currently on a board
-- and other persisted data
local function get_board(name)
	local board, metadata
	board, metadata = bulletin_boards.global_boards[name], bulletin_boards.global_boards_metadata[name]
	if board == nil then
		board, metadata = {}, {color_index = 0, update_timestamp = 0}
		bulletin_boards.global_boards[name] = board
		bulletin_boards.global_boards_metadata[name] = metadata
	end
	return board, metadata
	-- board.last_culled = minetest.get_gametime()
end

local function collect_garbage(board_name)
	local board, metadata = get_board(board_name)
	local stack = {}
	local datum = tostring(get_current_date())
	local old_size = #board
	for i = old_size, 1, -1 do
		local bulletin = board[i]
		if bulletin.valid_until == nil or bulletin.valid_until == "" or tostring(bulletin.valid_until) > datum then
			table.insert(stack, bulletin)
		else
			minetest.log("action", "Bulletin Boards Garbage Collector will remove a bulletin '"..(bulletin.title or "nil").."' by '"..(bulletin.owner or "nil").."' from "..board_name..", because its valid_until '"..tostring(bulletin.valid_until).."' was reached. (datum = "..datum..").")
		end
	end
	local board_i, stack_i = 1, math.min(#stack, bulletin_max)
	while board_i <= bulletin_max and stack_i >= 1 do
		board[board_i] = stack[stack_i]
		board_i = board_i + 1
		stack_i = stack_i - 1
	end
	for i = old_size, board_i, -1 do
		board[i] = nil
	end
	if #stack > bulletin_max then
		for i = bulletin_max + 1, #stack, 1 do
			local bulletin = stack[i]
			minetest.log("action", "Bulletin Boards Garbage Collector removed a bulletin '"..(bulletin.title or "nil").."' by '"..(bulletin.owner or "nil").."' from "..board_name..", because the maximum number of items in a board was reached. (old_size = "..old_size..").")
		end
	end
	local garbage_count = old_size - #board
	if garbage_count > 0 then
		minetest.log("action", "Board garbage collector collected "..garbage_count.." garbage items, "..#board.." items remain.")
		local timestamp = minetest.get_gametime()
		metadata.update_timestamp = timestamp
		save_boards()
	end
	return garbage_count
end

for k, board in pairs(bulletin_boards.global_boards) do
	collect_garbage(k)
end

local function get_infotext(board_name, board)
	local def = bulletin_boards.board_def[board_name] or {}
	local desc = def.desc or "nástěnka"
	local result = {desc}
	if #board > 0 then
		for i = #board, math.max(1, #board - 4), -1 do
			local bulletin = board[i]
			table.insert(result, bulletin.date.." "..ch_core.prihlasovaci_na_zobrazovaci(bulletin.owner)..": "..ch_core.utf8_truncate_right(bulletin.title, 80))
		end
	end
	if #result > 1 then
		return table.concat(result, "\n")
	else
		return desc
	end
end

local function update_board(pos, node)
	if minetest.get_item_group(node.name, "bulletin_board") == 0 then
		return false
	end
	local board, metadata = get_board(node.name)
	if metadata == nil then
		minetest.log("error", "[bulletin_boards] update_board() called for "..node.name.." at "..minetest.pos_to_string(pos)..", but the metadata was not found!")
		return false
	end
	local meta = minetest.get_meta(pos)
	local node_timestamp = meta:get_string("board_timestamp")
	if node_timestamp ~= "" then
		node_timestamp = tonumber(node_timestamp) or 0
	else
		node_timestamp = 0
	end
	if node_timestamp >= (metadata.update_timestamp or 0) then
		-- print("DEBUG: board "..node.name.." @ "..minetest.pos_to_string(pos).." is up to date (node_ts is "..node_timestamp..", metadata = "..dump2(metadata)..").")
		return true -- node is up to date
	end
	meta:set_string("infotext", get_infotext(node.name, board))
	meta:set_string("board_timestamp", tostring(metadata.update_timestamp))
	local dir = node.param2 % 8
	local color = node.param2 - dir
	local new_color = boards_colors[1 + (metadata.color_index % #boards_colors)]
	if new_color ~= color then
		node.param2 = dir + new_color
		minetest.swap_node(pos, node)
	end
	return true
end

--[[ for incrementing through the bulletins on a board
local function find_next(board, start_index)
	local index = start_index + 1
	while index ~= start_index do
		if board[index] then
			return index
		end
		index = index + 1
		if index > bulletin_max then
			index = 1
		end
	end
	return index
end
local function find_prev(board, start_index)
	local index = start_index - 1
	while index ~= start_index do
		if board[index] then
			return index
		end
		index = index - 1
		if index < 1 then
			index = bulletin_max
		end		
	end
	return index
end
]]

-- safe way to get the description string of an item, in case it's not registered
local function get_item_desc(stack)
	local stack_def = stack:get_definition()
	if stack_def then
		return stack_def.description
	end
	return stack:get_name()
end

-- shows the base board to a player
local function show_board(player_name, board_name)
	local player_role = ch_core.get_player_role(player_name)
	local board = get_board(board_name)
	local do_collect_garbage = true
	for pn, ps in pairs(bulletin_boards.player_state) do
		if pn ~= player_name and ps.board == board_name then
			do_collect_garbage = false -- someone else has openned the same board
			break
		end
	end
	if do_collect_garbage then
		collect_garbage(board_name)
	end
	local current_time = minetest.get_gametime()
		-- board[cull_index] = nil -- = how to remove a contribution

	local def = bulletin_boards.board_def[board_name]
	local desc = minetest.formspec_escape(def.desc)
	local tip
	if def.cost then
		local stack = ItemStack(def.cost)
		tip = S("Post your bulletin here for the cost of @1 @2", stack:get_count(), get_item_desc(stack))
		desc = desc .. S(", Cost: @1 @2", stack:get_count(), get_item_desc(stack))
	else
		tip = S("Post your bulletin here")
	end

	local formspec = {
		"formspec_version[5]"..
		"size[16,9]"..
		"item_image[0.2,0.2;1,1;"..F(board_name).."]"..
		"label[1.4,0.75;"..F(desc).."]",
	}
	if player_role ~= nil and player_role ~= "new" then
		table.insert(formspec, "button[10,0.25;5.75,1;pridat;přidat příspěvek]")
	end
	table.insert(formspec, "tablecolumns[image,0=ch_core_empty.png")
	for i, icon in ipairs(def.icons) do
		table.insert(formspec, ","..i.."="..F(icon))
	end
	-- local random_number = math.random(1, 1000000)
	table.insert(formspec,
		";color;text,align=center;color;text;color;text]"..
		"table[0.25,1.5;15.5,7;vyberclanku"..tostring(minetest.get_us_time())..";")

	local delimiter = ""
	for i = #board, 1, -1 do
		local bulletin = board[i]
		local icon = math.max(0, math.min(#def.icons, bulletin.icon))
		local title = bulletin.title
		local date = bulletin.date
		local owner = bulletin.owner
		local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner)
		table.insert(formspec, delimiter..icon..","..date_color..","..date..","..player_name_color..","..F(owner_viewname)..":,"..title_color..","..F(title))
		delimiter = ","
	end
	if delimiter == "" then
		-- empty board
		table.insert(formspec, "0") -- => empty icon
	end
	table.insert(formspec, ";]")
	bulletin_boards.player_state[player_name] = {board=board_name}
	minetest.show_formspec(player_name, "bulletin_boards:board", table.concat(formspec))
end

-- shows a specific bulletin on a board
local function show_bulletin(player, board_name, index)
	local board = get_board(board_name)
	local def = bulletin_boards.board_def[board_name]
	local icons = def.icons
	local bulletin = board[index] or {}
	local player_name = player:get_player_name()
	local player_role = ch_core.get_player_role(player_name)
	bulletin_boards.player_state[player_name] = {board=board_name, index=index}

	local tip
	local has_cost
	if def.cost and not minetest.is_creative_enabled(player_name) then
		local stack = ItemStack(def.cost)
		local player_inventory = minetest.get_inventory({type="player", name=player_name})
		tip = S("Post bulletin with this icon at the cost of @1 @2", stack:get_count(), get_item_desc(stack))
		has_cost = player_inventory:contains_item("main", stack)
	else
		tip = S("Post bulletin with this icon")
		has_cost = true
	end

	local days_ago
	if bulletin.timestamp then
		days_ago = math.floor((minetest.get_gametime() - bulletin.timestamp) / 86400)
	end

	local formspec = {
		"formspec_version[5]"..
		"size[11,11.25]",
	}
	if board[index] ~= nil then
		table.insert(formspec,
		"button[0.25,1.4;1.2,0.75;prev;"..S("Prev").."]"..
		"button[9.55,1.4;1.2,0.75;next;"..S("Next").."]")
	end
	if bulletin.owner == nil and player_role ~= "admin" and not has_cost then
		ch_core.systemovy_kanal(player_name, "K vyvěšení příspěvku vám chybí nástěnkou požadovaná platba!")
		bulletin_boards.player_state[player_name] = nil
		show_board(player_name, board_name)
		return
	elseif player_role == "admin" or
		(player_role ~= nil and player_role ~= "new" and has_cost and bulletin.owner == nil)
	then
		-- editing version of the formspec
		local validity = validity_max
		if bulletin.valid_until ~= nil then
			validity = F(bulletin.valid_until)
		end
		table.insert(formspec,
			"field[0.25,0.75;10.5,0.5;title;"..S("Title:")..";"..F(bulletin.title or "").."]"..
			"textarea[0.25,2.5;10.5,6.5;text;"..S("Contents:")..";"..F(bulletin.text or "").."]"..
			"label[1.75,1.75;"..S("Validity in days (1-@1):", validity_max).."]"..
			"field[5,1.5;1,0.5;platnost;;"..validity.."]"..
			"label[0.3,9.5;"..S("Post:")..(days_ago and " "..S("(posted @1 days ago)", days_ago) or "").."]")
		for i, icon in ipairs(icons) do
			table.insert(formspec,
				"image_button[".. i*1.1-0.75 ..",9.9;1,1;"..icon..";save_"..i..";]"..
				"tooltip[save_"..i..";"..tip.."]")
		end
		table.insert(formspec,
			"image_button["..(#icons+1)*1.1-0.75+0.5 ..",9.9;1,1;bulletin_boards_delete.png;delete;]"..
			"tooltip[delete;"..S("Delete this bulletin").."]"..
			"label["..(#icons+1)*1.1-0.75+0.5 ..",9.7;"..S("Delete:").."]")

	elseif bulletin.owner then
		-- non-editing version
		table.insert(formspec, "tablecolumns[image,0=ch_core_empty.png")
		for i, icon in ipairs(def.icons) do
			table.insert(formspec, ","..i.."="..F(icon))
		end
		table.insert(formspec,
			";color;text;color;text]"..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]"..
			"table[0.25,0.75;10.5,0.5;title;"..math.max(0, math.min(#icons, bulletin.icon))..","..player_name_color..","..ch_core.prihlasovaci_na_zobrazovaci(bulletin.owner)..":,"..title_color..","..F(bulletin.title or "").."]"..
			"tooltip[title;"..F(bulletin.title or "").."]"..
			"label[1.5,9.4;"..S("Posted by @1 (@2 days ago)", ch_core.prihlasovaci_na_zobrazovaci(bulletin.owner), math.floor((minetest.get_gametime() - bulletin.timestamp) / 86400)).."]"..
			"textarea[0.5,2.5;10,6.5;;"..F(bulletin.text or "")..";]"..
			"button[4,9.9;3,1;back;" .. S("Back to Board") .. "]")
		if bulletin.owner == player_name then
			table.insert(formspec,
				"image_button[0.25,9.9;1,1;bulletin_boards_delete.png;delete;]"..
				"tooltip[delete;"..S("Delete this bulletin").."]"..
				"label[0.25,9.7;"..S("Delete:").."]")
				-- .."label["..(#icons+1)*0.75-0.25 ..",7;"...."]"
		end
	else
		return
	end

	minetest.show_formspec(player_name, "bulletin_boards:bulletin", table.concat(formspec))
end

-- interpret clicks on the base board
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bulletin_boards:board" then return end
	local player_name = player:get_player_name()
	local state = bulletin_boards.player_state[player_name]
	if state == nil then return end
	local board = get_board(state.board)
	if fields.pridat then
		show_bulletin(player, state.board, #board + 1)
		return
	end
	local i
	for k, v in pairs(fields) do
		if k:sub(1, 11) == "vyberclanku" and v:sub(1, 4) == "CHG:" then
			i = v:sub(5,-1):gsub(":.*", "")
			i = tonumber(i)
			break
		end
	end
	if i ~= nil and i <= #board then
		show_bulletin(player, state.board, #board - i + 1)
	end
end)

-- interpret clicks on the bulletin
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bulletin_boards:bulletin" then return end
	local player_name = player:get_player_name()
	local player_role = ch_core.get_player_role(player_name)
	local state = bulletin_boards.player_state[player_name]
	if not state then return end
	local board, metadata = get_board(state.board)
	local def = bulletin_boards.board_def[state.board]
	if not board or not metadata then return end

	-- no security needed on these actions
	if fields.back then
		bulletin_boards.player_state[player_name] = nil
		show_board(player_name, state.board)
	end

	if fields.prev then
		show_bulletin(player, state.board, math.max(1, state.index - 1))
		return
	end
	if fields.next then
		show_bulletin(player, state.board, math.min(state.index + 1, #board))
		return
	end

	if fields.quit then
		minetest.after(0.1, show_board, player_name, state.board)
	end

	-- check if the player's allowed to do the stuff after this
	local current_bulletin = board[state.index]
	if player_role ~= "admin" and (current_bulletin and current_bulletin.owner ~= player_name) then
		-- someone's done something funny. Don't be accusatory, though - could be a race condition
		return
	end

	if fields.delete then
		-- delete the bulletin at index state.index
		local bulletin = board[state.index]
		if bulletin ~= nil then
			table.remove(board, state.index)
			local timestamp = minetest.get_gametime()
			metadata.update_timestamp = timestamp
			fields.title = ""
			save_boards()
			local player_pos = vector.round(player:get_pos())
			local board_pos = minetest.find_node_near(player_pos, 16, {state.board}, true)
			if board_pos ~= nil then
				update_board(board_pos, minetest.get_node(board_pos))
			end
			minetest.log("action", "Player "..player_name.." deleted a bulletin '"..(bulletin.title or "nil").."' by '"..(bulletin.owner or "nil").."' from "..state.board..". The new size of the board is "..#board..".")
		end
		bulletin_boards.player_state[player_name] = nil
		show_board(player_name, state.board)
		return
	end

	local player_inventory = minetest.get_inventory({type="player", name=player_name})
	local has_cost = true
	local is_creative = minetest.is_creative_enabled(player_name)
	if def.cost and not is_creative then
		has_cost = player_inventory:contains_item("main", def.cost)
	end
	for icon_index = 1, #def.icons do
		if fields.text ~= "" and fields["save_"..icon_index] then
			if player_role == "new" then
				ch_core.systemovy_kanal(player_name, "Nově založené postavy nemohou psát na nástěnky!")
				break
			elseif not (has_cost or is_creative) then
				ch_core.systemovy_kanal(player_name, "K vyvěšení příspěvku vám chybí nástěnkou požadovaná platba!")
				break
			else
				local cas = ch_core.aktualni_cas()
				local validity = fields.platnost
				if validity ~= nil then
					validity = tonumber(validity)
				end
				if validity ~= nil then
					validity = math.ceil(validity)
				end
				if validity ~= nil and 0 < validity and validity <= validity_max then
					validity = get_date_after_n_days(validity)
				else
					minetest.log("warning", "Unparsable or incorrect validity <"..(validity or "nil")..">")
					validity = get_date_after_n_days(validity_max)
				end
				local bulletin = {
					owner = player_name,
					title = ch_core.utf8_truncate_right(fields.title, max_title_size),
					text = ch_core.utf8_truncate_right(fields.text, max_text_size),
					icon = icon_index,
					timestamp = minetest.get_gametime(),
					date = cas.den..". "..cas.mesic..".",
					valid_until = validity,
				}
				board[state.index] = bulletin
				if def.cost and not is_creative then
					player_inventory:remove_item("main", def.cost)
				end
				metadata.color_index = metadata.color_index + 1
				metadata.update_timestamp = minetest.get_gametime()
				save_boards()

				-- update near boards of the same type:
				local player_pos = vector.round(player:get_pos())
				local board_pos = minetest.find_node_near(player_pos, 16, {state.board}, true)
				if board_pos ~= nil then
					update_board(board_pos, minetest.get_node(board_pos))
				end

				minetest.log("action", "Player "..player_name.." saved a bulletin '"..(bulletin.title or "nil").."' by '"..(bulletin.owner or "nil").."' to "..state.board.." at index "..state.index..". The new size of the board is "..#board..". Text of the bulletin:\n----\n"..bulletin.text.."\n----")
				break
			end
		end
	end
	bulletin_boards.player_state[player_name] = nil
	show_board(player_name, state.board)
end)


--[[ generates a random jumble of icons to superimpose on a bulletin board texture
-- rez is the "working" canvas size. 32-pixel icons get scattered on that canvas
-- before it is scaled down to 16 pixels
local function generate_random_board(rez, count, icons)
	icons = icons or base_icons
	local tex = {"([combine:"..rez.."x"..rez}
	for i = 1, count do
		tex[#tex+1] = ":"..math.random(1,rez-32)..","..math.random(1,rez-32)
			.."="..icons[math.random(1,#icons)]
	end
	tex[#tex+1] = "^[resize:16x16)"
	return table.concat(tex)
end
]]

local function register_board(board_name, board_def)
	bulletin_boards.board_def[board_name] = board_def
	local background = board_def.background or "bulletin_boards_corkboard.png"
	local foreground = board_def.foreground or "bulletin_boards_frame.png"
	-- local tile = background.."^"..generate_random_board(98, 7, board_def.icons).."^"..foreground
	local tile = background.."^"..foreground
	local bulletin_board_def = {
		description = board_def.desc,
		groups = {choppy=1, bulletin_board = 1},
		tiles = {{name = "ch_core_white_pixel.png", backface_culling = true}},
		overlay_tiles = {{name =
			(board_def.background or "bulletin_boards_corkboard_with_hole.png").."^"..
			(board_def.foreground or "(bulletin_boards_frame.png^[resize:32x32)"),
			backface_culling = true, color = "white"
		}},
		use_texture_alpha = "blend",
		inventory_image = (board_def.background or "(bulletin_boards_corkboard.png^[resize:32x32)").."^"..(board_def.foreground or "(bulletin_boards_frame.png^[resize:32x32)"),
		paramtype = "light",
		paramtype2 = "colorwallmounted",
		palette = "unifieddyes_palette_colorwallmounted.png",
		sunlight_propagates = true,
		drawtype = "nodebox",
		node_box = {
			type = "wallmounted",
			wall_top    = {-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			wall_side   = {-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5},
		},

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local player_name = clicker:get_player_name()
			show_board(player_name, board_name)
		end,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", board_def.desc or "")
		end,

		after_place_node = function(pos, placer, itemstack, pointed_thing)
			update_board(pos, minetest.get_node(pos))
		end,

		preserve_metadata = function(pos, oldnode, oldmeta, drops)
			if #drops == 1 then
				-- remove palette index from metadata
				drops[1]:get_meta():set_int("palette_index", 0)
			end
		end,
	}

	minetest.register_node(board_name, bulletin_board_def)
end

if minetest.get_modpath("default") then

register_board("bulletin_boards:bulletin_board_basic", {
	desc = S("Public Bulletin Board"),
	cost = "default:paper",
	icons = base_icons,
})
minetest.register_craft({
	output = "bulletin_boards:bulletin_board_basic",
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'default:paper', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	},
})

register_board("bulletin_boards:bulletin_board_copper", {
	desc = S("Copper Board"),
	cost = "default:copper_ingot",
	foreground = "bulletin_boards_frame_copper.png",
	icons = base_icons,
})
minetest.register_craft({
	output = "bulletin_boards:bulletin_board_copper",
	recipe = {
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
		{"default:copper_ingot", 'default:paper', "default:copper_ingot"},
		{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
	},
})
end

minetest.register_abm({
	label = "Bulletin Boards Updating",
	nodenames = {"group:bulletin_board"},
	interval = 5,
	chance = 1,
	catch_up = true,
	action = update_board,
})
