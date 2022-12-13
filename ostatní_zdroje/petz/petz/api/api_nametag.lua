petz.update_nametag = function(self)
	local name_tag
	if self.show_tag and self.tag and not(self.tag == "") then
		name_tag = self.tag
		local _bgcolor
		if not petz.settings["tag_background"] then
			_bgcolor = "#FFFFFF00"
		else
			_bgcolor = false
		end
		self.object:set_nametag_attributes({
			text = name_tag .." ♥ "..tostring(self.hp).."/"..tostring(self.max_hp),
			bgcolor = _bgcolor,
			})
	else
		self.object:set_nametag_attributes({
			text = "",
		})
	end
end

petz.delete_nametag = function(self)
	self.object:set_nametag_attributes({text = nil,})
end
