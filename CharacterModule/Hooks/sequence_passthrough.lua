CoreUnitDamage.spawn_prop = ""

Hooks:PostHook( CoreUnitDamage, "run_sequence", "CharacterModuleSequencePassthrough", function( self, name, ... ) 
	local spawn_manager = self._unit:spawn_manager()
	if not spawn_manager then return end

	if not self.var_mtr_ran then
		if string.match( name, "spawn_prop" ) then
			self.spawn_prop = name
			return
		elseif string.match( name, "var_mtr" ) then
			for unit_id, unit_entry in pairs(spawn_manager:spawned_units()) do
				local unit = unit_entry.unit
				if alive(unit) and unit:damage() then
					log(tostring(self.spawn_prop))
					unit:damage():run_sequence( self.spawn_prop, ... )
					self.var_mtr_ran = true
					return
				end
			end
		end
	end

	for unit_id, unit_entry in pairs(spawn_manager:spawned_units()) do
		local unit = unit_entry.unit
		if alive(unit) and unit:damage() then
			unit:damage():run_sequence( name, ... )
			return
		end
	end
end)