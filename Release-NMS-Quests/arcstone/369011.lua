-- arcstone/369011.lua - Arch Mage Galsin
-- Prophecy of Ro: Theater of Blood / Plane of Music access (the chime chain).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Ah another visitor to this place. It's always good to see a fresh face, particularly if that person has news of use to me. Tell me " .. e.other:GetName() .. ", have you heard of the [Plane of Music]?");
	elseif t:find("plane of music") then
		e.self:Say("When I arrived in this place I discovered an ancient book which contained an amazing amount of knowledge lost to Norrath over the ages. One of the more interesting sections spoke of the Plane of Music. The wonders described within that plane are almost beyond belief. I must see them for myself. The problem I'm confronted with is how exactly to enter the plane. The book has a small amount of [information] in that regard, but it's not the most heartening news.");
	elseif t:find("information") then
		e.self:Say("According to the book entry to the plane could only be accomplished by sounding a certain pure tone. This tone is normally impossible for mere mortals to generate, but there were chimes created that, when struck, would sound this tone and transport the bearer to the plane. Unfortunately the book also mentions that all of the known chimes were destroyed by Sullon Zek in a fit of rage. Apparently she took offense to a light hearted song of some sort written by Ayonae Ro. After reading that I began focusing my search on in a new [direction].");
	elseif t:find("direction") then
		e.self:Say("I have spoken with others on this subject prior to your arrival. Many of them agreed to pass on any news or rumors they heard to me. Recently one of these people told me of a scrykin named Ao the Fourth Born. From what I've been told he is seeking a book written by Druzzil Ro herself. It is my hope that this book has information that might provide an alternate route into the plane. If you wish to help in my research seek out Ao and see what you can discover.");
	elseif t:find("whispers") then
		e.self:Say("There have been rumors amongst the residents of this plane of a terrible disaster in the Plane of Music. Some unknown force has closed the plane off from all outside influences and by all implications begun to corrupt its very nature. The failure of this chime must mean that this corruption has reached a point where the purity of this note will no longer transport you. If this is true then there must be a way of modifying the chime to account for the corruption. The idea of modifying the chime does have [complications] associated with it though.");
	elseif t:find("complications") then
		e.self:Say("The material of this chime is, as far as I can tell, of divine origins. There are few forces that would be able to modify or harm it in any way. There is a possibility though. . . yes. . . the opening of the Plane of Rage must have been a message. Sullon Zek was able to destroy the chimes, so her magic must be able to affect this material. If you were able to find someone on her plane to help they may be able to modify the chime as needed. Go there and inquire about the chime with any that would speak with you. Perhaps the chime will prove to be our key to the Plane of Music after all.");
	elseif t:find("solution") then
		e.self:Say("With the opening of the portal back to the time of the Takish-Hiz empire we may have access to the powers needed to enchant the chime again. If you can find one of the royal bloodline they may be able to assist us in restoring the enchantment to the chime.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Harmonic Chime -> Silent Harmonic Chime
	if item_lib.check_turn_in(e.trade, { item1 = por.items.harmonic_chime }) then
		e.self:Say("Unbelievable, I was sure none of the chimes had survived Sullon's wrath. This is a fascinating artifact, I've never seen anything like it. Galsin taps the chime with a small hammer and stares in amazement when no sound is created. 'But the chime. . . This must be the one. It can only mean there is some truth to the [whispers] I have been hearing.'");
		c:SummonFixedItem(por.items.silent_harmonic_chime);
		return;
	end

	-- Twisted Chime (first, from Oathmir) -> Twisted Chime (second)
	if item_lib.check_turn_in(e.trade, { item1 = por.items.twisted_chime_first }) then
		e.self:Say("This has indeed been modified, but what happened to the enchantment that was on it? Who did you find to do this for you? Nevermind. . . We must find a way of restoring the enchantment to this chime before it can be tested. According to my book Ayonae bestowed the knowledge of these chimes upon the royal family in the Elddar Forest. Perhaps this is the [solution] we're looking for.");
		c:SummonFixedItem(por.items.twisted_chime_second);
		return;
	end

	-- Twisted Harmonic Chime (no effect) -> final chime + Harmonic Dissonance AA
	if item_lib.check_turn_in(e.trade, { item1 = por.items.twisted_harmonic_chime_blank }) then
		if not c:HasItem(por.items.twisted_harmonic_chime) then
			c:SummonFixedItem(por.items.twisted_harmonic_chime);
		end
		if (tonumber(c:GetBucket("por.harmonic_dissonance")) or 0) == 0 then
			c:GrantAlternateAdvancementAbility(por.aa.harmonic_dissonance, 1);
			c:SetBucket("por.harmonic_dissonance", "1");
		end
		e.self:Say("The enchantment has been restored! Strike the chime and a pure tone will carry you into the Plane of Music, though what you will find there I cannot say. Take this knowledge with you, and be careful.");
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
