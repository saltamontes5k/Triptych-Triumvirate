-- High Inquisitor Xeru: custom Seru-clone bonus boss (npc 1120002172).
-- Script-spawned at Seru's bind point when either Lord Inquisitor Seru form
-- (159690 first form / 159691 leash form) dies, in the live zone or an
-- instance. Unkilled Xerus despawn after two hours. Fragment loot is granted
-- here only, never from the loot table.

local xeru_id        = 1120002172;
local lt_matpa_id     = 159114;
local lt_rhugol_id    = 159112;
local lt_vantorus_id  = 159113;
local lt_bikun_id     = 159115;

local seru_form_ids = { 159690, 159691 };
local seru_bind     = { x = -231.464, y = -432.937, z = 202.375, h = 0.25 };

local xeru_despawn_ms      = 2 * 60 * 60 * 1000;
local xeru_despawn_recheck = 60 * 1000;

local add_thresholds = { 80, 60, 50, 40 };

local spell_torturing_winds    = 2061;
local spell_rune_iii           = 483;
local spell_xeru_authority     = 36838;
local spell_shield_of_truth    = 36832;

local first_event_hp = 98;

local winds_interval_min_ms = 50 * 1000;
local winds_interval_max_ms = 60 * 1000;

local buffed_resist       = 250;
local buffed_resist_stats = { "mr", "fr", "cr", "pr", "cor" };

local xeru_title_set = 213;

local fragment_ids = { 9536, 9537, 9538, 9539, 9540, 9541, 9542, 9543, 9544, 9545, 9547, 9548 };
local QUALITY_BASE      = 0;
local QUALITY_ENCHANTED = 1000000;
local QUALITY_LEGENDARY = 2000000;

local quality_floor = QUALITY_ENCHANTED;

local loot_tiers = {
	[0] = {
		{ chance = 10,  quality = { base = 100, enchanted = 0,  legendary = 0  } },
	},
	[1] = {
		{ chance = 40,  quality = { base = 90,  enchanted = 10, legendary = 0  } },
	},
	[2] = {
		{ chance = 100, quality = { base = 70,  enchanted = 25, legendary = 5  } },
		{ chance = 15,  quality = { base = 100, enchanted = 0,  legendary = 0  } },
	},
	[3] = {
		{ chance = 100, quality = { base = 40,  enchanted = 50, legendary = 10 } },
		{ chance = 100, quality = { base = 40,  enchanted = 55, legendary = 5 } },
		{ chance = 20,  quality = { base = 60,  enchanted = 35, legendary = 5  } },
	},
	[4] = {
		{ chance = 100, quality = { base = 0,   enchanted = 80, legendary = 20 } },
		{ chance = 100, quality = { base = 0,   enchanted = 80, legendary = 20 } },
		{ chance = 30,  quality = { base = 55,  enchanted = 40, legendary = 5 } },
	},
};

local engaged_this_pull    = false;
local shield_of_truth_used = false;
local alive_at_pull = 0;
local eligible    = {};
local displaced   = {};
local add_spawned = {};
local add_died    = {};
local spawn_point = {};
local add_order   = {};
local base_max_hp = {};
local base_resists = nil;

function evt_xeru_spawn(e)
	engaged_this_pull    = false;
	shield_of_truth_used = false;
	alive_at_pull = 0;
	eligible    = {};
	displaced   = {};
	add_spawned = {};
	add_died    = {};
	add_order   = {};
	base_resists = nil;

	eq.set_next_hp_event(first_event_hp);
	eq.set_timer("xeru_despawn", xeru_despawn_ms);
	e.self:ApplySpellBuff(spell_rune_iii);
end

function evt_seru_death_complete(e)
	local existing = eq.get_entity_list():GetNPCByNPCTypeID(xeru_id);
	if existing.valid then
		return;
	end

	eq.spawn2(xeru_id, 0, 0, seru_bind.x, seru_bind.y, seru_bind.z, seru_bind.h);
	eq.zone_emote(15, "The Praesertum cry out as High Inquisitor Xeru, phantom of the fallen Inquisitor, takes form!");
end

function evt_xeru_combat(e)
	if e.joined then
		if engaged_this_pull then
			return;
		end
		engaged_this_pull = true;

		e.self:Shout("You dare challenge the Lord Inquisitor?! The Praesertum will see to your end!");
		shuffle_add_order();

		local alive_count = 0;
		for lt_id, lt in pairs(lieutenants) do
			local mob = eq.get_entity_list():GetNPCByNPCTypeID(lt_id);
			if mob.valid then
				eligible[lt_id] = true;
				alive_count = alive_count + 1;
				e.self:ApplySpellBuff(lt.blessing);
			else
				eligible[lt_id] = false;
			end
		end
		alive_at_pull = alive_count;
		apply_lieutenant_resists(e.self, alive_count);

		if alive_count > 0 then
			e.self:SpellFinished(spell_torturing_winds, e.self);
			schedule_winds();
		end
	else
		e.self:Shout("Flee, heretics, flee for your lives! I remain here, absolute and unbroken!");
		reset_encounter(e);
	end
end

function schedule_winds()
	eq.set_timer("xeru_winds", math.random(winds_interval_min_ms, winds_interval_max_ms));
end

function evt_xeru_timer(e)
	if e.timer == "xeru_despawn" then
		if e.self:IsEngaged() then
			eq.set_timer("xeru_despawn", xeru_despawn_recheck);
		else
			eq.zone_emote(15, "High Inquisitor Xeru fades, his vigil untested.");
			e.self:Depop();
		end
		return;
	end

	if e.timer ~= "xeru_winds" then
		return;
	end

	if not engaged_this_pull or alive_at_pull == 0 then
		eq.stop_timer("xeru_winds");
		return;
	end

	e.self:SpellFinished(spell_torturing_winds, e.self);
	schedule_winds();
end

function apply_lieutenant_resists(xeru, alive_count)
	if base_resists == nil then
		base_resists = {};
		for _, stat in ipairs(buffed_resist_stats) do
			base_resists[stat] = xeru:GetNPCStat(stat);
		end
	end

	for _, stat in ipairs(buffed_resist_stats) do
		local base  = base_resists[stat];
		local boost = math.max(buffed_resist - base, 0) * alive_count / 4;
		xeru:ModifyNPCStat(stat, string.format("%d", math.floor(base + boost + 0.5)));
	end
end

function restore_resists(xeru)
	if base_resists == nil then
		return;
	end

	for _, stat in ipairs(buffed_resist_stats) do
		xeru:ModifyNPCStat(stat, string.format("%d", base_resists[stat]));
	end
end

function evt_xeru_hp(e)
	local hp = e.hp_event;

	local add_lt_id = add_order[hp];
	if add_lt_id ~= nil then
		if spawn_add(e, add_lt_id, lieutenants[add_lt_id]) then
			e.self:SpellFinished(spell_xeru_authority, e.self);
		end
	end

	if hp == 20 and alive_at_pull > 0 and not shield_of_truth_used then
		shield_of_truth_used = true;
		e.self:ApplySpellBuff(spell_shield_of_truth);
	end

	local next_hp = next_hp_step(hp);
	if next_hp > 0 then
		eq.set_next_hp_event(next_hp);
	end
end

function next_hp_step(hp)
	if hp % 5 ~= 0 then
		return hp - (hp % 5);
	end
	return hp - 5;
end

function shuffle_add_order()
	local ids = {};
	for lt_id, _ in pairs(lieutenants) do
		table.insert(ids, lt_id);
	end

	for i = #ids, 2, -1 do
		local j = math.random(i);
		ids[i], ids[j] = ids[j], ids[i];
	end

	add_order = {};
	for i, hp_pct in ipairs(add_thresholds) do
		add_order[hp_pct] = ids[i];
	end
end

function spawn_add(e, lt_id, lt)
	if not eligible[lt_id] or add_spawned[lt_id] then
		return false;
	end
	add_spawned[lt_id] = true;

	if lt.xeru_shout ~= nil then
		e.self:Shout(lt.xeru_shout);
	end

	local mob = eq.get_entity_list():GetNPCByNPCTypeID(lt_id);
	if mob.valid then
		displaced[lt_id]   = true;
		spawn_point[lt_id] = mob:GetSpawnPointID();
		mob:GMMove(e.self:GetX() + math.random(-15, 15), e.self:GetY() + math.random(-15, 15), e.self:GetZ(), e.self:GetHeading(), false);

		if base_max_hp[lt_id] == nil then
			base_max_hp[lt_id] = mob:GetNPCStat("max_hp");
		end
		mob:ModifyNPCStat("max_hp", string.format("%d", lt.add_hp));
		mob:SetHP(mob:GetMaxHP());

		if lt.add_shout ~= nil then
			mob:Shout(lt.add_shout);
		end

		local tank = e.self:GetHateTop();
		if tank.valid then
			mob:AddToHateList(tank, 500);
		end
		return true;
	end
	return false;
end

function restore_lieutenants(respawn_dead, force_move)
	for lt_id, lt in pairs(lieutenants) do
		if displaced[lt_id] then
			local mob = eq.get_entity_list():GetNPCByNPCTypeID(lt_id);
			if mob.valid and (force_move or not mob:IsEngaged()) then
				mob:WipeHateList();
				mob:BuffFadeAll();
				if base_max_hp[lt_id] ~= nil then
					mob:ModifyNPCStat("max_hp", string.format("%d", base_max_hp[lt_id]));
					base_max_hp[lt_id] = nil;
				end
				mob:SetHP(mob:GetMaxHP());
				mob:GMMove(lt.x, lt.y, lt.z, lt.h, false);
				displaced[lt_id] = false;
			end
		elseif respawn_dead and add_died[lt_id] then
			if spawn_point[lt_id] ~= nil and spawn_point[lt_id] > 0 then
				eq.spawn_from_spawn2(spawn_point[lt_id]);
			end
			add_died[lt_id] = false;
		end

		add_spawned[lt_id] = false;
		eligible[lt_id]    = false;
	end
	add_order = {};
end

function reset_encounter(e)
	eq.stop_timer("xeru_winds");
	e.self:WipeHateList();
	e.self:GotoBind();
	e.self:BuffFadeAll();
	e.self:SetHP(e.self:GetMaxHP());
	e.self:ApplySpellBuff(spell_rune_iii);
	restore_resists(e.self);

	restore_lieutenants(true, true);

	engaged_this_pull    = false;
	shield_of_truth_used = false;
	alive_at_pull        = 0;
	eq.set_next_hp_event(first_event_hp);
end

function roll_quality(weights)
	local roll = math.random(100);
	local quality;
	if roll <= weights.base then
		quality = QUALITY_BASE;
	elseif roll <= weights.base + weights.enchanted then
		quality = QUALITY_ENCHANTED;
	else
		quality = QUALITY_LEGENDARY;
	end
	return math.max(quality, quality_floor);
end

function grant_fragments_of_truth(e, tier)
	local rolls = loot_tiers[tier];
	if rolls == nil then
		return;
	end

	local available = {};
	for _, id in ipairs(fragment_ids) do
		table.insert(available, id);
	end

	for _, roll in ipairs(rolls) do
		if #available > 0 and math.random(100) <= roll.chance then
			local idx = math.random(#available);
			local base_id = available[idx];
			table.remove(available, idx);

			e.self:AddItem(base_id + roll_quality(roll.quality), 1);
		end
	end
end

function grant_kill_titles(e)
	for hate_entry in e.self:GetHateList().entries do
		local mob = hate_entry.ent;
		if mob.valid and mob:IsClient() then
			mob:CastToClient():EnableTitleSet(xeru_title_set);
		end
	end
end

function evt_xeru_death(e)
	eq.stop_timer("xeru_winds");
	grant_kill_titles(e);

	local tier = 0;
	for lt_id, _ in pairs(lieutenants) do
		if eligible[lt_id] then
			tier = tier + 1;
		end
	end

	grant_fragments_of_truth(e, tier);
end

function evt_xeru_death_complete(e)
	e.self:Shout("Impossible... I am absolute--");

	restore_lieutenants(false, false);

	engaged_this_pull    = false;
	shield_of_truth_used = false;
	alive_at_pull        = 0;
end

function evt_add_death_complete(e)
	local lt_id = e.self:GetNPCTypeID();
	displaced[lt_id]   = false;
	base_max_hp[lt_id] = nil;
	if add_spawned[lt_id] then
		add_died[lt_id] = true;
	end
end

function event_encounter_load(e)
	eq.register_npc_event("xeru_custom", Event.spawn,          xeru_id, evt_xeru_spawn);
	eq.register_npc_event("xeru_custom", Event.combat,         xeru_id, evt_xeru_combat);
	eq.register_npc_event("xeru_custom", Event.hp,             xeru_id, evt_xeru_hp);
	eq.register_npc_event("xeru_custom", Event.timer,          xeru_id, evt_xeru_timer);
	eq.register_npc_event("xeru_custom", Event.death,          xeru_id, evt_xeru_death);
	eq.register_npc_event("xeru_custom", Event.death_complete, xeru_id, evt_xeru_death_complete);

	for _, seru_id in ipairs(seru_form_ids) do
		eq.register_npc_event("xeru_custom", Event.death_complete, seru_id, evt_seru_death_complete);
	end

	for lt_id, _ in pairs(lieutenants) do
		eq.register_npc_event("xeru_custom", Event.death_complete, lt_id, evt_add_death_complete);
	end
end
