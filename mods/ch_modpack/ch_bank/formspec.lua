local tinv, utils = ...

local F = minetest.formspec_escape
local STATE_OPEN, STATE_CLOSED, STATE_CONFIRMED = utils.STATE_OPEN, utils.STATE_CLOSED, utils.STATE_CONFIRMED

local state_descs = {
	"#00ff00,<nabídka otevřena>",
	"#ff3333,<nabídka uzavřena>",
	"#ffff00,<obchod potvrzen>",
}

local role_images = {
	admin = "ch_core_koruna.png",
	new = "ch_core_slunce.png",
	survival = "ch_core_kladivo.png",
	creative = "ch_core_kouzhul.png",
}
local role_descs = {
	admin = F("správa serveru"),
	new = F("nová postava"),
	survival = F("dělnická postava"),
	creative = F("kouzelnická postava"),
}

function utils.get_formspec(trade_state)
	local zprava_name = "zprava"..trade_state.privmsg_index

	local player_name = trade_state.left.player_name
	local player = assert(minetest.get_player_by_name(player_name))
	local tiparams = tinv.get_trade_inventory_formspec_params(player)

	local player_name_right = trade_state.right.player_name
	local player_right = assert(minetest.get_player_by_name(player_name_right))
	local tiparams_right = tinv.get_trade_inventory_formspec_params(player_right)

	local formspec = {
		ch_core.formspec_header{
			formspec_version = 6,
			size = {11.375, 14.25},
			position = {0.8, 0.5},
			anchor = {0.8, 0.5},
			auto_background = true,
			bgcolor = {"", false, ""},
		},
		"image[0.325,0.325;1,1;"..F(ch_bank.icon).."]", -- from currency mode
		"label[1.6,0.8;Výměnný obchod]"..
		"button[10.5,0.325;0.75,0.75;zavrit;x]"..
		"tableoptions[background=#00000000;border=false;highlight=#00000000]"..
		"tablecolumns[color;text;color;text]"..
		-- LEFT LIST:
		"tooltip[0.25,1.4;5.4,0.5;",
			(role_descs[trade_state.left.player_role] or "neznámá postava"),
		"]"..
		"image[0.25,1.4;0.5,0.5;",
			(role_images[trade_state.left.player_role] or "ch_core_empty.png"),
		"]"..
		"table[0.7,1.5;6,2;lplayer;#ffffff,"..F(trade_state.left.player_display_name)..",",
		state_descs[trade_state.left.state]..";1]",
		"list["..tiparams.location..";"..tiparams.listname..";0.325,2;"..tiparams.width..","..tiparams.height..";0]",
		-- RIGHT LIST:
		"tooltip[5.65,1.4;5.4,0.5;",
			(role_descs[trade_state.right.player_role] or "neznámá postava"),
		"]"..
		"image[5.65,1.4;0.5,0.5;",
			(role_images[trade_state.right.player_role] or "ch_core_empty.png"),
		"]"..
		"table[6.1,1.5;6,2;rplayer;#ffffff,"..F(trade_state.right.player_display_name)..",",
		state_descs[trade_state.right.state]..";1]",
		"list["..tiparams_right.location..";"..tiparams_right.listname..";6.25,2;"..tiparams_right.width..","..tiparams_right.height..";0]",
		-- PRIVATE MESSAGE:
		"tooltip["..zprava_name..";Tip: Zprávu odešlete i pouhým stisknutím Enter.]"..
		"field[4,7.25;4.25,0.5;"..zprava_name..";napsat soukromou zprávu:;]"..
		"field_close_on_enter["..zprava_name..";false]"..
		"button[8.4,7.25;1.25,0.5;sendprivmsg;odeslat]"..
		"button[9.85,7.25;1.25,0.5;resetprivmsg;smazat]",
	}
	-- Buttons:
	if trade_state.left.state == STATE_OPEN then
		table.insert(formspec, "button[0.325,7;1.75,1;close_offer;uzavřít\nnabídku]")
	elseif trade_state.left.state == STATE_CONFIRMED or (trade_state.left.state == STATE_CLOSED and trade_state.right.state == STATE_OPEN) then
		table.insert(formspec, "button[2.1,7;1.75,1;cancel_offer;zrušit]")
	else
		table.insert(formspec, "button[0.325,7;1.75,1;confirm_offer;potvrdit\nsměnu]")
		table.insert(formspec, "button[2.1,7;1.75,1;cancel_offer;zrušit]")
	end
	table.insert(formspec, "scroll_container[0,8;12,6;sbar;vertical]")
	local zustatek, color = ch_bank.zustatek(player_name, true)
	if zustatek ~= nil then
		table.insert(formspec,
					"tableoptions[background=#00000000;highlight=#00000000;border=false]"..
					"tablecolumns[color;text;color;text;color;text]"..
					"table[0.3,0.2;10,0.5;;#cccccc,na účtu:,"..color..","..
					F(zustatek)..",#cccccc,Kčs]"..
					"field[4.25,0.0;1.5,0.5;penize;;1]"..
					"tooltip[penize;Částka pro výběr z účtu. Musí být celé číslo v rozsahu 1 až 10000.]"..
					"field_close_on_enter[penize;false]"..
					"item_image_button[5.9,0.0;0.6,0.6;ch_core:kcs_kcs;kcs;]"..
					"item_image_button[6.6,0;0.6,0.6;ch_core:kcs_h;hcs;]"..
					"item_image_button[7.3,0;0.6,0.6;ch_core:kcs_zcs;zcs;]"..
					"label[8,0.25;(výběr do nabídky)]")
	end
	local left_inv_ring = "listring["..tiparams.location..";"..tiparams.listname.."]"
	table.insert(formspec,
		"label[0.325,0.75;hlavní inventář:]"..
		"list[current_player;main;0.325,1;8,4;0]")
		if trade_state.left.state == STATE_OPEN then
			table.insert(formspec, left_inv_ring.."listring[current_player;main]")
		end
	local player_inv = player:get_inventory()
	for i = 1, 8, 1 do
		local bag_rows = math.ceil(player_inv:get_size("bag"..i.."contents") / 8)
		if bag_rows > 0 then
			table.insert(formspec,
				"label[0.325,"..(4.25 * i + 2.0)..";batoh "..i.."]"..
				"list[current_player;bag"..i.."contents;0.325,"..(4.25 * i + 2.25)..";8,"..bag_rows..";0]"..
				left_inv_ring..
				"listring[current_player;bag"..i.."contents]")
		end
	end
	table.insert(formspec, "scroll_container_end[]"..
		"scrollbaroptions[max=340;arrows=show]"..
		"scrollbar[10.75,8;0.4,6;vertical;sbar;]")
	return table.concat(formspec)
end
