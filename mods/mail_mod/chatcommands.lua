local show_inbox = function(name)
	mail.show_inbox(name)
end

local def = {
	description = "Otevře okno s poštou",
	func = show_inbox
}

minetest.register_chatcommand("pošta", def)
minetest.register_chatcommand("posta", def)
