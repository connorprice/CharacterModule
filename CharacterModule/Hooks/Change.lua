function ManageSpawnedUnits:spawn_unit(unit_id, align_obj_name, unit)
	local align_obj = self._unit:get_object(Idstring(align_obj_name))
	local spawn_unit = nil

	if type_name(unit) == "string" then
        local spawn_pos = align_obj:position()
        local spawn_rot = align_obj:rotation()
        spawn_unit = safe_spawn_unit(Idstring(unit), spawn_pos, spawn_rot)
        spawn_unit:unit_data().parent_unit = self._unit
	else
		spawn_unit = unit
	end

	if not spawn_unit then
		return
	end

	self._unit:link(Idstring(align_obj_name), spawn_unit, spawn_unit:orientation_object():name())

	local unit_entry = {
		align_obj_name = align_obj_name,
		unit = spawn_unit
	}
	self._spawned_units[unit_id] = unit_entry
end

function ManageSpawnedUnits:spawn_and_link_unit(joint_table, unit_id, unit)
	if self._spawned_units[unit_id] then
		return
	end
	if not self[joint_table] then
		return
	end
	if not unit_id then
		return
	end
	if not unit then
		return
	end
	self:spawn_unit(unit_id, self[joint_table][1], unit)
	self._sync_spawn_and_link = self._sync_spawn_and_link or {}
	self._sync_spawn_and_link[unit_id] = {
		unit = unit,
		joint_table = joint_table
	}
	self:_link_joints(unit_id, joint_table)
	if Network:is_server() and not self.local_only then
		managers.network:session():send_to_peers_synched("sync_link_spawned_unit", self._unit, unit_id, joint_table, "spawn_manager")
	end
end

function ManageSpawnedUnits:spawn_and_link_unit_alt(joint_table, unit_id, unit)
	self:spawn_and_link_unit(joint_table, unit_id, unit)
	self._sync_spawn_and_link[unit_id] = nil
end