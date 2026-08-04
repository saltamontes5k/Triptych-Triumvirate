-- #Aaryonar NPCID: 124010
function event_combat(e)
	if e.joined then
		-- also aggro Kal`Vunar (124016) and Nir`Tan (124012) if they are up
		local entity_list = eq.get_entity_list();
		local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124016);
		local add_2	= entity_list:IsMobSpawnedByNpcTypeID(124012);

		if add_1 then
			entity_list:GetNPCByNPCTypeID(124016):CastToNPC():AddToHateList(e.other, 1);
		elseif add_2 then
			entity_list:GetNPCByNPCTypeID(124012):CastToNPC():AddToHateList(e.other, 1);
		end
	end
end