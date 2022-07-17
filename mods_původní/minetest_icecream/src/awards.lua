

-- Load support for MT game translation.
local S = minetest.get_translator("icecream")

awards.register_award("icecream:icecream", {
	title = S("Jummy..."),
	icon = "icecream_award.png",
	description = S("Craft one IceCream."),
	trigger = {
		type = "craft",
		item = "group:food_icecream",
		target = 1
	}
})
awards.register_award("icecream:snow", {
	title = S("For later, For Ice Cream"),
	icon = "icecream_award_snow.png",
	description = S("Get snow."),
	trigger = {
		type = "dig",
		item = "default:snow",
		target = 1
	}
})
awards.register_award("icecream:dough", {
	title = S("Kneading dough"),
	icon = "icecream_award_dough.png",
	description = S("Craft one Cone Dough."),
	trigger = {
		type = "craft",
		item = "icecream:dough",
		target = 1
	}
})
awards.register_award("icecream:cone", {
	title = S("Mega Cone"),
	icon = "icecream_award_cone.png",
	description = S("Eat your Cone."),
	trigger = {
		type = "eat",
		item = "icecream:cone",
		target = 1
	}
})
awards.register_award("icecream:frozen", {
	title = S("Froooozen Brain"),
	icon = "icecream_award_frozen.png",
	description = S("Eat one IceCream."),
	trigger = {
		type = "eat",
		item = "group:food_icecream",
		target = 1
	}
})