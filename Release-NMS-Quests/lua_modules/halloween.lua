-- Nights of the Dead (Halloween) shared helpers and IDs
-- Seasonal content gated by the 'peq_halloween' content flag.
--
-- Task ids below are the LIVE ids in the `tasks` table.  Older quest scripts
-- referenced a stale range (211-222); those have been remapped:
--   211->8278  212->5655  213->5654  214->5651  215->5653  216->3540
--   217->5652  218->3539  219->500219 220->500220 222->500222
--
-- Gating rule: content_flags tables (spawn2/spawnentry/ground_spawns/loottable)
-- carry 'peq_halloween'.  Tasks have no content_flags column, so task NPCs
-- must test the flag before assigning (see M.enabled()).

local M = {}

M.FLAG = 'peq_halloween'

M.TASK = {
	HAPPY        = 500219, -- Happy Halloween! (shared wrapper)
	TRICKORTREAT = 500220, -- Trick or Treat for the Old Man
	RATBOUNTY    = 500222, -- The Rat Bounty (PoK ratter hunt)
	BLACKCAT     = 8278,   -- Find the Black Cat
	ZOMBIE       = 5655,   -- Great Zombie Attack
	LYCAN        = 5654,   -- Lycanthrope's Cure
	CANDYAPPLE   = 5651,   -- Making Candy Apples
	MASH         = 5653,   -- Monster Mash
	GHOSTRIDER   = 3540,   -- Nektulos Ghost Rider
	TOADSTOOL    = 5652,   -- Toadstool Surprise
	PIEFLING     = 3539,   -- Toxxulia Pie Fling
	HUNGRY       = 8013,   -- The Hungry Halfling
	-- 2005-2008 quests (task id block 620004+)
	ZAPPING      = 620004, -- Skeleton Zapping
	TROUBLE      = 620005, -- Troublemakers in Faydark
	GARDEN       = 620006, -- Necromancer's Garden
	UNDEAD       = 620007, -- Undead Rising
	COSTUME      = 620008, -- Missing Costume Pieces
	BONECOLLECT  = 620009, -- The Bone Collector
	SCARECROW    = 620010, -- Scarecrow Roundup
	WITCH        = 620011, -- The Witch's Wishes
}

M.ITEM = {
	-- 2005-2009 class rewards / quest items that exist in the DB
	BONE_MASK        = 90040,
	FREEMIND_SPORE   = 53513,
	BLOOD_CURSE_WAND = 87310, -- Wand of the Blood Curse
	FIERY_WAND       = 87309, -- Fiery Wand of Retribution
	SKELETON_SCYTHE  = 87296, -- Scythe of Skeletal Expulsion
	RONGOL_PITCHFORK = 49060,
	BLESSED_SHILLELAGH = 49061,
	MASK_OF_EYES     = 80043,
	BRIDLE_CURSED    = 80039,
	SCARECROW_POTION = 80058,
	FLOATING_SKULL   = 80057,
	SCRUMPTIOUS_JOL  = 87311,
	GINORMOUS_JAWBREAKER = 87312,
	-- candy / consumables
	HAUNTED_CANDY_APPLES = 85067,
	CANDY_CORN           = 84090,
	FULL_TREAT_BAG       = 84096,
	-- 2005-2008 quest tools / rewards
	FIREWORK_NAGAFEN = 80042,
	FLOATING_SKULL_REWARD = 80057,
	WORM_SKULL_MUFFIN     = 80059,
	BLOODY_CLOAK          = 85060,
	BLOODY_FANGS          = 85061,
	DISCORDLING_BONE      = 54349,
	DRAGON_SKULL_FRAG     = 84081,
	BONE_EARRING          = 90025,
	-- Witch's Wishes (created this pass)
	WITCH_CAULDRON = 3001001,
	DREAD_MUSHROOM = 3001002,
	LOST_MIRROR    = 3001003,
	MIRROR_PIECES  = 3001004,
	BROKEN_HORSESHOE = 3001005,
	WITCH_BREW     = 3001006,
}

M.NPC = {
	WICKED_WINNIE = 202384,
	SPOOKY_SALLY  = 202386,
	HAUNTED_JACK  = 202387,
}

-- True when the Halloween event is toggled on.  Use before assigning tasks.
function M.enabled()
	return eq.is_content_flag_enabled(M.FLAG)
end

-- Assign a task only if the event is live and the player doesn't already have
-- it active/repeatable-completed.
function M.assign(client, task)
	if not M.enabled() then
		return false
	end
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

return M
