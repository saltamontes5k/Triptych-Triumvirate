-- bazaar/#Sage_of_Anachronism.lua
-- The Fabled Encounters requester (npc 151062, lastname "Fabled
-- Encounters", upper floor of the Bazaar). Offers the Fabled expeditions
-- listed in FABLED_EXPEDITIONS below. Gates use the progression stages
-- from nms_progression (PREREQ map) plus optional per-boss subflags
-- recorded by each Fabled kill under the FNagafen stage:
--   fabled_nagafen / fabled_vox  -> FRoK complete
--   fabled_trakanon / fabled_gorenaire / fabled_severilous /
--   fabled_talendor              -> FSoV complete
-- The live gate for Fabled Nagafen/Vox is FNagafen (Quarm dead) -- the
-- design sheet's tier rows only describe future program ordering.
-- Fabled instances run at zone version 2+ (one expedition version per
-- zone, requested here and gated in each zone's player.pl).

local prog = require("nms_progression");

local FABLED_STAGE = "FNagafen";

local FABLED_EXPEDITIONS = {
	{
		key          = "nagafen",
		saylink      = "Fabled Lord Nagafen",
		name         = "The Fabled Lord Nagafen",
		zone         = "soldungb",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_stage   = "FNagafen",
		deny_message = "The Sage shakes his head. The memory of the Fire Lord will not stir for you yet. Only one who has stood in the Plane of Time and watched Quarm fall may wake it.",
		enabled      = true,
	},
	{
		key          = "vox",
		saylink      = "Fabled Lady Vox",
		name         = "The Fabled Lady Vox",
		zone         = "permafrost",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_stage   = "FNagafen",
		deny_message = "The Sage shakes his head. The Ice Queen's memory will not wake for you yet. Only one who has stood in the Plane of Time and watched Quarm fall may rouse her.",
		enabled      = true,
	},
	{
		key          = "trakanon",
		saylink      = "Fabled Trakanon",
		name         = "The Fabled Trakanon",
		zone         = "sebilis",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_subflags = { "fabled_nagafen", "fabled_vox" },
		deny_message = "The Sage shakes his head. The Devourer sleeps until the first memories fall: the Fabled Lord Nagafen and the Fabled Lady Vox must both be laid to rest.",
		enabled      = true,
	},
	{
		key          = "gorenaire",
		saylink      = "Fabled Gorenaire",
		name         = "The Fabled Gorenaire",
		zone         = "dreadlands",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_subflags = { "fabled_nagafen", "fabled_vox" },
		deny_message = "The Sage shakes his head. The Storm Queen sleeps until the first memories fall: the Fabled Lord Nagafen and the Fabled Lady Vox must both be laid to rest.",
		enabled      = true,
	},
	{
		key          = "severilous",
		saylink      = "Fabled Severilous",
		name         = "The Fabled Severilous",
		zone         = "emeraldjungle",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_subflags = { "fabled_nagafen", "fabled_vox" },
		deny_message = "The Sage shakes his head. The Green Scourge sleeps until the first memories fall: the Fabled Lord Nagafen and the Fabled Lady Vox must both be laid to rest.",
		enabled      = true,
	},
	{
		key          = "talendor",
		saylink      = "Fabled Talendor",
		name         = "The Fabled Talendor",
		zone         = "skyfire",
		version      = 2,
		duration     = eq.seconds("14h"),
		gate_subflags = { "fabled_nagafen", "fabled_vox" },
		deny_message = "The Sage shakes his head. The Red Terror sleeps until the first memories fall: the Fabled Lord Nagafen and the Fabled Lady Vox must both be laid to rest.",
		enabled      = true,
	},
};

--Gate check: gate_stage via the progression module, gate_subflags via
--the Fabled subflags recorded under the FNagafen stage. GM bypass.
local function gate_passes(client, row)
	if client:GetGM() then
		return true;
	end
	if row.gate_stage and not prog.stage_complete(client, row.gate_stage) then
		return false;
	end
	if row.gate_subflags then
		local flags = prog.get_stage_progress(client, FABLED_STAGE);
		for _, sub in ipairs(row.gate_subflags) do
			if flags[sub] ~= "1" then
				return false;
			end
		end
	end
	return true;
end

local function find_expedition_row(message)
	for _, row in ipairs(FABLED_EXPEDITIONS) do
		if row.enabled and message:find(row.key, 1, true) then
			return row;
		end
	end
	return nil;
end

local function on_fabled_expedition(client, row)
	local dz = client:GetExpedition();
	return dz.valid and dz:GetName() == row.name;
end

function event_say(e)
	local msg = e.message:lower();

	if msg:find("hail") then
		local links = {};
		for _, row in ipairs(FABLED_EXPEDITIONS) do
			if row.enabled then
				table.insert(links, "[" .. eq.say_link(row.key) .. "]");
			end
		end
		e.self:Say(string.format(
			"Hail, %s. I am the keeper of memories the world was too frightened to keep. The great wyrms of old stir again, more terrible than history remembers. Would you face the memory of the [" ..
			table.concat(links, "] or the [") .. "]?",
			e.other:GetCleanName()));
		return;
	end

	local row = nil;
	if msg:match("^enter") then
		-- the enter branch must run before the row match: "enter nagafen"
		-- also contains the row key.
		local dz = e.other:GetExpedition();
		if not dz.valid then
			e.self:Say("You carry no memory to return to. Hail me again when you wish to seek one.");
			return;
		end
		for _, r in ipairs(FABLED_EXPEDITIONS) do
			if r.enabled and dz:GetName() == r.name then
				row = r;
				break;
			end
		end
		if row == nil then
			e.self:Say("That memory is not mine to open. Speak to whoever granted it.");
			return;
		end
		e.other:MovePCDynamicZone(dz:GetZoneID());
		return;
	end

	row = find_expedition_row(msg);
	if row then
		if on_fabled_expedition(e.other, row) then
			e.self:Say("The memory still holds you. Say [" .. eq.say_link("enter " .. row.key) .. "] to return to it.");
			return;
		end

		if not gate_passes(e.other, row) then
			e.self:Say(row.deny_message);
			return;
		end

		local dz = e.other:CreateExpedition({
			expedition = { name = row.name, min_players = 1, max_players = 6 },
			instance   = { zone = row.zone, version = row.version, duration = row.duration },
			compass    = { zone = "bazaar", x = -32.3, y = -603.1, z = 24.6 },
			safereturn = { zone = "bazaar", x = -32.3, y = -603.1, z = 24.6, h = 250.5 },
			zonein     = { x = -265, y = -410, z = -110, h = 0 },
		});
		if dz.valid then
			e.self:Say("So be it. The memory of " .. row.name .. " gathers in the dark of his old lair. Say [" ..
				eq.say_link("enter " .. row.key) .. "] to cross the threshold -- and remember: the fire remembers everything.");
		else
			e.self:Say("The memory does not answer... perhaps another party already walks within it. Try again in a moment.");
		end
		return;
	end
end
