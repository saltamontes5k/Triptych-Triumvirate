-- Wel`Wnas (124092) NPCID: 124092
function event_combat(e)
	if e.joined then
		-- also aggro #Lady_Mirenilla (124077) and  Gra`Vloren (124091) if they are up
		local entity_list = eq.get_entity_list();
		local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124077);
		local add_2	= entity_list:IsMobSpawnedByNpcTypeID(124091);

		if add_1 then
			entity_list:GetNPCByNPCTypeID(124077):CastToNPC():AddToHateList(e.other, 1);
		end
		
		if add_2 then
			entity_list:GetNPCByNPCTypeID(124091):CastToNPC():AddToHateList(e.other, 1);
		end
	end
end