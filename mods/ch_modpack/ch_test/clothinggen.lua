if minetest.get_modpath("clothing") then

	local function give_item(inv, name, alt_name)
		if minetest.registered_items[name] ~= nil then
			inv:add_item("main", ItemStack(name))
		elseif alt_name ~= nil and minetest.registered_items[alt_name] ~= nil then
			inv:add_item("main", ItemStack(alt_name))
		else
			minetest.log("warning", "Item "..name.." not found.")
		end
	end
	
	local function prikaz1(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		local inv = player:get_inventory()
		local basic_colors = clothing.basic_colors

		for a, _ in pairs(basic_colors) do
			-- single-color
			give_item(inv, "clothing:"..param.."_"..a)
		end
	end

	local function prikaz2(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		local inv = player:get_inventory()
		local basic_colors = clothing.basic_colors

		for a, _ in pairs(basic_colors) do
			for b, _ in pairs(basic_colors) do
				if a.."_s50" == b then
					give_item(inv, "clothing:"..param.."_"..a.."_"..b, "clothing:"..param.."_"..b.."_"..a)
				end
			end
		end
	end

	local function prikaz3(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		local inv = player:get_inventory()
		local basic_colors = clothing.basic_colors

		for a, _ in pairs(basic_colors) do
			for b, _ in pairs(basic_colors) do
				if a.."_s50" == b then
					give_item(inv, "clothing:"..param.."_"..a.."_"..b.."_stripy", "clothing:"..param.."_"..b.."_"..a.."_stripy")
				end
			end
		end
	end

	local privs = {give = true, server = true}
	local function get_def(prikaz)
		return {
			description = "Generování oblečení",
			params = "",
			privs = privs,
			func = prikaz,
		}
	end

	minetest.register_chatcommand("gensaty1", get_def(prikaz1))
	minetest.register_chatcommand("gensaty2", get_def(prikaz2))
	minetest.register_chatcommand("gensaty3", get_def(prikaz3))
end
