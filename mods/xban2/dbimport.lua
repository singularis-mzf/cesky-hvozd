
xban.importers = { }

dofile(xban.MP.."/importers/minetest.lua")
dofile(xban.MP.."/importers/v1.lua")
dofile(xban.MP.."/importers/v2.lua")

minetest.register_chatcommand("xban_dbi", {
	description = "Import old databases",
	params = "<importer>",
	privs = { server=true },
	func = function(name, params)
		if params == "--list" then
			local importers = { }
			for importer in pairs(xban.importers) do
				table.insert(importers, importer)
			end
			minetest.chat_send_player(name,
			  ("[xban] Známé importéry: %s"):format(
			  table.concat(importers, ", ")))
			return
		elseif not xban.importers[params] then
			minetest.chat_send_player(name,
			  ("[xban] Neznámý importér `%s'"):format(params))
			minetest.chat_send_player(name, "[xban] Zkuste `--list'")
			return
		end
		local f = xban.importers[params]
		local ok, err = f()
		if ok then
			minetest.chat_send_player(name,
			  "[xban] Import úspěšný")
		else
			minetest.chat_send_player(name,
			  ("[xban] Import selhal: %s"):format(err))
		end
	end,
})
