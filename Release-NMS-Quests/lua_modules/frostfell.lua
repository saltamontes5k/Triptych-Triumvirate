-- Frostfell (classic 2006-2012) shared helpers and IDs
-- Seasonal content gated by the 'frostfell' content flag.

local M = {}

M.TASK = {
	CLUES  = 612001, -- Searching for Clues (2006)
	SANTUG = 612002, -- Saving Santug (2006)
	LIST   = 612003, -- Santug's List (2006)
	TINAM  = 612004, -- A Gift for Tinam (2006)
	KANF   = 612005, -- Freedom of Kanf Shadowhands (2007)
	GEMMI  = 612006, -- Savior of Gemmi Goodkin (2007)
	BRAM   = 612007, -- Search for Bram Bandyboot (2007)
	HAILIE = 612008, -- Rescue Hailie Biggeyes (2007)
	CHEER  = 612009, -- Gathering Holiday Cheer (2010)
	BRAXI  = 612010, -- Braxi Roundup (2012)
}

M.ITEM = {
	-- 2006 clues
	CLUE_BROKEN_TOY = 87510,
	CLUE_SCROLL     = 87511,
	CLUE_INNORUUK   = 87512,
	CLUE_SNOWBALL   = 87513,
	CLUE_FUR        = 87514,
	GRIMP_SCALES    = 87558,
	SANTUG_GIFT     = 87516,
	ORNATE_SLED     = 87517,
	STOCKING        = 87569,
	-- A Gift for Tinam
	HORGRAM_GEM     = 87541,
	HAIR            = 87542,
	CLOAK           = 87543,
	SPEAR           = 87544,
	DOLLY           = 87545,
	COINS           = 87574,
	-- 2007 frostheart snowman drops
	SNOWGLOBE       = 79663,
	ICICLE_CAKE     = 79664,
	CROSSBOW        = 79665,
	SKATES          = 79662,
	FRUIT_CAKE      = 79666,
	-- 2010 / 2012
	BRAINSTEM       = 100167,
	CHEER_POTION    = 100168,
	SHARKSKIN       = 16891,
	MANA_BATTERY    = 14800,
	BRAXI_DEVICE    = 64062,
	POTION_ADV      = 40605,
}

M.NPC = {
	GRIMP        = 1500101001,
	HIDING_GOBLIN= 1500101002,
	GRINNUCH     = 1500101003,
	ZOOG         = 1500101004,
	ZOTT         = 1500101005,
	ZIPP         = 1500101006,
	ZOBB         = 1500101007,
	BRAM         = 1500101008,
	HAILIE       = 1500101009,
	GEMMI        = 1500101010,
	KANF         = 1500101011,
	SNOWMAN      = 1500101012,
	FATHER       = 1500101013,
	GORILLA      = 1500101014,
	DORIK        = 1500101015,
	FREEZKORR    = 1500101016,
	GEZRAZELM    = 1500101017,
	-- plane of knowledge controllers (existing)
	SANTUG_HELPER= 202403,
	KUUTAS       = 202421,
	CORDYS       = 202440,
	ELBA         = 202441,
}

M.CLUES = {
	M.ITEM.CLUE_BROKEN_TOY,
	M.ITEM.CLUE_SCROLL,
	M.ITEM.CLUE_INNORUUK,
	M.ITEM.CLUE_SNOWBALL,
	M.ITEM.CLUE_FUR,
}

M.SNOWMAN_LOOT = {
	M.ITEM.SNOWGLOBE,
	M.ITEM.ICICLE_CAKE,
	M.ITEM.CROSSBOW,
	M.ITEM.SKATES,
	M.ITEM.FRUIT_CAKE,
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
