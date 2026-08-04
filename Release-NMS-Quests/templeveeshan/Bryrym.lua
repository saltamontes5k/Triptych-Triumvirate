-- Bryrym NPCID: 124005
function event_combat(e)
	if e.joined then
		-- also aggro #Lord_Feshlak (124008) and Vukuz (124015) if they are up
		local entity_list = eq.get_entity_list();
		local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124008);
		local add_2	= entity_list:IsMobSpawnedByNpcTypeID(124015);

		if add_1 then
			entity_list:GetNPCByNPCTypeID(124008):CastToNPC():AddToHateList(e.other, 1);
		end
		
		if add_2 then
			entity_list:GetNPCByNPCTypeID(124015):CastToNPC():AddToHateList(e.other, 1);
		end
	end
end