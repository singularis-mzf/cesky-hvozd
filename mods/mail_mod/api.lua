-- see: mail.md

local S = minetest.get_translator("mail_mod")

mail.registered_on_receives = {}
function mail.register_on_receive(func)
	mail.registered_on_receives[#mail.registered_on_receives + 1] = func
end

mail.receive_mail_message = "You have a new message from @1! Subject: @2\nTo view it, type /mail"

--[[
mail sending function, can be invoked with one object argument (new api) or
all 4 parameters (old compat version)
see: "Mail format" api.md
--]]
function mail.send(src, dst, subject, body)
	-- figure out format
	local m
	if dst == nil and subject == nil and body == nil then
		-- new format (one object param)
		m = {from = src.from or src.src, to = src.to or src.dst, subject = src.subject or "", body = src.body or ""}
		if src.cc then
			m.cc = src.cc
		end
		if src.bcc then
			m.bcc = src.bcc
		end
	else
		-- old format
		m = {from = src, to = dst, subject = subject or "", body = body or ""}
	end

	local extra
	-- log mail send action
	if m.cc or m.bcc then
		local cc, bcc
		if m.cc then
			cc = "CC: " .. m.cc
			if m.bcc then
				cc = cc .. " - "
			end
		else
			cc = ""
		end
		if m.bcc then
			bcc = "BCC: " .. m.bcc
		else
			bcc = ""
		end
		extra = " (" .. cc .. bcc .. ")"
	else
		extra = ""
	end
	minetest.log("action", "[mail] '" .. m.from .. "' sends mail to '" .. m.to .. "'" ..
		extra .. "' with subject '" .. m.subject .. "' and body: '" .. m.body .. "'")

	-- normalize to, cc and bcc while compiling a list of all recipients
	local recipients = {}
	m.to = mail.normalize_players_and_add_recipients(m.to, recipients)
	if m.cc then
		m.cc = mail.normalize_players_and_add_recipients(m.cc, recipients)
	end
	if m.bcc then
		m.bcc = mail.normalize_players_and_add_recipients(m.bcc, recipients)
	end

	-- form the actual mail
	local msg = {
		unread  = true,
		sender  = m.from,
		to      = m.to,
		subject = m.subject,
		body    = m.body,
		time    = os.time(),
	}
	if m.cc then
		msg.cc  = m.cc
	end

	-- add self as a recipient
	recipients[m.from] = m.from

	-- send the mail to all recipients
	for _, recipient in pairs(recipients) do
		local messages = mail.getMessages(recipient)
		table.insert(messages, 1, msg)
		mail.setMessages(recipient, messages)
	end

	-- remove self from notifications
	recipients[m.from] = nil

	-- notify recipients that happen to be online
	local subject = m.subject
	if subject == "" then
		subject = "(Žádný předmět)"
	else
		subject = ch_core.utf8_truncate_right(subject, 27)
	end

	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if recipients[player_name] ~= nil then
			minetest.chat_send_player(player_name, S(mail.receive_mail_message, m.from, subject))
		end
	end

	for i=1, #mail.registered_on_receives do
		if mail.registered_on_receives[i](m) then
			break
		end
	end
end
