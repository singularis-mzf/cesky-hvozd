beautiflowers = {}

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local mpath = minetest.get_modpath("beautiflowers")
local pot = minetest.get_modpath("flowerpot")

beautiflowers.flowers ={

    {"bonsai_1","green", "bonsai_1", "Bonsaj 1", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_2","brown", "bonsai_2", "Bonsaj 2", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_3","green", "bonsai_3", "Bonsaj 3", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"bonsai_4","brown", "bonsai_4", "Bonsaj 4", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_5","dark_green", "bonsai_5", "Bonsaj 5", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},

    {"pasto_1","dark_green", "pasto_1", "Travina 1", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_2","dark_green", "pasto_2", "Travina 2", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_3","dark_green", "pasto_3", "Travina 3", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_4","dark_green", "pasto_4", "Travina 4", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"pasto_5","dark_green", "pasto_5", "Travina 5", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"pasto_6","dark_green", "pasto_6", "Travina 6", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_7","dark_green", "pasto_7", "Travina 7", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_8","dark_green", "pasto_8", "Travina 8", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_9","dark_green", "pasto_9", "Travina 9", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_10","dark_green", "pasto_10","Travina 10", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},

    {"stanislava","red", "arcoiris", "Stanislava červená (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"vlastimil","yellow", "ada", "Vlastimil žlutý (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"antonie","yellow", "agnes", "Antonie žlutá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"emanuel","yellow", "alicia", "Emanuel žlutý (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"borivoj","yellow", "alma", "Bořivoj žlutý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"erika","yellow", "amaia", "Erika žlutá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"bronislav","yellow", "any", "Bronislav žlutý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"jaromir","yellow", "anastasia", "Jaromír žlutý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"denisa","blue", "astrid", "Denisa modrá (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"vaclav","blue", "beatriz", "Václav modrý (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"filip","violet", "belen", "Filip fialový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"liliana","blue", "berta", "Liliana modrá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"gita","blue", "blanca", "Gita modrá (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pavel","white", "carla", "Pavel bílý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"zuzana","blue", "casandra", "Zuzana modrá (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"monika","blue", "clara", "Monika modrá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"roman","blue", "claudia", "Roman modrý (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"eliska","white", "cloe", "Eliška bílá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"jakub","pink", "cristina", "Jakub růžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"hanus","orange", "dafne", "Hanuš oranžový (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"laura","orange", "dana", "Laura oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"veroslav","orange", "delia", "Věroslav oranžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"marta","orange", "elena", "Marta oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"jana","orange", "erica", "Jana oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"darina","orange", "estela", "Darina oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"emilie","orange", "eva", "Emílie oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"sandra","orange", "fabiola", "Sandra oranžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"norbert","orange", "fiona", "Norbert oranžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"vavrinec","orange", "gala", "Vavřinec oranžový (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"magda","pink", "gisela", "Magda růžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"ivan","white", "gloria", "Ivan bílý (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"zina","white", "irene", "Zina bílá (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"pankrac","white", "ingrid", "Pankrác bílý (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"lukas","white", "iris", "Lukáš bílý (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"bohdan","white", "ivette", "Bohdan bílý (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"frantisek","orange", "jennifer", "František oranžový (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"iva","red", "lara", "Iva červená (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"natasa","red", "laura", "Nataša červená (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"viktor","red", "lidia", "Viktor červený (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"herman","red", "lucia", "Heřman červený (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"klara","red", "mara", "Klára červená (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, 2 / 16, 5 / 16}},
    {"brigita","red", "martina", "Brigita červená (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"valdemar","red", "melania", "Valdemar červený (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"ema","red", "mireia", "Ema červená (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"dusan","red", "nadia", "Dušan červený (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"zbynek","red", "nerea", "Zbyněk červený (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"adela","red", "noelia", "Adéla červená (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"viola","violet", "noemi", "Viola fialová (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"jeronym","magenta", "olimpia", "Jeroným magentový (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"justyna","magenta", "oriana", "Justýna magentová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"sabina","pink", "pia", "Sabina růžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 0 / 16, 2 / 16}},
    {"otmar","pink", "raquel", "Otmar růžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 0 / 16, 2 / 16}},
    {"mahulena","pink", "ruth", "Mahulena růžová (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"ondrej","pink", "sandra", "Ondřej růžový (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"mikulas","pink", "sara", "Mikuláš růžový (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"kvetoslava","pink", "silvia", "Květoslava růžová (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"vratislav","pink", "sofia", "Vratislav růžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"lucie","pink", "sonia", "Lucie růžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -1 / 16, 2 / 16}},
    {"natalie","pink", "talia", "Natálie růžová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"judita","cyan", "thais", "Judita tyrkysová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"zaneta","cyan", "valeria", "Žaneta tyrkysová (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"ludvik","cyan", "valentina", "Ludvík tyrkysový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"vavrinec","cyan", "vera", "Vavřinec tyrkysový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16}},
    {"alan","cyan", "victoria", "Alan tyrkysový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"rehor","cyan", "xenia", "Řehoř tyrkysový (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"milena","cyan", "zaida", "Milena tyrkysová (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"vilma","cyan", "virginia", "Vilma tyrkysová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"cestmir","violet", "nazareth", "Čestmír fialový (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"silvestr","violet", "arleth", "Silvestr fialový (květina)", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"viktorie","violet", "miriam", "Viktorie fialová (květina)", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"robert","violet", "minerva", "Robert fialový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"bonifac","violet", "vanesa", "Bonifác fialový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"tamara","violet", "sabrina", "Tamara fialová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"alois","violet", "rocio", "Alois fialový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"karolina","violet", "regina", "Karolína fialová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"helena","violet", "paula", "Helena fialová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"berta","violet", "olga", "Berta fialová (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"erik","violet", "xena", "Erik fialový (květina)", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"albina","white", "diana", "Albína bílá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"leos","pink", "caroline", "Leoš růžový (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"sona","white", "michelle", "Soňa bílá (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"lubomir","white", "genesis", "Lubomír bílý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"leopold","white", "suri", "Leopold bílý (květina)", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"zofie","white", "hadassa", "Žofie bílá", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
}

local flowers = beautiflowers.flowers

for i = 1, #flowers do
	local name, dye, texture, czechname, box = unpack(flowers[i])
    -- local desc = unpack(name:split("_"))

    minetest.register_node("beautiflowers:"..dye.."_"..name, {
	    description = czechname,
	    drawtype = "plantlike",
	    waving = 1,
	    visual_scale = 1.0,
	    tiles = {texture..".png"},
	    inventory_image = texture..".png",
	    wield_image = texture..".png",
	    paramtype = "light",
	    sunlight_propagates = true,
	    walkable = false,
	    buildable_to = true,
	    groups = {snappy = 3, flower = 1, flora = 1, attached_node = 1, flammable = 1, beautiflowers = 1},
	    sounds = default.node_sound_leaves_defaults(),
	    selection_box = {
		    type = "fixed",
		    fixed = box or {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
	    },
    })

    minetest.register_craft({
	    output = "dye:"..dye.." 4",
	    recipe = {
		    {"beautiflowers:"..dye.."_"..name}
	    },
    })

    if pot then
	   flowerpot.register_node("beautiflowers:"..dye.."_"..name)
    end
end

minetest.register_craft({
	output = "beautiflowers:bonsai_1",
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "default:sapling", "default:cobble"},
        {"default:cobble", "default:cobble", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_2",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_3",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:cobble", "default:sapling", "default:cobble"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_4",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:sapling", "default:cobble", "default:sapling"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_5",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:sapling", "default:sapling", "default:sapling"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

-- dofile(mpath .. "/spawn.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
