-- Erollisi Day (erollisiday) shared helpers and IDs
-- Seasonal content gated by the 'erollisiday' content flag.

local M = {}

M.TASK = {
	PERFECT   = 610001, -- The Perfect Companion
	FRIENDS   = 610002, -- Things Are Best With Friends
	FOOL      = 610003, -- A Fool In Love
	ALLNEED   = 610004, -- All You Need Is Love
	FINDME    = 610005, -- Can Anybody Find Me
	ONLYFOOLS = 610006, -- Only Fools Fall In
	LURES     = 610007, -- Lures Hurt
	CRAZY     = 610008, -- Crazy Little Thing
	ITHINK    = 610009, -- I Think I Love You
}

M.ITEM = {
	CHEWED_NIB      = 3000017,
	FLUFFY_QUILL    = 3000018,
	HEART_PAPER     = 3000019,
	DRYING_SAND     = 3000020,
	HEARTFELT_LETTER= 3000021,
	RIVER_FLOWER    = 3000022,
	GOBLIN_DOLL     = 3000023,
	BANDIT_DRUM     = 3000024,
	TORN_FLYER      = 3000025,
	FLYER_PAGE1     = 3000026,
	FLYER_PAGE2     = 3000027,
	NEWS_FLYER      = 3000028,
	IKSAR_TAILBONE  = 3000029,
	SARNAK_VOICEBOX = 3000030,
	COCKATRICE_CLAW = 3000031,
	BEACH_GRASS     = 3000032,
	TOTEM           = 3000033,
	SQUEEZED_GLEE   = 3000034,
	POISON_VIAL     = 3000035,
	GOLDEN_FLOWER   = 3000036,
	ROSEUS_FLOWER   = 3000037,
	NUT_COOKIE      = 3000038,
	HABANERO        = 3000039,
	SERRANO         = 3000040,
	GARLIC          = 3000041,
	SESAME          = 3000042,
	FUDGE_BROWNIE   = 3000043,
	CANDY_SULTRY    = 3000044,
	CANDY_SASSY     = 3000045,
	CANDY_SWEET     = 3000046,
	GUMDROP_FAM     = 3000047,
	BROWNIE_FAM     = 3000048,
	IDOL_FRIENDSHIP = 17797,
	DAY_FLOWERS     = 57535,
}

M.NPC = {
	GOBLIN_WARRIOR      = 1500100026,
	GOBLIN_INSTIGATOR   = 1500100027,
	GOBLIN_INSTIGATOR_R = 1500100028,
	GOBLIN_INSTIGATOR_G = 1500100029,
	IKSAR_SKELETON      = 1500100030,
	SARNAK_SKELETON     = 1500100031,
	RATTLED_CLOCKWORK   = 1500100032,
	ADDLED_CLOCKWORK    = 1500100033,
	DEFECTIVE_CLOCKWORK = 1500100034,
	MALFUNC_CLOCKWORK   = 1500100035,
}

-- Assign a task if the player does not already have it active/completed.
function M.assign(client, task)
	if not client:IsTaskActive(task) and not client:IsTaskCompleted(task) then
		client:AssignTask(task)
		return true
	end
	return false
end

-- Increment an activity on an active task.
function M.upd(client, task, activity, count)
	if client:IsTaskActive(task) then
		client:UpdateTaskActivity(task, activity, count or 1)
	end
end

-- True if every activity in [first,last] has at least one update.
function M.all_done(client, task, first, last)
	for i = first, last do
		if client:GetTaskActivityDoneCount(task, i) < 1 then
			return false
		end
	end
	return true
end

-- Spawn an NPC and scale it to the given player's level.
function M.spawn_scaled(npc_id, x, y, z, h, player)
	local mob = eq.spawn2(npc_id, 0, 0, x, y, z, h or 0)
	if type(mob) == "number" then
		mob = eq.get_entity_list():GetNPCByID(mob)
	end
	if mob and player then
		mob:ScaleNPC(player:GetLevel())
	end
	return mob
end

-- Resolve the player responsible for a kill from an event table.
function M.killer(e)
	local k = e.other
	if k and k:IsPet() then
		k = k:GetOwner()
	end
	if k and k:IsClient() then
		return k
	end
	if e.killer_id then
		local c = eq.get_entity_list():GetClientByID(e.killer_id)
		if c then
			return c
		end
	end
	return nil
end

return M
