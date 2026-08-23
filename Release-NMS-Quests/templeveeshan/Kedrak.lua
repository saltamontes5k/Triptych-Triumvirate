-- Kedrak NPCID: 124093
function event_combat(e)
	if e.joined then
		-- also aggro #Lord_Kreizenn (124074) and Carx`Vean (124094) if they are up
		local entity_list = eq.get_entity_list();
		local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124074);
		local add_2	= entity_list:IsMobSpawnedByNpcTypeID(124094);

		if add_1 then
			entity_list:GetNPCByNPCTypeID(124074):CastToNPC():AddToHateList(e.other, 1);
		end
		
		if add_2 then
			entity_list:GetNPCByNPCTypeID(124094):CastToNPC():AddToHateList(e.other, 1);
		end
	end
end
