-- Saddlebag API functions

local function free_saddlebag(self)
	kitz.drop_item(self, ItemStack("petz:saddlebag"))
	--Drop the items from petz inventory
	local inv = self.saddlebag_inventory
	for key, value in pairs(inv) do
		kitz.drop_item(self, ItemStack(value))
	end
	self.saddlebag = kitz.remember(self, "saddlebag", false)
	self.saddlebag_inventory = {} --clear inventory
	kitz.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
end

local function free_saddle(self)
	kitz.drop_item(self, ItemStack("petz:saddle"))
	self.saddle = kitz.remember(self, "saddle", false)
	kitz.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
end

function petz.free_saddles(self)
	if self.saddle then -- drop saddle
		free_saddle(self)
	end
	if self.saddlebag then -- drop saddlebag and its content
		free_saddlebag(self)
	end
end
