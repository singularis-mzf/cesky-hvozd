-- TODO this doesn't handle coloring and translation

local old_chat_send_player = minetest.chat_send_player

function minetest.chat_send_player(name, text)
	while #text > 65000 do
		local found_newline = false
		for i = 65000, 1, -1 do
			if text:sub(i, i) == "\n" then
				old_chat_send_player(name, text:sub(1, i - 1))
				text = text:sub(i + 1)
				found_newline = true
				break
			end
		end

		if not found_newline then
			old_chat_send_player(name, text:sub(1, 65000))
			text = text:sub(65000 + 1)
		end
	end

	if #text > 0 then
		old_chat_send_player(name, text)
	end
end

local old_chat_send_all = minetest.chat_send_all

function minetest.chat_send_all(text)
	while #text > 65000 do
		local found_newline = false
		for i = 65000, 1, -1 do
			if text:sub(i, i) == "\n" then
				old_chat_send_all(text:sub(1, i - 1))
				text = text:sub(i + 1)
				found_newline = true
				break
			end
		end

		if not found_newline then
			old_chat_send_all(text:sub(1, 65000))
			text = text:sub(65000 + 1)
		end
	end

	if #text > 0 then
		old_chat_send_all(text)
	end
end
