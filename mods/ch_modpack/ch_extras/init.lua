ch_base.open_mod(minetest.get_current_modname())

local has_unifieddyes = minetest.get_modpath("unifieddyes")

ch_extras = {}

function ch_extras.degrotate_after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.paramtype2 == "degrotate" then
		node.param2 = math.random(0, 239)
		minetest.swap_node(pos, node)
	end
end

function ch_extras.degrotate_on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 239 then
			node.param2 = 0
		else
			node.param2 = node.param2 + 1
		end
	else
		if node.param2 == 0 then
			node.param2 = 239
		else
			node.param2 = node.param2 - 1
		end
	end
	minetest.swap_node(pos, node)
	return true
end

local dofile = ch_core.compile_dofile({}, {path = true})

local function dofile_ud(...)
    if has_unifieddyes then
        return dofile(...)
    end
end

dofile("3dprint.lua") -- 3D tisk (jen funkce, samotné bloky jsou definovány jinde)
dofile("anchor.lua") -- soukromá světová kotva
-- dofile("balikovna.lua") -- rozepsáno
dofile_ud("colorable_nodes.lua") -- další lakované bloky
dofile_ud("colorable_doors.lua") -- lakované dveře
dofile_ud("colorable_fence.lua") -- lakovaný plot -- : colorable_nodes.lua
dofile_ud("colorable_grate.lua") -- lakované pletivo
dofile_ud("colorable_glass.lua") -- barevné sklo
dofile_ud("colorable_pole.lua") -- lakovaná tyč
dofile("covers.lua") -- pokrývky
dofile("craftitems.lua") -- předměty (různé)
dofile_ud("dice.lua") -- hrací kostka
dofile("doors.lua") -- různé dveře
dofile("fence_hv.lua") -- výstražný plot
dofile("flags.lua") -- česká a slovenská vlajka (node_box)
dofile("geokes.lua") -- geokeš a související značky
dofile("gravel.lua") -- světlý a železniční štěrk
dofile("lupa.lua") -- zrcadlo
dofile("magic_wand.lua") -- kouzelnická hůlka
dofile("marble.lua") -- venkovní mramor
dofile("markers.lua") -- značkovací tyče
dofile("mirror.lua") -- zrcadlo
dofile("otisky.lua") -- sada na rozbor otisků prstů
dofile_ud("particle_board.lua") -- dřevotříska
dofile("periskop.lua") -- periskop
dofile("piles.lua") -- hromady dřeva
dofile("ropeblock.lua") -- lanový blok
dofile("scorched_tree.lua") -- ohořelý kmen
dofile_ud("shaft.lua") -- dřík kamenného sloupu
dofile("sickles.lua") -- srpy
dofile("skakadlo.lua") -- skákadlo
dofile("small_decorations.lua") -- praskliny a špína
dofile("switch.lua") -- výměnové návěstidlo
dofile("teleporter.lua") -- teleportér
dofile_ud("tile1.lua") -- barvitelná mozaika na dlažbu
dofile("totalst.lua") -- totální stanice
dofile("trojnastroj.lua") -- trojnástroj
dofile_ud("vraceni_satu.lua") -- vracení šatů (regál a pás)
dofile_ud("vystavni_ram.lua") -- výstavní rám
dofile("zdlazba.lua") -- zámková dlažba

ch_base.close_mod(minetest.get_current_modname())
