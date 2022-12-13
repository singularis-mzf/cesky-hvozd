--
--'set_initial_properties' is call by 'on_activate' for each pet
--

petz.dyn_prop = {
	accel = {type= "int", default = 1},
	affinity = {type= "int", default = 100},
	anthill_founded = {type= "boolean", default = false},
	back_home = {type= "boolean", default = false},
	beaver_oil_applied = {type= "boolean", default = false},
	--DELETE THIS BLOCK IN A FUTURE UPDATE -- behive changed to beehive>>>
	behive = {type= "pos", default = nil},
	--<
	beehive = {type= "pos", default = nil},
	brushed = {type= "boolean", default = false},
	captured = {type= "boolean", default = false},
	child = {type= "boolean", default = false},
	colorized = {type= "string", default = nil},
	convert = {type= "string", default = nil},
	convert_to = {type= "string", default = nil},
	convert_count = {type= "int", default = 5},
	plucked = {type= "string", default = nil},
	dreamcatcher = {type= "boolean", default = false},
	dead = {type= "boolean", default = false},
	driver = {type= "player", default = nil},
	eggs_count = {type= "int", default = 0},
	exchange_item_index = {type= "int", default = 1},
	exchange_item_amount = {type= "int", default = 1},
	father_genes = {type= "table", default = {}},
	father_veloc_stats = {type= "table", default = {}},
	fed = {type= "boolean", default = true},
	food_count = {type= "int", default = 0},
	food_count_wool = {type= "int", default = 0},
	for_sale = {type= "boolean", default = false},
	gallop = {type= "boolean", default = false},
	gallop_time = {type= "int", default = 0},
	gallop_exhausted = {type= "boolean", default = false},
	gallop_recover_time = {type= "int", default = petz.settings.gallop_recover_time},
	genes = {type= "table", default = {}},
	growth_time = {type= "int", default = 0},
	herding = {type= "boolean", default = false},
	home_pos = {type= "table", default = nil},
	horseshoes = {type= "int", default = 0},
	is_baby = {type= "boolean", default = false},
	is_male = {type= "boolean", default = nil},
	is_pregnant = {type= "boolean", default = false},
	is_rut = {type= "boolean", default = false},
	lashed = {type= "boolean", default = false},
	lashing_count = {type= "int", default = 0},
	lifetime = {type= "int", default = nil},
	max_speed_forward = {type= "int", default = 1},
	max_speed_reverse = {type= "int", default = 1},
	milked = {type= "boolean", default = false},
	muted = {type= "boolean", default = false},
	owner = {type= "string", default = nil},
	pregnant_count = {type= "int", default = petz.settings.pregnant_count},
	pregnant_time = {type= "int", default = 0},
	previous_status = {type= "string", default = nil},
	saddle = {type= "boolean", default = false},
	saddlebag = {type= "boolean", default = false},
	saddlebag_inventory = {type= "table", default = {}},
	shaved = {type= "boolean", default = false},
	show_tag = {type= "boolean", default = false},
	sleep_start_time = {type= "int", default = nil},
	sleep_end_time = {type= "int", default = nil},
	square_ball_attached = {type= "boolean", default = false},
	status = {type= "string", default = nil},
	tag = {type= "string", default = ""},
	tamed = {type= "boolean", default = false},
	--texture_no = {type= "int", default = nil}, --PASSED BY STATICDATA
	warn_attack = {type= "boolean", default = false},
	was_killed_by_player = {type= "boolean", default = false},
}

petz.compose_texture= function(self)
	local texture
	if self.type == "lamb" then
		local shaved_string = ""
		if self.shaved then
			shaved_string = "_shaved"
		end
		texture = "petz_lamb".. shaved_string .."_"..self.skin_colors[self.texture_no]..".png"
	elseif self.is_mountable then
		if self.saddle then
			texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png" .. "^petz_"..self.type.."_saddle.png"
		else
			texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png"
		end
		if self.saddlebag then
			texture = texture .. "^petz_"..self.type.."_saddlebag.png"
		end
	else
		texture = self.textures[self.texture_no]
	end
	return texture
end

petz.cleanup_prop= function(self)
	self.warn_attack = false --reset the warn attack
	self.driver = nil --no driver
	self.was_killed_by_player = false --reset the warn attack
end

petz.genetics_random_texture = function(self, textures_count)
	local _array = {}
	for row = 1, textures_count do
		_array[row] = {}
		for col = 1, textures_count do
			_array[row][col] = math.min(row, col)
		end
	end
	return _array[math.random(1, textures_count)][math.random(1, textures_count)]
	-- Accessing the array to calculate the rates
	--local rates = {}
	--for row=1, textures_count do
		--for col=1, textures_count do
			--rates[array[row][col]] = (rates[array[row][col]] or 0) + 1
		--end
	--end

	--for row=1, textures_count do
		--minetest.chat_send_player("singleplayer", tostring(rates[row]))
	--end
end

petz.set_random_gender = function()
	if math.random(1, 2) == 1 then
		return true
	else
		return false
	end
end

petz.get_gen = function(self)
	local textures_count
	if self.mutation and (self.mutation > 0) then
		textures_count = #self.skin_colors - self.mutation
	else
		textures_count = #self.skin_colors
	end
	return math.random(1, textures_count)
end

petz.genetics_texture  = function(self, textures_count)
	for i = 1, textures_count do
		if self.genes["gen1"] == i or self.genes["gen2"] == i then
			return i
		end
	end
end

petz.load_vars = function(self)
	for key, value in pairs(petz.dyn_prop) do
		self[key] = kitz.recall(self, key) or value["default"]
	end
	if not(self.sleep_start_time) or not(self.sleep_end_time) then
		petz.calculate_sleep_times(self)
	end
	petz.insert_tamed_by_owner(self)
	petz.cleanup_prop(self) --Reset some vars
end

function petz.set_initial_properties(self, staticdata, dtime_s)
	--minetest.chat_send_all(staticdata)
	local static_data_table = minetest.deserialize(staticdata)
	local captured_mob = false
	local baby_born = false
	if static_data_table and static_data_table["memory"]
		and static_data_table["memory"]["captured"] then
			captured_mob = true
	elseif static_data_table and static_data_table["baby_born"] then
		baby_born = true
	end
	--
	--1. NEW MOBS
	--
	if not(self.texture_no) and not(captured_mob) then --set some vars
		--Load default settings ->
		for key, value in pairs(petz.dyn_prop) do
			self[key] = value["default"]
		end
		--Define some settings ->
		--Set a random gender for all the mobs (not defined in the entity definition)
		if (self.is_male == nil) then
			self.is_male = kitz.remember(self, "is_male", petz.set_random_gender())
		end
		if self.is_mountable then
			if not(baby_born) then
				self.max_speed_forward= kitz.remember(self, "max_speed_forward", math.random(2, 4)) --set a random velocity for walk and run
				self.max_speed_reverse= kitz.remember(self, "max_speed_reverse", math.random(1, 2))
				self.accel= kitz.remember(self, "accel", math.random(2, 4))
			end
		end
		if self.parents then --for chicken only
			self.is_baby = kitz.remember(self, "is_baby", true)
		end
		--Mobs that can have babies
		if self.breed then
			--Genetics
			local genes_mutation = false
			if self.mutation and (self.mutation > 0) and math.random(1, 200) == 1 then
				genes_mutation = true
			end
			if not genes_mutation then
				if not baby_born then
					self.genes["gen1"] = petz.get_gen(self)
					self.genes["gen2"] = petz.get_gen(self)
					--minetest.chat_send_player("singleplayer", tostring(self.genes["gen1"]))
					--minetest.chat_send_player("singleplayer", tostring(self.genes["gen2"]))
				else
					if math.random(1, 2) == 1 then
						self.genes["gen1"] = static_data_table["gen1_father"]
					else
						self.genes["gen1"] = static_data_table["gen2_father"]
					end
					if math.random(1, 2) == 1 then
						self.genes["gen2"] = static_data_table["gen1_mother"]
					else
						self.genes["gen2"] = static_data_table["gen2_mother"]
					end
				end
				local textures_count
				if self.mutation and (self.mutation > 0) then
					textures_count = #self.skin_colors - self.mutation
				else
					textures_count = #self.skin_colors
				end
				self.texture_no = petz.genetics_texture(self, textures_count)
			else -- mutation
				local mutation_gen = math.random((#self.skin_colors-self.mutation+1), #self.skin_colors) --select the mutation in the last skins
				self.genes["gen1"] = mutation_gen
				self.genes["gen2"] = mutation_gen
				self.texture_no = mutation_gen
			end
			kitz.remember(self, "genes", self.genes)
		end
		--ALL the mobs
		--Get a texture
		if not self.texture_no then
			if self.skin_colors then
				local textures_count
				if self.mutation and (self.mutation > 0) then
					textures_count = #self.skin_colors - self.mutation
				else
					textures_count = #self.skin_colors
				end
				self.texture_no = petz.genetics_random_texture(self, textures_count)
			else
				--texture variation
				if #self.textures >= 1 then
					self.texture_no = math.random(#self.textures)
				end
			end
		end

		--Save the texture number:
		self.texture_no = kitz.remember(self, "texture_no", self.texture_no or 1)

		if petz.settings[self.type.."_convert_count"] then
			self.convert_count = kitz.remember(self, "convert_count", petz.settings[self.type.."_convert_count"])
		end

		if self.init_tamagochi_timer then
			petz.init_tamagochi_timer(self)
		end

		petz.calculate_sleep_times(self) --Sleep behaviour
	--
	--2. ALREADY EXISTING MOBS
	--
	elseif not captured_mob then
		--Check if the petz was removed from the petz list in the settings
		local remove_petz = true
		for key, value in pairs(petz.settings["petz_list"]) do
			if value == self.type then
				remove_petz = false
				break
			end
		end
		if remove_petz then
			self.object:remove()
			return
		end
		petz.load_vars(self) --Load memory variables
		if not self.texture_no then
			self.texture_no = kitz.remember(self, "texture_no", 1)
		end
	--
	--3. CAPTURED MOBS
	--
	else
		self.captured = kitz.remember(self, "captured", false) --IMPORTANT! mark as not captured
		for key, value in pairs(petz.dyn_prop) do
			local prop_value
			if value["type"] == "string" then
				prop_value = static_data_table["memory"][key]
			elseif value["type"] == "int" then
				prop_value = tonumber(static_data_table["memory"][key])
			elseif value["type"] == "boolean" then
				prop_value = minetest.is_yes(static_data_table["memory"][key])
			elseif value["type"] == "table" then
				prop_value = static_data_table["memory"][key]
			elseif value["type"] == "player" then
				prop_value = nil
			end
			self[key] = kitz.remember(self, key, prop_value) or value["default"]
		end
	end

	--Check if dead
	if self.dead then
		self.object:remove()
		return
	end

	--set the texture
	if self.texture_no then
		local texture = petz.compose_texture(self) --compose the texture
		local props = {}
		props.textures = {texture}
		self.object:set_properties(props) --apply the texture
	end

	if self.type == "bee" and self.queen then --delay to create beehive
		minetest.after(math.random(120, 150), function()
			if kitz.is_alive(self.object) then
				self.create_beehive = kitz.remember(self, "create_beehive", true)
			end
		end, self)
	elseif self.type == "ant" and self.ant_type == "queen" then
		minetest.after(math.random(120, 150), function()
			if kitz.is_alive(self.object) then
				self.create_anthill = kitz.remember(self, "create_anthill", true)
			end
		end, self)
	end

	if self.colorized then
		if not self.shaved then
			petz.colorize(self, self.colorized)
		end
	end

	--<<<
	--DELETE THIS BLOCK IN A FUTURE UPDATE -- behive changed to beehive>>>
	if self.behive then
		self.beehive = kitz.remember(self, "beehive", self.behive)
		self.behive = kitz.remember(self, "behive", nil)
	end
	--<<<

	if self.horseshoes and not captured_mob then
		petz.horseshoes_speedup(self)
	end

	if self.breed then
		if baby_born then
			self.is_baby = kitz.remember(self, "is_baby", true)
		end
		if self.is_baby then
			petz.set_properties(self, {
				visual_size = self.visual_size_baby,
				collisionbox = self.collisionbox_baby
			})
		end
	end

	--self.head_rotation = {x= -90, y= 90, z= 0}
	--self.whead_position = self.object:get_bone_position("parent")
	--self.head_position.y = self.head_position.y + 0.25

	--ALL the mobs

	if self.is_pet and self.tamed then
		petz.update_nametag(self)
	end

	if self.status then
		if self.status == "stand" then
			petz.standhere(self)
		elseif self.status == "guard" then
			petz.guard(self)
		elseif self.status == "sleep" then
			self.status = nil --reset
		elseif self.status == "alight" then
			petz.alight(self, 0, "alight")
		else
			self.status = nil
		end
	end

end
