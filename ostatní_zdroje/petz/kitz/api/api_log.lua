local _id = 0

function kitz.logon_mob(self)
	_id = _id + 1
	self._id = _id
	kitz.active_mobs[_id] = self
end

function kitz.logout_mob(self)
	kitz.active_mobs[self._id] = nil
end
