-- eastkorlach/#General_Veronhar.lua
-- Depths of Darkhollow: the Undershore raid boss, General Veronhar (362090).
--
-- Encounter (raspersrealm, "Events and Raids"): Veronhar fights alongside his
-- two Commanders -- #Commander_Zygurth (362088) and #Commander_Rygaz (362091),
-- who hit for ~1000 and have low health.  During the fight the General orders
-- them to switch targets at random, casts General's Charge (PBAE dd + push,
-- spell 7464) and Seizure of Thought (AE stun, spell 7032), and calls out for
-- his archers to fire.  Loot is already authored on loottable 91766.
--
-- Note: the page gives no exact archer emote/duck text, so the volley is
-- telegraphed with an emote only; the commanders' target-swapping is the
-- distinctive mechanic and is modelled directly.

local GENERAL_CHARGE     = 7464;
local SEIZURE_OF_THOUGHT = 7032;
local COMMANDERS = { 362088, 362091 };

local engaged = false;

local function random_client()
	local cl = eq.get_entity_list():GetClientList();
	if not cl or #cl.entries == 0 then
		return nil;
	end
	local pick = cl.entries[math.random(#cl.entries)];
	if pick and pick.valid then
		return pick;
	end
	return nil;
end

function event_combat(e)
	if e.joined and not engaged then
		engaged = true;
		eq.set_timer("orders", 20000);
		eq.set_timer("charge", 14000);
		eq.set_timer("archers", 35000);
	end
end

function event_timer(e)
	if e.timer == "orders" then
		for _, id in ipairs(COMMANDERS) do
			local cmd = eq.get_entity_list():GetMobByNpcTypeID(id);
			if cmd and cmd.valid and cmd:IsEngaged() then
				local t = random_client();
				if t then
					cmd:AddToHateList(t, 6000);
				end
			end
		end
		e.self:Say("Commanders! Break their line - take whoever stands tallest!");
	elseif e.timer == "charge" then
		e.self:CastSpell(GENERAL_CHARGE, e.self:GetID());
		if math.random(1, 2) == 1 then
			e.self:CastSpell(SEIZURE_OF_THOUGHT, e.self:GetID());
		end
	elseif e.timer == "archers" then
		e.self:Say("Archers! Loose!");
		eq.zone_emote(MT.Yellow, "General Veronhar signals his archers - take cover!");
	end
end

function event_death_complete(e)
	engaged = false;
	eq.stop_timer("orders");
	eq.stop_timer("charge");
	eq.stop_timer("archers");
	eq.zone_emote(MT.Yellow, "General Veronhar has fallen. The Malgrinnor foothold in the Undershore is broken.");
end

function event_despawn(e)
	engaged = false;
	eq.stop_timer("orders");
	eq.stop_timer("charge");
	eq.stop_timer("archers");
end
