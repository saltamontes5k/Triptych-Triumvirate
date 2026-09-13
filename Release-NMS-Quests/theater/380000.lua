-- theater/380000.lua - Eodue the Pure
-- Prophecy of Ro: grants Deathknell, Tower of Dissonance access once the player
-- brings her an Inspiration looted from the Theater of Blood.
local por = require("por_helper");

-- Inspirations of the six companions of Ayonae Ro (drop from the ToB encounter bosses).
local inspirations = { 52595, 52594, 52598, 52596, 52597, 52599 }

local companions = {
	"Cassindra", "Denon", "Ervaj", "Jonthan", "Rizlona", "Tuyen",
}

-- The chime chain is complete once Arch Mage Galsin restores the final
-- Twisted Harmonic Chime (arcstone/369011.lua), which sets this bucket.
local function chime_done(client)
	return (tonumber(client:GetBucket("por.harmonic_dissonance")) or 0) == 1
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Do you hear it? The music has gone wrong. My companions and I came to the Theater of Blood to play for Ayonae Ro, but something has taken her, and now we are cursed. Will you help me free them?");
	elseif t:find("what curse") then
		e.self:Say("We are bound to this place. When one of us falls, a fragment of their inspiration lingers. Bring me such a fragment, and I can use it to open the way into the tower of Deathknell, where Ayonae Ro has withdrawn.");
	elseif t:find("what source") then
		e.self:Say("The corruption comes from the same hand that has poisoned Sullon Zek's rage and closed the Plane of Music. Something is very wrong with the goddesses, and only by reaching Ayonae can we learn the truth.");
	elseif t:find("deathknell") or t:find("enter") or t:find("tower") then
		if (tonumber(e.other:GetBucket("por.deathknell")) or 0) ~= 1 then
			e.self:Say("You are not yet attuned to the tower. Bring me an inspiration, and perhaps the way will open.");
		elseif not chime_done(e.other) then
			e.self:Say("The tower's note is still impure. Seek Arch Mage Galsin and finish what the royal line began. Restore the chime, and Deathknell will answer.");
		elseif por.enter(e.other, "theatera", "Deathknell, Tower of Dissonance", 1, 54, "6h", "3d") then
			e.self:Say("The tower of Deathknell opens. Ayonae Ro waits above, and the music there has turned to something terrible.");
		end
	else
		for _, name in ipairs(companions) do
			if t:find(name:lower()) then
				e.self:Say("That is one of my companions. Strike them down if you must, and bring me the inspiration they leave behind. It is the only way.");
				return;
			end
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	for _, id in ipairs(inspirations) do
		if item_lib.check_turn_in(e.trade, { item1 = id }) then
			if not chime_done(c) then
				c:SummonFixedItem(id); -- refund: the chime chain is not yet finished
				e.self:Say("A fragment of inspiration, but the tower will not hear it yet. The song must first be made pure. Seek Arch Mage Galsin and restore the chime.");
				return;
			end
			if (tonumber(c:GetBucket("por.deathknell")) or 0) == 0 then
				c:SetBucket("por.deathknell", "1");
			end
			e.self:Say("A fragment of inspiration! I can feel the way opening. Go now, the tower of Deathknell awaits you, and with it Ayonae Ro herself.");
			c:Message(15, "Your path to Deathknell, Tower of Dissonance has been opened.");
			return;
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
