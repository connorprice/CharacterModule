CharacterModule = CharacterModule or class(ItemModuleBase)

function CharacterModule:RegisterHook()
	-- Check for an id!
	if not self._config.id then
		BeardLib:log("[ERROR] Character Module missing 'id'!")
	end

	-- Setup Character Defaults
	self._config.based_on = self._config.based_on or "russian"
	self._config.default_mask = self._config.default_mask or "dallas"

	self._config.character = self._config.character or {}
	self._config.blackmarket = self._config.blackmarket or {}
	self._config.gui = self._config.gui or {}

	self._config.blackmarket.name_id = self._config.blackmarket.name_id or "menu_" .. self._config.id
	self._config.blackmarket.desc_id = self._config.blackmarket.desc_id or self._config.desc_id .. "_desc" 
	
	self._config.blackmarket.sequence = self._config.blackmarket.sequence or "var_mtr_" .. self._config.id
	self._config.blackmarket.mask_on_sequence = self._config.blackmarket.mask_on_sequence or "mask_on_" .. self._config.id
	self._config.blackmarket.mask_off_sequence = self._config.blackmarket.mask_off_sequence or "mask_off_" .. self._config.id

	self._config.gui.name_id = self._config.gui.name_id or self._config.blackmarket.name_id
	self._config.gui.desc_id = self._config.gui.desc_id or self._config.blackmarket.desc_id

	self._config.masks.x = self._config.masks.x or 0
	self._config.masks.y = self._config.masks.y or 0
	self._config.masks.z = self._config.masks.z or 0

	-- Add Character Tweak Data
	Hooks:PostHook( CharacterTweakData, "init", self._config.id .. "AddCharacterTweakData", function( char_self )
		if char_self[self._config.id] then
			BeardLib:log("[ERROR] CharacterTweakData with id '%s' already exists!", self._config.id)
			return
		end

		local data = table.merge( deep_clone( char_self[self._config.based_on] ), self._config.character )
		char_self[self._config.id] = data
	end)

	-- Add Criminal Tweak Data
	local function SetupCriminalTweakData( tweak_data )  
		local function GetCriminalBasedOnData( based_on )
			for index, data in pairs( tweak_data.criminals.characters ) do
				if data.name == based_on then
					return deep_clone( data )
				end
			end
		end

		local criminal_based_on = self._config.based_on
		local criminal_based_on_data = GetCriminalBasedOnData( criminal_based_on )

		local _characters = table.size(tweak_data.criminals.characters)

		criminal_based_on_data.name = self._config.id
		criminal_based_on_data.order = _characters + 1

		criminal_based_on_data.static_data.voice = self._config.character.speech_prefix or criminal_based_on_data.static_data.voice
		criminal_based_on_data.static_data.ai_mask_id = self._config.id
		criminal_based_on_data.static_data.ai_character_id = "ai_" .. self._config.id
		
		tweak_data.criminals.characters[_characters + 1] = criminal_based_on_data

		table.insert(tweak_data.criminals.character_names, self._config.id)
	end

	-- Extra Helper Function
	local function ConvertOldToNewCharacterName( name )
		local t = {
			spanish = "chains",
			russian = "dallas",
			german = "wolf",
			american = "hoxton"
		}

		return t[name] or name
	end

	-- Add Black Market Tweak Data
	Hooks:PostHook( BlackMarketTweakData, "_init_characters", self._config.id .. "AddCharacterBlackMarketTweakData", function( bmc_self, tweak_data )
		if bmc_self.characters[self._config.id] then
			BeardLib:log("[ERROR] BlackMarketTweakData with id '%s' already exists!", self._config.id)
			return
		end

		local based_on = ConvertOldToNewCharacterName( self._config.based_on )
		local based_on_data = nil

		local based_on_locked = {
			fps_unit = "units/payday2/characters/fps_mover/fps_mover",
			npc_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1",
			menu_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1_menu",
			sequence = "var_material_01",
			name_id = "bm_character_locked"
		}

		if bmc_self.characters.locked[based_on] then
			based_on_data = table.merge( based_on_locked, bmc_self.characters.locked[based_on] )
		else
			based_on_data = deep_clone( bmc_self.characters[based_on] )
		end

		local data = table.merge( based_on_data, self._config.blackmarket )
		bmc_self.characters[self._config.id] = data
		bmc_self.characters[self._config.id].based_on = self._config.based_on
		bmc_self.characters[self._config.id].custom = true

		-- Store this for our auto sequence generation.
		self._config.blackmarket.npc_unit = data.npc_unit
		
		local ai_based_on = "ai_" .. based_on
		local ai_based_on_data = deep_clone( bmc_self.characters[ai_based_on] )

		local ai_data = table.merge( ai_based_on_data, self._config.blackmarket )
		bmc_self.characters["ai_".. self._config.id] = ai_data

		SetupCriminalTweakData( tweak_data )
	end)
	-- Add Economy Tweak Data
	Hooks:PostHook( EconomyTweakData, "init", self._config.id .. "AddCharacterEconomyTweakData", function( eco_self )
		eco_self.character_cc_configs[self._config.id] = eco_self.character_cc_configs[self._config.based_on]
	end)

	Hooks:PostHook(GuiTweakData, "init", self._config.id .. "AddCharacterGuiTweakData", function(gui_self)
		local function GetGuiBasedOnData( based_on )
			for index, data in pairs( gui_self.crime_net.codex[2] ) do
				if data.id == based_on then
					return deep_clone( data )
				end
			end
		end

		local based_on = ConvertOldToNewCharacterName( self._config.based_on )
		local based_on_data = GetGuiBasedOnData( based_on )

		based_on_data.id = self._config.id
		based_on_data.name_id = self._config.gui.name_id
		based_on_data[1].desc_id = self._config.gui.desc_id
		based_on_data[1].post_event = self._config.gui.post_event or based_on_data[1].post_event
		based_on_data[1].videos = self._config.gui.videos or based_on_data[1].videos

		table.insert( gui_self.crime_net.codex[2], based_on_data )
	end)

	-- Add Mask Tweak Data
	Hooks:PostHook( BlackMarketTweakData, "_init_masks", self._config.id .. "AddCharacterMaskTweakData", function( bmm_self )
		bmm_self.masks.character_locked[self._config.id] = self._config.default_mask

		local function CalculateNewMaskOffset( mask_id, mask_data )
			local offset = Vector3( self._config.masks.x, self._config.masks.y, self._config.masks.z )
			if self._config.masks[mask_id] then
				offset = Vector3( self._config.masks[mask_id].x or self._config.masks.x, self._config.masks[mask_id].y or self._config.masks.y, self._config.masks[mask_id].z or self._config.masks.z )
			end

			if mask_data.offsets then
				local based_on_offset = mask_data.offsets[self._config.based_on]
				if based_on_offset then
					offset = offset + based_on_offset[1]
				end
			else
				mask_data.offsets = {}
			end

			if based_on_offset then
				mask_data.offsets[self._config.id] = clone( mask_data.offsets[self._config.based_on] )
				mask_data.offsets[self._config.id][1] = offset
			else
				mask_data.offsets[self._config.id] = { offset, Rotation( 0, 0, 0 ) }
			end
		end

		local function CalculateNewMaskReplace( mask_id, mask_data )
			if self._config.masks[mask_id] and self._config.masks[mask_id].mask_replace then
				mask_data.characters = mask_data.characters or {}
				mask_data.characters[self._config.id] = self._config.masks[mask_id].mask_replace
				return
			end
			
			if mask_data.characters then
				local based_on_mask_replace = mask_data.characters[self._config.based_on]
				if based_on_mask_replace then
					mask_data.characters[self._config.id] = based_on_mask_replace
				end
			end
		end

		for mask_id, mask_data in pairs(bmm_self.masks) do
			CalculateNewMaskOffset( mask_id, mask_data )
			CalculateNewMaskReplace( mask_id, mask_data )
		end
	end)

	-- Automatically Generate Sequence
	Hooks:AddHook( "BeardLibProcessScriptData", self._config.id .. "AddCharacterScriptData", function( ids_ext, ids_path, data )
		if ids_ext == Idstring("sequence_manager") then
			if ids_path == Idstring(self._config.blackmarket.npc_unit) then
				if self._config.unit then
					local sequence = {
						_meta = "sequence",
						editable_state = "true",
						name = "'" .. self._config.blackmarket.sequence .. "'",
						triggable = "true",
						{
							_meta = "run_sequence",
							name = "'int_seq_hide_all'"
						},
						{
							_meta = "function",
							extension = "'spawn_manager'",
							["function"] = "'spawn_and_link_unit_nosync_load'",
							param1 = "'_char_joint_names'",
							param2 = "'custom_char_mesh'",
							param3 = "'" .. self._config.unit .. "'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_1'",
							name = "'var_model_01'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_2'",
							name = "'var_model_02'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_3'",
							name = "'var_model_03'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_4'",
							name = "'var_model_04'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_5'",
							name = "'var_model_05'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_6'",
							name = "'var_model_06'"
						},
						{
							_meta = "run_sequence",
							filter = "'armor_state_7'",
							name = "'var_model_07'"
						}
					}

					if self._config.extra_units then
						for index, unit in pairs(self._config.extra_units) do
							if type(index) == "number" then
								local extra_unit = {
									_meta = "function",
									extension = "'spawn_manager'",
									["function"] = "'spawn_and_link_unit_nosync_load'",
									param1 = "'_char_joint_names'",
									param2 = "'custom_char_mesh_" .. tostring(index) .. "'",
									param3 = "'" .. unit .. "'"
								}

								table.insert( sequence, extra_unit )
							end
						end
					end

					table.insert( data[1], sequence )

					local temp_mask_on_sequence = {
						_meta = "sequence",
						editable_state = "true",
						name = "'" .. self._config.blackmarket.mask_on_sequence .. "'",
						triggable = "true"
					}

					local temp_mask_off_sequence = {
						_meta = "sequence",
						editable_state = "true",
						name = "'" .. self._config.blackmarket.mask_off_sequence .. "'",
						triggable = "true"
					}

					table.insert( data[1], temp_mask_on_sequence )
					table.insert( data[1], temp_mask_off_sequence )

					-- Scrub and tux stuff because they are unique inbetween heisters even with this annoying single model one!
					if ( self._config.blackmarket.npc_unit == "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1" ) then
						for seq_index, filter in pairs(data[1]) do
							if filter.name == "'is_" .. self._config.based_on .. "'" then
								filter[1].value = filter[1].value .. " or (dest_unit:parent() or dest_unit):base():character_name() == '" .. self._config.id .. "'"
							end
						end
					end
				end
			elseif ids_path == Idstring("units/payday2/characters/fps_criminals_suit_1/fps_criminals_suit_1") then
				if self._config.fps_unit or self._config.unit then
					local sequence = {
						_meta = "sequence",
						editable_state = "true",
						name = "'" .. self._config.blackmarket.sequence .. "'",
						triggable = "true",
						{
							_meta = "function",
							extension = "'spawn_manager'",
							["function"] = "'spawn_and_link_unit_nosync_load'",
							param1 = "'_char_joint_names'",
							param2 = "'custom_char_mesh'",
							param3 = "'" .. (self._config.fps_unit or self._config.unit) .. "'"
						}
					}

					if self._config.extra_fps_units then
						if type(index) == "number" then
							for index, unit in pairs(self._config.extra_fps_units) do
								local extra_unit = {
									_meta = "function",
									extension = "'spawn_manager'",
									["function"] = "'spawn_and_link_unit_nosync_load'",
									param1 = "'_char_joint_names'",
									param2 = "'custom_char_mesh_" .. index .. "'",
									param3 = "'" .. unit .. "'"
								}

								table.insert( sequence, extra_unit )
							end
						end
					end

					local objects_to_hide = {
						"g_body",
						"g_body_jacket",
						"g_hands",
						"g_body_jiro",
						"g_body_bodhi",
						"g_body_jimmy",
						"g_body_terry",
						"g_body_myh"
					}

					for index, object_name in pairs( objects_to_hide ) do
						local object_hider = {
							_meta = "object",
							enabled = "false",
							name = "'" .. object_name .. "'"
						}

						table.insert( sequence, object_hider )
					end

					table.insert( data[1], sequence )

					-- Scrub and tux stuff because they are unique inbetween heisters even with this annoying single model one!
					for seq_index, filter in pairs(data[1]) do
						if filter.name == "'is_" .. self._config.based_on .. "'" then
							filter[1].value = filter[1].value .. " or (dest_unit:parent() or dest_unit):base():character_name() == '" .. self._config.id .. "'"
						end
					end
				end
			end
		end
	end )

end