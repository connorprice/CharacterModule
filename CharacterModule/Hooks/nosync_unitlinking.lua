function ManageSpawnedUnits:spawn_unit_nosync(unit_id, align_obj_name, unit)
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

function ManageSpawnedUnits:spawn_and_link_unit_nosync(joint_table, unit_id, unit)
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

	self:spawn_unit_nosync(unit_id, self[joint_table][1], unit)

	self._nosync_spawn_and_link = self._nosync_spawn_and_link or {}
	self._nosync_spawn_and_link[unit_id] = {
		unit = unit,
		joint_table = joint_table
	}

	self:_link_joints(unit_id, joint_table)
end

function ManageSpawnedUnits:spawn_and_link_unit_nosync_load(joint_table, unit_id, unit)
	if not managers.dyn_resource then return end
	managers.dyn_resource:load(Idstring("unit"), Idstring(unit), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self:spawn_and_link_unit_nosync( joint_table, unit_id, unit )
end


function ManageSpawnedUnits:remove_unit_nosync(unit_id)
	local entry = self._spawned_units[unit_id]
	if entry then
		entry.unit:set_slot(0)

		self._spawned_units[unit_id] = nil
	end
end

function ManageSpawnedUnits:linked_units()
	local linked_units = deep_clone(self._nosync_spawn_and_link or {})

	for k,v in pairs(self._sync_spawn_and_link or {}) do linked_units[k] = v end

	return linked_units
end

function ManageSpawnedUnits:hide_object_nosync(object_name)
	local object = self._unit:get_object( Idstring( object_name ) )

	if object then
		object:set_visibility( false )
	end
end