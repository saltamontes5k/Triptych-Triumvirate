function event_spawn(e)
	-- Spawned by Zebuxoruk during his monologue.
	-- Start monologue after a short delay since we're already in position.
	eq.set_timer("start", 9000);
end

function event_timer(e)
	if (e.timer == "start") then
		eq.stop_timer(e.timer);
		e.self:Emote("speaks with no movement of her mouth. Her thoughts flow through you, calming you as you begin to comprehend what she is trying to communicate to you.");
		eq.set_timer("druzzil1",1000);
	elseif (e.timer == "druzzil1") then
		e.self:Emote("speaks to your mind, 'Zebuxoruk, my student I cannot allow this to happen. If you were to escape from another prison the will and power of the gods will have been compromised.'");
		eq.set_timer("druzzil2",8000);
		eq.stop_timer("druzzil1");
	elseif (e.timer == "druzzil2") then
		e.self:Emote("speaks to your mind, 'That I did, but I also taught you not to share your wealth of knowledge if it would affect the fate of others. I cannot allow this to happen. I must set things back to how they were before you and these mortals arrived here, I believe that you cannot understand this and I am sorry.'");
		eq.set_timer("druzzil3",8000);
		eq.stop_timer("druzzil2");
	elseif (e.timer == "druzzil3") then
		e.self:Emote("looks upon Zebuxoruk one last time, as a wave of sadness comes across her gentle face.");
		eq.set_timer("druzzil4",7000);
		eq.stop_timer("druzzil3");
	elseif (e.timer == "druzzil4") then
		e.self:Emote("begins to chant an incantation; mana flows out from her body in all directions. Things begin moving slowly in reverse. You become dizzy from the experience and fall to your knees. As you look up the last thing you can see is Druzzil Ro smiling in your direction. She then waves her arms gracefully and points at you.");
		eq.set_timer("druzzil5",7000);
		eq.stop_timer("druzzil4");
	elseif (e.timer == "druzzil5") then	
		eq.stop_timer("druzzil5");
		eq.zone_emote(MT.LightGray,"Druzzil Ro has preserved the timeline and restored existence back to its normalcy. You may now loot your hard-earned rewards. Speak to Druzzil when you are ready to [return] to the Plane of Knowledge.");
	end
end

function event_say(e)
	if (e.message:findi("hail")) then
		e.self:Say("My work here is done, mortals. You have performed a great service, though the timeline must be preserved. Are you ready to [" .. eq.say_link("return") .. "] to the Plane of Knowledge?");
	elseif (e.message:findi("return")) then
		e.self:Say("Very well. Safe travels, brave soul.");
		e.other:MovePCInstance(202, 0, 1015, 20, 392, 264)
	end
end
