print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

mail = {

	-- mark webmail fork for other mods
	fork = "webmail",

	-- api version
	apiversion = 1.1,

	-- mail directory
	maildir = minetest.get_worldpath().."/mails",
	contactsdir = minetest.get_worldpath().."/mails/contacts",

	-- allow item/node attachments
	allow_attachments = minetest.settings:get("mail.allow_attachments") == "true",

	webmail = {
		-- disallow banned players in the webmail interface
		disallow_banned_players = minetest.settings:get("webmail.disallow_banned_players") == "true",

		-- url and key to the webmail server
		url = minetest.settings:get("webmail.url"),
		key = minetest.settings:get("webmail.key")
	},

	tan = {}
}


local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/util/normalize.lua")
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/attachment.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/storage.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")
dofile(MP .. "/onjoin.lua")
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
