ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("advtrains")

local function escape_texture(str)
	return str:gsub("[%[%()^:]", "\\%1")
end

local inventory_list_sizes = {box=15*8}
local function get_inventory_formspec(self, pname, invname)
	return "size[15,13]"..
			"list["..invname..";box;0,0;15,8;]"..
			"list[current_player;main;3,9;8,4;]"..
			"listring[]"
end

local allowed_drawtypes = {
	normal = 1,
	allfaces = 1,
	allfaces_optional = 1,
	glasslike = 1,
	glasslike_framed = 1,
	glasslike_framed_optional = 1,
	liquid = 1,
}
local paper_items = {
	["default:paper"] = 1,
	["homedecor:toilet_paper"] = 1,
	["homedecor:paper_towel"] = 1,
}

local wagon_item_cache = {}

local function set_textures(self, data)
	local inv = minetest.get_inventory({type="detached", name="advtrains_wgn_"..data.id})
	local itemname = (inv and inv:get_stack("box", 1):get_name()) or ""
	if itemname ~= (wagon_item_cache[data.id] or "") then
		local obj_properties = nil
		minetest.log("info", data.id..": Gondola item name changed from "..(wagon_item_cache[data.id] or "").." to "..itemname)
		if itemname ~= "" then
			if paper_items[itemname] then
				obj_properties = {
					mesh="moretrains_gondola_toiletpaper.b3d",
					textures = {"moretrains_wagon_gondola.png"},
				}
			elseif minetest.get_item_group(itemname, "advtrains_trackplacer") > 0 then
				obj_properties = {
					mesh="moretrains_gondola_rails.b3d",
					textures = {"moretrains_wagon_gondola.png"},
				}
			else
				local def = minetest.registered_nodes[itemname]
				if allowed_drawtypes[def.drawtype or ""] then
					local texture = def.tiles or "default_cobble.png"
					if type(texture) == "table" then
						texture = texture[1] or "default_cobble.png"
					end
					obj_properties = {
						mesh="moretrains_gondola_mese.b3d",
						textures={"[combine:256x256:0,0=moretrains_wagon_gondola_cobble.png:0,109="..escape_texture(texture).."\\^\\[resize\\:16x16"},
					}
				end
			end
			wagon_item_cache[data.id] = itemname
		else
			wagon_item_cache[data.id] = nil
		end
		self.object:set_properties(obj_properties or {mesh="moretrains_gondola.b3d", textures = {"moretrains_wagon_gondola.png"}})
	end
end

local function convert(self, dtime, data, train)
	-- data.type = "advtrains:moretrains_wagon_gondola"
	set_textures(self, data)
end

advtrains.register_wagon("moretrains_wagon_gondola", {
	mesh="moretrains_gondola.b3d",
	textures = {"moretrains_wagon_gondola.png"},
	set_textures = set_textures,
	custom_on_step = convert,
	seats = {},
	drives_on={default=true},
	max_speed=20,
	visual_size = {x=1, y=1},
	wagon_span=2.784,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:wood 2", "default:chest", "advtrains:wheel 2"},
	has_inventory = true,
	get_inventory_formspec = get_inventory_formspec,
	inventory_list_sizes = inventory_list_sizes,
}, S("Gondola wagon (empty)"), "moretrains_wagon_gondola_inv.png")

minetest.register_craft({
	output = 'advtrains:moretrains_wagon_gondola',
	recipe = {
		{'group:wood', 'default:chest', 'group:wood'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

ch_base.close_mod(minetest.get_current_modname())
