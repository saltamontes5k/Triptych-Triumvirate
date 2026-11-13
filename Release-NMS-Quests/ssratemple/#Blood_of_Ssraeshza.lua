function event_spawn(e)
	-- Exactly one Blood of Ssraeshza may stand: the static spawn2 row, #EmpCycle and the Emperor
	-- encounter can each create it (the row's unique_spawn_by_name flag is not implemented by the
	-- server, so it cannot dedupe on its own). Remove any other copy that is not in combat.
	local npc_list = eq.get_entity_list():GetNPCList();
	if npc_list then
		for npc in npc_list.entries do
			if npc:GetNPCTypeID() == 162189 and npc:GetID() ~= e.self:GetID() and not npc:IsEngaged() then
				eq.debug("Blood of Ssraeshza: removing duplicate copy");
				npc:Depop();
			end
		end
	end
end
function event_combat(e)
if e.joined then
eq.spawn2(162280, 0, 0, 625, -356,  403,  0); --Ssraezsha (162280)
eq.spawn2(162280, 0, 0, 689, -356,  403,  0); --Ssraezsha (162280)
eq.spawn2(162280, 0, 0, 689, -293,  403,  0); --Ssraezsha (162280)
eq.spawn2(162280, 0, 0, 625, -293,  403,  0); --Ssraezsha (162280)
end
end

function event_death_complete(e)
eq.signal(162260,1); -- #EmpCycle
end
