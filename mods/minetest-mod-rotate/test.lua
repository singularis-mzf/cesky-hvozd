#! /usr/bin/lua5.1

--cat init.lua | sed 's/[^a-zA-Z0-9_\.]\+/\n/g' | sort -u | grep '^minetest'
minetest = {}
minetest.registered_nodes = {
	["default:stick"] = {},
	["default:steel_ingot"] = {},
	["default:copper_ingot"] = {},
	["default:gold_ingot"] = {},
	}
minetest.registered_items = {}

minetest.add_node = function() end
minetest.chat_send_player = function() end
minetest.get_node = function() end
minetest.get_node_or_nil = function() end
minetest.get_player_privs = function() end
minetest.is_protected = function() end
minetest.record_protection_violation = function() end
minetest.register_craft = function() end
minetest.register_craftitem = function() end
minetest.register_on_craft = function() end
minetest.register_privilege = function() end
minetest.register_tool = function() end
minetest.remove_node = function() end
minetest.setting_getbool = function() end
minetest.swap_node = function() end

minetest.log = function(level, message) print(string.upper(level)..": "..message) end

minetest.get_modpath = function(name)
	if name == "rotate" then
	    return "."
	else
	    return nil
	end
end

dofile("init.lua")
