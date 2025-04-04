-- This file supplies all the code related to the airbrush

local S = minetest.get_translator("unifieddyes")

local has_ch_sky = minetest.get_modpath("ch_sky")

local function color_to_description(colorname)
	if colorname == nil then
		error("nil in color_to_description()!")
	end
	local idef = minetest.registered_items["dye:"..colorname] or minetest.registered_items[colorname]
	if idef ~= nil and idef.description ~= nil then
		return idef.description
	else
		minetest.log("error", "Can't translate color '"..colorname.."' to a description")
		return colorname
	end
end

local function get_dye_item(inv, listname, dye_item_name)
	if inv:contains_item(listname, dye_item_name) then
		return ItemStack(dye_item_name)
	end
	for _, stack in ipairs(inv:get_list(listname)) do
		local name = stack:get_name()
		if name ~= "" and core.get_item_group(name, "dye") ~= 0 then
			stack:set_count(1)
			return stack
		end
	end
	return ItemStack()
end

local function get_palette(ndef)
	if ndef == nil then
		return nil
	elseif ndef._ch_ud_palette ~= nil then
		return ndef._ch_ud_palette
	else
		return ndef.palette
	end
end

function unifieddyes.on_airbrush(itemstack, player, pointed_thing)
	local player_name = player:get_player_name()
	local painting_with = nil

	if unifieddyes.player_current_dye[player_name] then
		painting_with = unifieddyes.player_current_dye[player_name]
	end

	if not painting_with then
		minetest.chat_send_player(player_name, S("*** You need to set a color first."))
		minetest.chat_send_player(player_name, S("*** Right-click any random node to open the color selector,"))
		minetest.chat_send_player(player_name, S("*** or shift+right-click a colorized node to use its color."))
		minetest.chat_send_player(player_name, S("*** Be sure to click \"Accept\", or the color you select will be ignored."))
		return
	end

	local pos = minetest.get_pointed_thing_position(pointed_thing)
	if not pos then
		local look_angle = player:get_look_vertical()
		if look_angle > -1.55 then
			minetest.chat_send_player(player_name, S("*** No node selected"))
		else
			local hexcolor = unifieddyes.get_color_from_dye_name(painting_with)
			if hexcolor then
				local r = tonumber(string.sub(hexcolor,1,2),16)
				local g = tonumber(string.sub(hexcolor,3,4),16)
				local b = tonumber(string.sub(hexcolor,5,6),16)
				local color = string.format("#%02x%02x%02x", r, g, b)
				if has_ch_sky then
					ch_sky.set_sky(player, {type = "plain", base_color = color})
					ch_sky.colorize_sky(player, {day_color = color, day_ratio = 1.0, night_color = color, night_ratio = 1.0})
				else
					player:set_sky({type = "plain", base_color = color})
				end
			end
		end
		return
	end

	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if not def then return end

	if minetest.is_protected(pos, player_name) then
		minetest.chat_send_player(player_name, S("*** Sorry, someone else owns that node."))
		return
	end

	if not (def.groups and def.groups.ud_param2_colorable and def.groups.ud_param2_colorable > 0) then
		minetest.chat_send_player(player_name, S("*** That node can't be colored."))
		return
	end

	local palette = get_palette(def)
	local fdir = 0
	if not palette then
		minetest.chat_send_player(player_name, S("*** That node can't be colored -- it's either undefined or has no palette."))
		return
	elseif palette == "unifieddyes_palette_extended.png" then
		palette = "extended"
	elseif palette == "unifieddyes_palette_colorwallmounted.png" then
		palette = "wallmounted"
		fdir = node.param2 % 8
	elseif palette == "unifieddyes_palette_color4dir.png" then
		palette = "4dir"
		fdir = node.param2 % 4
	elseif palette ~= "unifieddyes_palette_extended.png"
	  and palette ~= "unifieddyes_palette_colorwallmounted.png"
	  and string.find(palette, "unifieddyes_palette_") then
		palette = "split"
		fdir = node.param2 % 32
	else
		minetest.chat_send_player(player_name, S("*** That node can't be colored -- it has an invalid color mode."))
		return
	end

	local idx, hue = unifieddyes.getpaletteidx(painting_with, palette)
	local inv, dye_item
	if not core.is_creative_enabled(player_name) then
		inv = player:get_inventory()
		dye_item = get_dye_item(inv, "main", painting_with)
		if dye_item:is_empty() then
			local suff = ""
			if not idx then
				suff = "  " .. S("Besides, @1 can't be applied to that node.", color_to_description(painting_with))
			end
			minetest.chat_send_player(
				player_name, S("*** You're in survival mode, and you're out of @1.", color_to_description(painting_with))..suff
			)
			return
		end
	end

	if not idx then
		minetest.chat_send_player(player_name, S("*** @1 can't be applied to that node.", color_to_description(painting_with)))
		return
	end

	local oldidx = node.param2 - fdir
	local name = def.airbrush_replacement_node or node.name

	if palette == "split" then

		local modname = string.sub(name, 1, string.find(name, ":")-1)
		local nodename2 = string.sub(name, string.find(name, ":")+1)
		local oldcolor
		local newcolor

		if def.ud_color_start and def.ud_color_end then
			oldcolor = string.sub(node.name, def.ud_color_start, def.ud_color_end)
			newcolor = string.sub(painting_with, 5)
		else
			if hue ~= 0 then
				newcolor = unifieddyes.HUES_EXTENDED[hue][1]
			else
				newcolor = "grey"
			end

			if def.airbrush_replacement_node then
				oldcolor = "grey"
			else
				local s = string.sub(get_palette(def), 21)
				oldcolor = string.sub(s, 1, string.find(s, "s.png")-1)
			end
		end

		name = modname..":"..string.gsub(nodename2, oldcolor, newcolor)

		if not minetest.registered_items[name] then
			minetest.chat_send_player(player_name, S("*** @1 can't be applied to that node.", color_to_description(painting_with)))
			return
		end
	elseif idx == oldidx then
		return
	end
	minetest.swap_node(pos, {name = name, param2 = fdir + idx})
	if inv ~= nil then
		inv:remove_item("main", dye_item)
		return
	end
end

local hps = 0.6 -- horizontal position scale
local vps = 1.3 -- vertical position scale
local vs = 0.1 -- vertical shift/offset

local color_button_size = ";0.75,0.75;"
local color_square_size = ";0.69,0.69;"

function unifieddyes.make_readable_color(color)
        -- is this a low saturation color?
        local has_low_saturtation = string.find(color, "s50");

        -- remove _s50 tag, we care about that later again
	local s = string.gsub(color, "_s50", "")

        -- replace underscores with spaces to make it look nicer
	s = string.gsub(s, "_", " ")

        -- capitalize words, you know, looks nicer ;)
        s = string.gsub(s, "(%l)(%w*)", function(a,b) return string.upper(a)..b end)

        -- add the word dye, this is what the translations expect
        s = s.." Dye"

	-- if it is a low sat color, append an appropriate string
	if has_low_saturtation then
	  s = s.." (low saturation)"
	end

	return s
end

function unifieddyes.make_colored_square(hexcolor, colorname, showall, creative, painting_with, nodepalette, hp, v2,
	selindic, inv, explist)

	local dye = "dye:"..colorname

	local overlay = ""
	local colorize = minetest.formspec_escape("^[colorize:#"..hexcolor..":255")

	if not creative and inv:contains_item("main", dye) then
		overlay = "^unifieddyes_onhand_overlay.png"
	end

	local unavail_overlay = ""
	if not showall and not unifieddyes.palette_has_color[nodepalette.."_"..colorname]
		or (explist and not explist[colorname]) then
		if overlay == "" then
			unavail_overlay = "^unifieddyes_unavailable_overlay.png"
		else
			unavail_overlay = "^unifieddyes_onhand_unavailable_overlay.png"
		end
	end

	local tooltip = "tooltip["..colorname..";"..
					S(unifieddyes.make_readable_color(colorname))..
					"\n(dye:"..colorname..")]"

	if dye == painting_with then
		overlay = "^unifieddyes_select_overlay.png"
		selindic = "unifieddyes_white_square.png"..colorize..overlay..unavail_overlay.."]"..tooltip
	end

	local form
	if unavail_overlay == "" then
		form = "image_button["..
					(hp*hps)..","..(v2*vps+vs)..
					color_button_size..
					"unifieddyes_white_square.png"..colorize..overlay..unavail_overlay..";"..
					colorname..";]"..
					tooltip
	else
		form = "image["..
					(hp*hps)..","..(v2*vps+vs)..
					color_square_size..
					"unifieddyes_white_square.png"..colorize..overlay..unavail_overlay.."]"..
					tooltip
	end

	return form, selindic
end

function unifieddyes.show_airbrush_form(player)
	if not player then return end

	local t = {}

	local player_name = player:get_player_name()
	local painting_with = unifieddyes.player_selected_dye[player_name] or unifieddyes.player_current_dye[player_name]
	local creative = minetest.is_creative_enabled(player_name)
	local inv = player:get_inventory()
	local nodepalette = "extended"
	local showall = unifieddyes.player_showall[player_name]
	local palette_data = unifieddyes.palette_data_extended

	t[1] = "size[14.5,8.5]label[7,-0.3;"..S("Select a color:").."]"
	local selindic = "unifieddyes_select_overlay.png^unifieddyes_question.png]"

	local last_right_click = unifieddyes.player_last_right_clicked[player_name]
	if last_right_click then
		local palette_info = unifieddyes.get_node_palette_by_def(last_right_click.def)
		if palette_info == nil then
			last_right_click.def = {}
			last_right_click.undef = true
		else
			nodepalette = palette_info.palette_type
			if nodepalette == "extended" then
				t[#t+1] = "label[0.5,8.25;"..S("(Right-clicked a node that supports all 256 colors, showing them all)").."]"
				showall = true
			end
			if palette_info.real_palette ~= nil and palette_info.real_palette:sub(1, 27) == "unifieddyes_palette_bright_" then
				palette_data = unifieddyes.palette_data_bright_extended
			end
		end
	end

	if last_right_click.undef then
		t[#t+1] = "label[0.5,8.25;"..S("(Right-clicked an undefined node, showing all colors)").."]"
	elseif not last_right_click.def.groups
	  or not last_right_click.def.groups.ud_param2_colorable
	  or not get_palette(last_right_click.def)
	  or not string.find(get_palette(last_right_click.def), "unifieddyes_palette_") then
		t[#t+1] = "label[0.5,8.25;"..S("(Right-clicked a node not supported by the Airbrush, showing all colors)").."]"
	end

	local explist = last_right_click.def.explist
	local color_data_index = 1

	for v = 0, 6 do
		local val = unifieddyes.VALS_EXTENDED[v+1]

		local sat = ""
		local v2=(v/2)

		for hi, h in ipairs(unifieddyes.HUES_EXTENDED) do
			local hue = h[1]
			local hp=hi-1

			local r = h[2]
			local g = h[3]
			local b = h[4]

			local factor = 40
			if v > 3 then
				factor = 75
				v2 = (v-2)
			end

			local r2 = math.max(math.min(r + (4-v)*factor, 255), 0)
			local g2 = math.max(math.min(g + (4-v)*factor, 255), 0)
			local b2 = math.max(math.min(b + (4-v)*factor, 255), 0)

			local hexcolor = string.format("%02x", r2)..string.format("%02x", g2)..string.format("%02x", b2)
			local color_data = palette_data[color_data_index]
			color_data_index = color_data_index + 1
			hexcolor = string.format("%02x%02x%02x", color_data[1], color_data[2], color_data[3])
			local f
			f, selindic = unifieddyes.make_colored_square(hexcolor, val..hue..sat, showall, creative, painting_with, nodepalette,
			hp, v2, selindic, inv, explist)
			t[#t+1] = f
		end

		if v > 3 then
			sat = "_s50"
			v2 = (v-1.5)

			for hi, h in ipairs(unifieddyes.HUES_EXTENDED) do
				local hue = h[1]
				local hp=hi-1

				local r = h[2]
				local g = h[3]
				local b = h[4]

				local factor = 75

				local pr = 0.299
				local pg = 0.587
				local pb = 0.114

				local r2 = math.max(math.min(r + (4-v)*factor, 255), 0)
				local g2 = math.max(math.min(g + (4-v)*factor, 255), 0)
				local b2 = math.max(math.min(b + (4-v)*factor, 255), 0)

				local p = math.sqrt(r2*r2*pr + g2*g2*pg + b2*b2*pb)
				local r3 = math.floor(p+(r2-p)*0.5)
				local g3 = math.floor(p+(g2-p)*0.5)
				local b3 = math.floor(p+(b2-p)*0.5)

				local hexcolor = string.format("%02x", r3)..string.format("%02x", g3)..string.format("%02x", b3)
				local color_data = palette_data[color_data_index]
				color_data_index = color_data_index + 1
				hexcolor = string.format("%02x%02x%02x", color_data[1], color_data[2], color_data[3])
				local f
				f, selindic = unifieddyes.make_colored_square(hexcolor, val..hue..sat, showall, creative, painting_with,
				nodepalette, hp, v2, selindic, inv, explist)
				t[#t+1] = f
			end
		end
	end

	local v2=5
	for y = 0, 15 do

		local hp=15-y

		local hexgrey = string.format("%02x", y*17)..string.format("%02x", y*17)..string.format("%02x", y*17)
		local color_data = palette_data[256 - y]
		hexgrey = string.format("%02x%02x%02x", color_data[1], color_data[2], color_data[3])
		local grey = "grey_"..y

		if y == 0 then grey = "black"
		elseif y == 4 then grey = "dark_grey"
		elseif y == 8 then grey = "grey"
		elseif y == 11 then grey = "light_grey"
		elseif y == 15 then grey = "white"
		end

		local f
		f, selindic = unifieddyes.make_colored_square(hexgrey, grey, showall, creative, painting_with, nodepalette, hp, v2,
		selindic, inv, explist)
		t[#t+1] = f

	end

	if not creative then
		t[#t+1] = "image[10,"
		t[#t+1] = (vps*5.55+vs)
		t[#t+1] = color_button_size
		t[#t+1] = "unifieddyes_onhand_overlay.png]label[10.7,"
		t[#t+1] = (vps*5.51+vs)
		t[#t+1] = ";"..S("Dyes").."]"
		t[#t+1] = "label[10.7,"
		t[#t+1] = (vps*5.67+vs)
		t[#t+1] = ";v inventáři]"

	end

	t[#t+1] = "image[10,"
	t[#t+1] = (vps*5+vs)
	t[#t+1] = color_button_size
	t[#t+1] = selindic

	if painting_with then
		t[#t+1] = "label[10.7,"
		t[#t+1] = (vps*4.90+vs)
		t[#t+1] = ";"..S("Your selection:").."]"
		t[#t+1] = "label[10.7,"
		t[#t+1] = (vps*5.07+vs)
		t[#t+1] = ";"
		t[#t+1] = S(unifieddyes.make_readable_color(string.sub(painting_with, 5)))
		t[#t+1] = "]label[10.7,"
		t[#t+1] = (vps*5.24+vs)
		t[#t+1] = ";("
		t[#t+1] = painting_with
		t[#t+1] = ")]"
	else
		t[#t+1] = "label[10.7,"
		t[#t+1] = (vps*5.07+vs)
		t[#t+1] = ";"..S("Your selection").."]"
	end

	t[#t+1] = "button_exit[10.5,8;2,1;cancel;"..S("Cancel").."]button_exit[12.5,8;2,1;accept;"..S("Accept").."]"


	if last_right_click and last_right_click.def and nodepalette ~= "extended" then
		if showall then
			t[#t+1] = "button[0,8;2,1;show_avail;"..S("Show Available").."]"
			t[#t+1] = "label[2,8.25;"..S("(Currently showing all 256 colors)").."]"
		else
			t[#t+1] = "button[0,8;2,1;show_all;"..S("Show All Colors").."]"
			t[#t+1] = "label[2,8.25;"..S("(Currently only showing what the right-clicked node can use)").."]"
		end
	end

	minetest.show_formspec(player_name, "unifieddyes:dye_select_form", table.concat(t))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)

	if formname == "unifieddyes:dye_select_form" then

		local player_name = player:get_player_name()
		local nodepalette = "extended"
		local showall = unifieddyes.player_showall[player_name]

		local last_right_click = unifieddyes.player_last_right_clicked[player_name]
		if last_right_click and last_right_click.def then
			if get_palette(last_right_click.def) then
				if get_palette(last_right_click.def) == "unifieddyes_palette_colorwallmounted.png" then
					nodepalette = "wallmounted"
				elseif get_palette(last_right_click.def) == "unifieddyes_palette_color4dir.png" then
					nodepalette = "4dir"
				elseif get_palette(last_right_click.def) ~= "unifieddyes_palette_extended.png" then
					nodepalette = "split"
				end
			end
		end

		if fields.show_all then
			unifieddyes.player_showall[player_name] = true
			unifieddyes.show_airbrush_form(player)
			return
		elseif fields.show_avail then
			unifieddyes.player_showall[player_name] = false
			unifieddyes.show_airbrush_form(player)
			return
		elseif fields.quit then
			if fields.accept then
				local dye = unifieddyes.player_selected_dye[player_name]
				if not dye then
					minetest.chat_send_player(player_name, S("*** Clicked \"Accept\", but no color was selected!"))
					return
				elseif not showall
						and not unifieddyes.palette_has_color[nodepalette.."_"..string.sub(dye, 5)] then
					minetest.chat_send_player(player_name, S("*** Clicked \"Accept\", but the selected color can't be used on the"))
					minetest.chat_send_player(player_name, S("*** node that was right-clicked (and \"Show All\" wasn't in effect)."))
					if unifieddyes.player_current_dye[player_name] then
						minetest.chat_send_player(player_name, S("*** Ignoring it and sticking with @1.", color_to_description(unifieddyes.player_current_dye[player_name])))
					else
						minetest.chat_send_player(player_name, S("*** Ignoring it."))
					end
					return
				else
					unifieddyes.player_current_dye[player_name] = dye
					unifieddyes.player_selected_dye[player_name] = nil
					minetest.chat_send_player(player_name, S("*** Selected @1 for the airbrush.", color_to_description(dye)))
					return
				end
			else -- assume "Cancel" or Esc.
				unifieddyes.player_selected_dye[player_name] = nil
				return
			end
		else
			local s3 = ""
			for k, _ in pairs(fields) do
				s3 = k
				break
			end

			local inv = player:get_inventory()
			local creative = minetest.is_creative_enabled(player_name)
			local dye = "dye:"..s3

			if (showall or unifieddyes.palette_has_color[nodepalette.."_"..s3]) --[[and
				(creative or inv:contains_item("main", dye) )]] then
				unifieddyes.player_selected_dye[player_name] = dye
				unifieddyes.show_airbrush_form(player)
			end
		end
	end
end)

minetest.register_tool("unifieddyes:airbrush", {
	description = S("Dye Airbrush"),
	_ch_help = "Slouží k barvení bloků.\nZvláštní nástroj — neopotřebovává se, ale vyžaduje barviva (nemáte-li právo usnadnění hry).\nLevý klik na blok ho nabarví zvolenou barvou, pravý klik na blok vyvolá okno s výběrem barvy k barvení.\nAux1 + pravý klik na již nabarvený blok nastaví barvu podle něj.\nK barvení jízdních kol a tramvají slouží jiná barvicí pistole.",
	inventory_image = "unifieddyes_airbrush.png",
	use_texture_alpha = true,
	tool_capabilities = {
		full_punch_interval=0.1,
	},
	range = 12,
	on_use = unifieddyes.on_airbrush,
	on_place = function(itemstack, placer, pointed_thing)
		local keys = placer:get_player_control()
		local player_name = placer:get_player_name()
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node
		local def

		if pos then node = minetest.get_node(pos) end
		if node then def = minetest.registered_items[node.name] end

		if keys.sneak and def and def.on_rightclick then
			return def.on_rightclick(pos, node, placer, itemstack, pointed_thing)
		end

		unifieddyes.player_last_right_clicked[player_name] = {pos = pos, node = node, def = def}

		if not keys.aux1 then
			unifieddyes.show_airbrush_form(placer)
		elseif keys.aux1 then
			if not pos or not def then return end
			local newcolor = unifieddyes.color_to_name(node.param2, def)

			if newcolor and string.find(def.paramtype2, "color") then
				minetest.chat_send_player(player_name, S("*** Switching to @1 for the airbrush, to match that node.", color_to_description(newcolor)))
				unifieddyes.player_current_dye[player_name] = "dye:"..newcolor
			else
				minetest.chat_send_player(player_name, S("*** That node is uncolored."))
			end
		end
	end
})
