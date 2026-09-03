local BROWN_TYPES = {
	1500000029, -- a_Thul_Tae_Ew_zealot
	1500000152, -- A_Thul_Tae_Ew_Tracker
	1500000167, -- a_Thul_Tae_Ew_protector
	1500000041, -- a_Thul_Tae_Ew_lifestealer
	1500000027, -- a_Thul_Tae_Ew_justicar 
	1500000008, -- a_Thul_Tae_Ew_judicator
	1500000170, -- A_Thul_Tae_Ew_Hunter
	1500000151, -- A_Thul_Tae_Ew_Hunter
	1500000043, -- a_Thul_Tae_Ew_fanatic
	1500000026, -- a_Thul_Tae_Ew_defender
	1500000039, -- a_Thul_Tae_Ew_bloodcaller
};
function event_encounter_load(e)

	for _, id in ipairs(BROWN_TYPES) do
		eq.register_npc_event("BlackOoze", Event.death, id, function(e)
			if ( math.random(1, 2) == 1 ) then
				eq.spawn2(1500000140, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0);
			end
		end);
	end
end
