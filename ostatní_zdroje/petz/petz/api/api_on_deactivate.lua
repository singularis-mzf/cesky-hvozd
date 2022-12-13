function petz.on_deactivate(self)
	kitz.logout_mob(self)
	petz.dreamcatcher_save_metadata(self)
end
