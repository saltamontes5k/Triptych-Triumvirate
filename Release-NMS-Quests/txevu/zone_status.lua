-- Texas Zone_Status NPCID 297140

local instance_id = 0;
local Txevu_Lockouts = {};

-- Events
local CHAMP_EVENT	= 'Mastruq Champion'
local HP_EVENT		= 'High Priest Nkosi Bakari'
local UKUN_EVENT	= 'Ukun Bloodfeaster'
local ACM_EVENT		= 'Ancient Cragbeast Matriarch'
local INL_EVENT		= 'Ikaav Nysf Lleiv'
local ZMTZ_EVENT	= 'Zun Muram Tkarish Zyk'

function setup_event()
	Txevu_Lockouts = {
		[297001] = {CHAMP_EVENT,eq.seconds('20h'), Spawn_Champ},
		[297212] = {HP_EVENT,	eq.seconds('20h'), Spawn_HP},
		[297082] = {UKUN_EVENT,	eq.seconds('20h'), Spawn_Ukun},
		[297056] = {ACM_EVENT,	eq.seconds('20h'), Spawn_ACM},
		[297090] = {INL_EVENT,	eq.seconds('20h'), Spawn_INL},
		[297150] = {ZMTZ_EVENT,	eq.seconds('20h'), Spawn_Zun}
	}
end

function event_spawn(e)
	local zone_id = eq.get_zone_id();
	instance_id = eq.get_zone_instance_id();
	local expedition = eq.get_expedition_by_zone_instance(zone_id,instance_id);

	if instance_id ~= 0 then
		setup_event();
	end

	for k,v in pairs(Txevu_Lockouts) do
		if v[3] and not expedition:HasLockout(v[1]) then
			v[3]() -- boss spawning function
		end
	end
end

function Spawn_Champ()
	eq.spawn2(297001,0,0,88,0,-420,0);	-- NPC: #Champ_Event
end

function Spawn_HP()
	eq.spawn2(297212,0,0,-720,346,-475,0);	-- NPC: #priest_trigger
end

function Spawn_Ukun()
	eq.spawn2(297082,0,0,270,446,-420.87,118);	-- NPC: #Ukun_Bloodfeaster
end

function Spawn_ACM()
	eq.spawn2(297056,0,0,627,0,-364.87,140.25);	-- NPC: #Ancient_Cragbeast_Matriarch
end

function Spawn_INL()
	eq.spawn2(297090,0,0,991,0,-372.87,387.5);	-- NPC: #Ikaav_Nysf_Lleiv
end

function Spawn_Zun()
	eq.spawn2(297150,0,0,1506.94,1.8,-285.87,374.75);	-- NPC: #Zun`Muram_Tkarish_Zyk
end

function AddLockout(lockout)
    local lockout_name = lockout[1];
    local lockout_duration = lockout[2];

    local expedition = eq.get_expedition()
    if expedition.valid then
        -- this should add the lockout to:
        -- 1) the expedition internally, so anyone that gets added after and zones in will receive it
        -- 2) all current members of the expedition, even if they're in another zone
        -- 3) all clients currently inside the dz instance in case members were removed but haven't been teleported out yet
        expedition:AddLockout(lockout_name, lockout_duration)
    end
end
