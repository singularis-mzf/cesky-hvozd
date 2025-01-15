local def

local function command(player_name, param)
	return true
end


local function command(player_name, param)
	core.show_formspec(player_name, "ch_test:test", "formspec_version[6]"..
		"size[20,20]".."no_prepend[]"..
		"box[0,0;20,20;#333333FF]".."style_type[list;size=1.6,1.6;spacing=0.75,0.75]".."list[current_player;main;1,1.25;8,8;0]")
	return true
end








def = {
	params = "[text]",
	description = "spustí právě testovanou akci pro účely vývoje serveru (jen pro Administraci)",
	privs = {server = true},
	func = command,
}
minetest.register_chatcommand("test", def)
