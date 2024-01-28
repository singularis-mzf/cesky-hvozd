local def = {
	description = "Otevře rozhraní pošty",
	func = function(name, param)
		if #param > 0 then -- if param is not empty
			mail.show_compose(name, param) -- make a new message
		else
			mail.show_mail_menu(name) -- show main menu
		end
	end
}

minetest.register_chatcommand("pošta", def)
minetest.register_chatcommand("posta", def)
