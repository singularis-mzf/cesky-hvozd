

-- Give player comboblock letter on initial logon
minetest.register_on_newplayer(function(player)
	player:get_inventory():add_item("main", "comboblock:help")
end)

-- register our Page
minetest.register_craftitem("comboblock:help", {
	description = "Comboblock Letter",
	inventory_image = "comboblock_help.png",
	groups = {letter = 1, flammable = 3},
	on_use = function(itemstack, user, pointed_thing)
				 minetest.show_formspec(user:get_player_name(), "comboblock:help", comboblock.letter)
			 end,
})

comboblock.letter ="formspec_version[5]"..
				"size[12.5,14.0]"..
				"box[0,0;12.5,14.0;#181818]"..
				"box[0.25,0.25;12,13.5;#ffeed4]"..
				"image[4.25,0.75;4.25,0.8;comboblock_header.png]"..
				"image[0.6,2.2;1.8,1.7;comboblock_help_1a.png]"..
				"image[0.6,5.2;1.8,1.7;comboblock_help_1b.png]"..
				"image[3,2.2;1.8,1.7;comboblock_help_2a.png]"..
				"image[3,5.2;1.8,1.7;comboblock_help_2b.png]"..
				"image[5.4,2.2;1.8,1.7;comboblock_help_3a.png]"..
				"image[5.4,5.2;1.8,1.7;comboblock_help_3b.png]"..
				"image[7.8,2.2;1.8,1.7;comboblock_help_4a.png]"..
				"image[7.8,5.2;1.8,1.7;comboblock_help_4b.png]"..
				"image[10.1,2.2;1.8,1.7;comboblock_help_5a.png]"..
				"image[10.1,5.2;1.8,1.7;comboblock_help_5b.png]"..
				"image[1.4,4.2;0.5,0.5;comboblock_arrow.png]"..
				"image[3.8,4.2;0.5,0.5;comboblock_arrow.png]"..
				"image[6.3,4.2;0.5,0.5;comboblock_arrow.png]"..
				"image[8.8,4.2;0.5,0.5;comboblock_arrow.png]"..
				"image[11.1,4.2;0.5,0.5;comboblock_arrow.png]"..
				"image[1.25,9;1.8,1.7;comboblock_help_8.png]"..
				"image[4.3,9;1.8,1.7;comboblock_help_9.png]"..
				"image[8.5,8.6;2.5,2.5;comboblock_help_10.png]"..
				"image[3.35,9.6;0.65,0.65;comboblock_plus.png]"..
				"image[6.95,9.45;0.65,0.65;comboblock_equals.png]"..
				"image[0.2,3;0.5,0.5;comboblock_paperedge.png]"..
				"image[0.2,3.5;0.25,0.25;comboblock_paperedge.png^[transformFY]"..
				"image[0.2,11.5;0.65,0.65;comboblock_paperedge.png^[transformFY]"..
				"image[0.2,11.25;0.3,0.4;comboblock_paperedge.png]"..
				"image[11.85,5;0.6,0.6;comboblock_paperedge.png^[transformFX]"..
				"image[12,5.3;0.3,0.7;comboblock_paperedge.png^[transformFX]"..
				"image[12,0.5;0.5,0.4;comboblock_paperedge.png^[transformFX]"..
				"image[12.1,0.35;0.3,0.3;comboblock_paperedge.png^[transformFX]"..
				"image[12,12;0.3,0.5;comboblock_paperedge.png^[transformFXFY]"..
				"image[11,13.5;0.5,0.3;comboblock_paperedge.png^[transformR90]"..
				"image[11.25,13.5;0.5,0.6;comboblock_paperedge.png^[transformR90]"..
				"image[4.25,13.5;1.25,0.4;comboblock_paperedge.png^[transformR90]"..
				"image[4.00,13.6;0.75,0.25;comboblock_paperedge.png^[transformR90FX]"..
				"image[2,0.25;0.85,0.25;comboblock_paperedge.png^[transformR270]"..
				"image[9.5,0.25;0.4,0.35;comboblock_paperedge.png^[transformR270]"..
				"image[9.75,0.25;0.7,0.15;comboblock_paperedge.png^[transformR270FX]"