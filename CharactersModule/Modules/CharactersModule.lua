CharactersModule = CharactersModule or class(ItemModuleBase)

function CharactersModule:init(core_mod, config)
	if not CharactersModule.super.init(self, core_mod, config) then
		return false
	end
	return true
end

function CharactersModule:RegisterHook()
	Hooks:PostHook(CharacterTweakData, "init", self._config.id..Idstring("CharactersModuleCharacterTweakDatainit"):key(), function(char_self)
		if char_self[self._config.id] then
			BeardLib:log("[ERROR] CharacterTweakData with id '%s' already exists!", self._config.id)
			return
		end
		local presets = char_self.presets
		char_self[self._config.id] = {
			damage = presets.gang_member_damage,
			weapon = deep_clone(presets.weapon.gang_member)
		}
		char_self[self._config.id].weapon.weapons_of_choice = {
			primary = "wpn_fps_ass_m4_npc",
			secondary = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
		}
		char_self[self._config.id].detection = presets.detection.gang_member
		char_self[self._config.id].move_speed = presets.move_speed.very_fast
		char_self[self._config.id].crouch_move = false
		char_self[self._config.id].speech_prefix = self._config.speech_prefix
		char_self[self._config.id].weapon_voice = self._config.weapon_voice
		char_self[self._config.id].access = self._config.access
		char_self[self._config.id].arrest = {
			timeout = 240,
			aggression_timeout = 6,
			arrest_timeout = 240
		}
	end)
	Hooks:PostHook(BlackMarketTweakData, "_init_characters", self._config.id..Idstring("CharactersModuleBlackMarketTweakData_init_characters"):key(), function(bmc_self, tweak_data)
		if bmc_self.characters[self._config.id] then
			BeardLib:log("[ERROR] BlackMarketTweakData with id '%s' already exists!", self._config.id)
			return
		end
		if type(bmc_self.characters[self._config.based_on]) ~= "table" then
			bmc_self.characters[self._config.id] = {
				fps_unit = "units/payday2/characters/fps_mover/fps_mover",
				npc_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1",
				menu_unit = "units/payday2/characters/npc_criminals_suit_1/npc_criminals_suit_1_menu",
				name_id = "bm_character_locked",
				sequence = "var_mtr_dallas",
				mask_on_sequence = "mask_on",
				mask_off_sequence = "mask_off"
			}
		else
			bmc_self.characters[self._config.id] = deep_clone(bmc_self.characters[self._config.based_on])
		end
		bmc_self.characters[self._config.id].name_id = self._config.name_id
		bmc_self.characters[self._config.id].desc_id = self._config.desc_id		
		bmc_self.characters[self._config.id].based_on = self._config.based_on
		bmc_self.characters[self._config.id].custom = true
		bmc_self.characters[self._config.id].sequence = self._config.sequence
		if self._config.mask_on_sequence then
			bmc_self.characters[self._config.id].mask_on_sequence = self._config.mask_on_sequence
		end
		if self._config.mask_off_sequence then
			bmc_self.characters[self._config.id].mask_off_sequence = self._config.mask_off_sequence
		end
		if self._config.texture_bundle_folder then
			bmc_self.characters[self._config.id].texture_bundle_folder = self._config.texture_bundle_folder
		end
		
		bmc_self.characters["ai_"..self._config.id] = deep_clone(bmc_self.characters[self._config.id])
		
		local _characters = table.size(tweak_data.criminals.characters) + 1
		tweak_data.criminals.characters[_characters] = {
			name = self._config.id,
			order = _characters+1,
			static_data = {
				voice = self._config.static_data_voice or "",
				ai_mask_id = "dallas",
				ai_character_id = "ai_"..self._config.id,
				ssuffix = self._config.static_data_ssuffix or "v"
			},
			body_g_object = Idstring("g_body")
		}
		table.insert(tweak_data.criminals.character_names, self._config.id)
	end)
	Hooks:PostHook(EconomyTweakData, "init", self._config.id..Idstring("CharactersModuleEconomyTweakData"):key(), function(eco_self)
		eco_self.character_cc_configs[self._config.id] = eco_self.character_cc_configs[self._config.based_on]
	end)
	Hooks:PostHook(GuiTweakData, "init", self._config.id..Idstring("CharactersModuleGuiTweakData"):key(), function(gui_self)
		table.insert(gui_self.crime_net.codex[2], {
			{
				desc_id = self._config.desc_id,
				post_event = "loc_quote_set_a",
				videos = {"locke1"}
			},
			name_id = self._config.name_id,
			id = self._config.id
		})
	end)
	Hooks:PostHook(BlackMarketTweakData, "_init_masks", self._config.id..Idstring("CharactersModuleBlackMarketTweakData_init_masks"):key(), function(bmm_self)
		bmm_self.masks.character_locked[self._config.id] = self._config.default_mask
		for mask_id, mask_data in pairs(bmm_self.masks) do
			for type_id in pairs({"characters", "offsets"}) do
				if mask_data[type_id] and mask_data[type_id][self._config.id] then
					bmm_self.masks[mask_id][type_id][self._config.id] = deep_clone(mask_data[type_id][self._config.id])
				end
			end
		end
	end)
end