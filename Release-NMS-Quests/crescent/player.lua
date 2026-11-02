-- Crescent Reach zone player script (lua port of the reconstructed stock
-- player.pl + the becoming-hero seeds/throne system + the RoF2 welcome and
-- champion scene hooks). Replaces player.pl, which now only holds the NMS
-- froglok-deity redirect -- preserved below as check_frog_zone.
-- items: 53481, 53482, 53485, 53484, 53486
local welcome = require("achievement_quest_blightfire_welcome")
local champion = require("achievement_quest_blightfire_champion")

local function check_frog_zone(e)
	-- NMS: froglok (race 330) followers of deity 208 are redirected at zone in.
	if e.self:GetRace() == 330 and e.self:GetDeity() == 208 then
		e.self:MovePC(8, 120, 129, -24, 0)
	end
end

-- Becoming a Hero: credit a completed seed cast only; native task completion
-- owns rewards. Shimmering Parchment (spell 8699) seeds task 3039603.
local function becoming_hero_seed_cast(e)
	if e.spell_id ~= 8699 then return end
	if not quest.istaskactivityactive(3039603, 0) then return end
	local seed_slot = -1
	for slot = 23, 32 do
		if e.self:GetItemIDAt(slot) == 84231 then seed_slot = slot; break end
	end
	if seed_slot < 0 then return end
	local sx, sy, sz = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	if not (sx >= -2150 and sx <= -1650 and sy >= -350 and sy <= 700 and sz >= -130 and sz <= -40) then
		return
	end
	local key = "becoming_hero_seed_last"
	local done = e.self:GetTaskActivityDoneCount(3039603, 0)
	local old = e.self:GetBucket(key)
	local ox, oy = string.match(old or "", "^(-?[%d.]+),(-?[%d.]+)$")
	if done > 0 and ox then
		local dx, dy = sx - tonumber(ox), sy - tonumber(oy)
		if dx * dx + dy * dy < 1 then return end
	end
	e.self:SetBucket(key, string.format("%s,%s", sx, sy))
	quest.updatetaskactivity(3039603, 0, 1)
	quest.spawn2(394933, 0, 0, sx, sy, sz, 0)
	if e.self:GetTaskActivityDoneCount(3039603, 0) >= 10 then
		e.self:RemoveItem(84231, 1)
		e.self:DeleteBucket(key)
	end
end

-- Becoming a Hero: the throne door summons Master_Vanguard_Regan's echo for
-- task 3039606. Dated guide X-225,Y-1250; native throne Z 123.218.
local function becoming_hero_throne_click(e)
	if e.door_id ~= 18 then return end
	if not quest.istaskactive(3039606) then return end
	if math.abs(e.self:GetX() + 226.163) > 60 or math.abs(e.self:GetY() + 1239.01) > 60 or math.abs(e.self:GetZ() - 123.218) > 25 then
		return
	end
	if eq.get_entity_list():GetNPCByNPCTypeID(394930) then return end
	quest.spawn2(394930, 0, 0, -225, -1250, 123.218, 0)
end

function event_connect(e)
	check_frog_zone(e)
end

function event_zone(e)
	check_frog_zone(e)
end

function event_enter_zone(e)
	check_frog_zone(e)
	-- Stock reconstruction: the Wayfarers Brotherhood whisper.
	local qg = quest.get_qglobals(e.self)
	if e.self:GetLevel() >= 15 and not qg.Wayfarer
		and e.self:GetStartZone() == e.zone_id and quest.is_lost_dungeons_of_norrath_enabled() then
		e.self:Message(15, "A mysterious voice whispers to you, 'Vladnelg Galvern has just joined the Wayfarers Brotherhood and has some information about them, and how you can start doing odd jobs for them. You looked like the heroic sort, so I wanted to contact you . . . discreetly.'")
	end
	welcome.player_event(e)
end

-- Shimmering Parchment is the original Touch of the Six click effect.
-- Activity type CastOn supplies the native task UI but has no automatic
-- casting dispatcher in this core. Credit the actual completed cast only.
function event_cast(e)
	becoming_hero_seed_cast(e)
	if e.spell_id == 8691 and quest.istaskactivityactive(6020, 1) and e.self:CountItem(84220) > 0 then
		quest.updatetaskactivity(6020, 1, 1)
	end
end

function event_click_door(e)
	becoming_hero_throne_click(e)
end

-- Task 5431 - Ways of Nature - Initiate Dakkan
-- Task 5427 - Snake Sacs - Initiate Dakkan
-- Task 10644 - Cap of Color - Jinkin
-- Task 6800 - Here Kitty, Kitty - Jinkin
-- Task 10645 - Thrills and Quills - Jinkin
function event_task_stage_complete(e)
	if e.task_id == 5431 and e.activity_id == 1 then
		quest.summonitem(53481, 5) -- Potion of Minor Relief x 5
		quest.signal(394147)
		e.self:Message(4, "Dakkan is one step further in his quest to learn about nature and could use your help.")
		quest.exp(500)
		quest.ding()
	end
	if e.task_id == 5427 and e.activity_id == 1 then
		quest.summonitem(53482, 5) -- Potion of Quickened Thought x 5
		quest.signal(394147)
		e.self:Message(4, "Dakkan is getting closer to learning all he needs to know about poison, but he still has more to learn.")
		quest.exp(500)
		quest.ding()
	end
	if e.task_id == 10644 and e.activity_id == 1 then
		quest.summonitem(53485, 10) -- Sporeling Essence Potion x 10
		e.self:Message(4, "Jinkin now has a full supply of dye, but as diligently as she works, it won't last long.")
		quest.exp(500)
		quest.ding()
	end
	if e.task_id == 6800 and e.activity_id == 2 then
		quest.summonitem(53484, 10) -- Jinkin's Hearty Elixir x 10
		e.self:Message(4, "Jinkin has enough fangs now to complete her necklace, but she still has a lot of work to do!")
		quest.exp(500)
		quest.ding()
	end
	if e.task_id == 10645 and e.activity_id == 3 then
		quest.summonitem(53486) -- Quill-Studded Bracer
		e.self:Message(4, "Jinkin has enough hides to make many bracelets now. Hopefully, someone will buy them . . .")
		quest.exp(500)
		quest.ding()
	end
	if e.task_id == 505746 and e.activity_id == 1 then
		quest.summonitem(57974) -- Crescent Reach City Charter
		e.self:Message(4, "You pull the city charter from the bookshelf and your heart begins to beat just a little faster. You feel just a bit more at home in Crescent Reach.")
	end
	welcome.player_event(e)
end

function event_task_accepted(e)
	welcome.player_accepted(e)
	champion.player(e)
end

function event_task_complete(e)
	welcome.task_complete(e)
	champion.complete(e)
end

function event_timer(e)
	welcome.player_timer(e)
end
