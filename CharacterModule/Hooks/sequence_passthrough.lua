-- Store commands that are done before we attach our character.
CoreUnitDamage.sequence_backlog = {}
CoreUnitDamage.backlog_handled = false

Hooks:PostHook( CoreUnitDamage, "run_sequence", "CharacterModuleSequencePassthrough", function( self, sequence_name, endurance_type, source_unit, dest_body, normal, position, direction, damage, velocity, params )
	local spawn_manager = self._unit:spawn_manager()
	if not spawn_manager then return end

	local spawned_units = spawn_manager:spawned_units()

	if table.size(spawned_units) == 0 then
		table.insert(self.sequence_backlog, { sequence_name, endurance_type, source_unit, dest_body, normal, position, direction, damage, velocity, params } )
		return
	end

	if not self.backlog_handled then
		for _, seq_data in pairs(self.sequence_backlog) do
			for unit_id, unit_entry in pairs( spawn_manager:spawned_units() ) do
				local unit = unit_entry.unit
				if unit:damage() then
					unit:damage():run_sequence( seq_data[1], seq_data[2], seq_data[3], seq_data[4], seq_data[5], seq_data[6], seq_data[7], seq_data[8], seq_data[9], seq_data[10] )
				end
			end
		end

		self.backlog_handled = true
	end

	for unit_id, unit_entry in pairs( spawn_manager:spawned_units() ) do
		local unit = unit_entry.unit
		if unit:damage() then
			unit:damage():run_sequence( sequence_name, endurance_type, source_unit, dest_body, normal, position, direction, damage, velocity, params )
		end
	end
end)