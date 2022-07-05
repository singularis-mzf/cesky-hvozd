minetest.register_on_joinplayer(function(player)
	minetest.after(2, function(name)
		local messages = mail.getMessages(name)

		local unreadcount = 0

		for _, message in pairs(messages) do
			if message.unread then
				unreadcount = unreadcount + 1
			end
		end

		if unreadcount > 0 then
			minetest.chat_send_player(name,
				minetest.colorize("#00f529", "(" ..  unreadcount .. ") Máte nepřečtenou poštu! Pro přečtení zadejte „/pošta“, „/posta“, nebo použijte tlačítko v inventáři"))

		end
	end, player:get_player_name())
end)
