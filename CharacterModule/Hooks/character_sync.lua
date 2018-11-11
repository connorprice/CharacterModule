function NetworkPeer:check_peer_preferred_character()
	local free_characters = clone(CriminalsManager.character_names())
	local peers_table = managers.network and managers.network:session() and managers.network:session():peers()
	for _, peer in pairs(peers_table) do
		local character = peer:character()
		table.delete(free_characters, character)
	end
	return free_characters[math.random(#free_characters)]
end

function CharactersModuleSync_Fix(peer, d1, d2, d3, d4, d5, d6, d7, d8, d9, ...)
	local _d1 = tostring(d1)
	if _d1 == "set_unit" and tweak_data.blackmarket.characters[d3] and tweak_data.blackmarket.characters[d3].custom then
		d3 = peer:check_peer_preferred_character()
	elseif _d1 == "sync_outfit" then
		local list = managers.blackmarket:unpack_outfit_from_string(d2)
		local chara = tostring(list.character)
		if not tweak_data.blackmarket.characters[chara] or tweak_data.blackmarket.characters[chara].custom then
			list.character = "locked"
			d2 = BeardLib.Utils:OutfitStringFromList(list)
		end
	elseif _d1 == "lobby_info" then
		local chara = tostring(d4)
		if not tweak_data.blackmarket.characters[chara] or tweak_data.blackmarket.characters[chara].custom then
			local based_on = tweak_data.blackmarket.characters[chara] and tweak_data.blackmarket.characters[chara].based_on or nil
			if based_on then
				for char_name, data in pairs(Global.blackmarket_manager.characters) do
					if data and not data.equipped and char_name ~= based_on and tweak_data.blackmarket.characters[char_name] and tweak_data.blackmarket.characters[char_name].fps_unit then
						d4 = char_name
						break
					end
				end
			else
				d4 = peer:check_peer_preferred_character()
			end
		end
	elseif _d1 == "join_request_reply" then
		local chara = tostring(d9)
		if not tweak_data.blackmarket.characters[chara] or tweak_data.blackmarket.characters[chara].custom then
			local based_on = tweak_data.blackmarket.characters[chara] and tweak_data.blackmarket.characters[chara].based_on or nil
			if based_on then
				for char_name, data in pairs(Global.blackmarket_manager.characters) do
					if data and not data.equipped and char_name ~= based_on and tweak_data.blackmarket.characters[char_name] and tweak_data.blackmarket.characters[char_name].fps_unit then
						d9 = char_name
						break
					end
				end
			else
				d9 = peer:check_peer_preferred_character()
			end
		end
	end
	return d1, d2, d3, d4, d5, d6, d7, d8, d9, ...
end

local CharactersModuleSync_Net_send = NetworkPeer.send
function NetworkPeer:send(...)
	return CharactersModuleSync_Net_send(self, CharactersModuleSync_Fix(self, ...))
end

local CharactersModuleSync_Net_send_queued_sync = NetworkPeer.send_queued_sync
function NetworkPeer:send_queued_sync(...)
	return CharactersModuleSync_Net_send_queued_sync(self, CharactersModuleSync_Fix(self, ...))
end