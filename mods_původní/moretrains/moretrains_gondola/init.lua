local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end


local function escape_texture(str)
	return str:gsub("[%[%()^:]", "\\%1")
end

local function	set_textures(self, data)
	local inv = minetest.get_inventory({type="detached", name="advtrains_wgn_"..data.id})
	if inv then
		if inv:is_empty("box") then
			self.object:set_properties({
						mesh="moretrains_gondola.b3d",
			})
			return
		end			
		local stack = inv:get_stack("box",1)
		local name = stack:get_name()		
		local ndef = minetest.registered_nodes[name]
		if ndef then
			local dtype = ndef.drawtype
			if dtype == "normal" or dtype == "allfaces" or dtype == "allfaces_optional" or dtype == "glasslike" or dtype == "glasslike_framed" or dtype == "glasslike_framed_optional" or dtype == "liquid" then
				local texture = ndef.tiles or "default_cobble.png"
				if type(texture) == "table" then
					texture = texture[1] or "default_cobble.png"
				end
				self.object:set_properties({
						mesh="moretrains_gondola_mese.b3d",
						textures={"[combine:256x256:0,0=moretrains_wagon_gondola_cobble.png:0,109="..escape_texture(texture).."\\^\\[resize\\:16x16"}
				})
				return
			end
		end
		local idef = minetest.registered_items[name]
		if idef and idef.groups.advtrains_trackplacer and idef.groups.advtrains_trackplacer > 0 then
			self.object:set_properties({
					mesh="moretrains_gondola_rails.b3d",
					textures = {"moretrains_wagon_gondola.png"},
			})
		else
			self.object:set_properties({
					mesh="moretrains_gondola_toiletpaper.b3d",
					textures = {"moretrains_wagon_gondola.png"},
			})
		end
	end		
end


local function convert(self, dtime, data, train)
	data.type = "advtrains:moretrains_wagon_gondola"
end
advtrains.register_wagon("moretrains_wagon_gondola", {
	mesh="moretrains_gondola.b3d",
	textures = {"moretrains_wagon_gondola.png"},
	set_textures = set_textures,
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Gondola wagon (empty)"), "moretrains_wagon_gondola_inv.png")


advtrains.register_wagon("moretrains_wagon_gondola_mese", {
	mesh="moretrains_gondola_mese.b3d",
	textures = {"moretrains_wagon_gondola.png"},
	seats = {},
	drives_on={default=true},
	custom_on_step = convert,
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Gondola wagon with mese"), "moretrains_wagon_gondola_mese_inv.png")



advtrains.register_wagon("moretrains_wagon_gondola_cobble", {
	mesh="moretrains_gondola_mese.b3d",
	textures = {"[combine:256x256:0,0=moretrains_wagon_gondola_cobble.png:0,109=default_obsidian_glass.png\\^\\[resize\\:16x16"},
	seats = {},
	custom_on_step = convert,
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Gondola wagon with cobble stone"), "moretrains_wagon_gondola_cobble_inv.png")

advtrains.register_wagon("moretrains_wagon_gondola_toiletpaper", {
	mesh="moretrains_gondola_toiletpaper.b3d",
	textures = {"moretrains_wagon_gondola.png"},
	set_textures = set_textures,
	custom_on_step = convert,
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Gondola wagon with toilet paper"), "moretrains_wagon_gondola_toiletpaper_inv.png")

advtrains.register_wagon("moretrains_wagon_gondola_rails", {
	mesh="moretrains_gondola_rails.b3d",
	textures = {"moretrains_wagon_gondola.png"},
	custom_on_step = convert,
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
	has_inventory = true,
	get_inventory_formspec = function(self, pname, invname)
		return "size[8,11]"..
			"list["..invname..";box;0,0;8,3;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
	end,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Gondola wagon with rails"), "moretrains_wagon_gondola_rails_inv.png")


minetest.register_craft({
	output = 'advtrains:moretrains_wagon_gondola',
	recipe = {
		{'group:wood', 'default:chest', 'group:wood'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

