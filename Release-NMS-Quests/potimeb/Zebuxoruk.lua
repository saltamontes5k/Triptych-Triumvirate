function event_spawn(e)
	eq.set_timer("walk",5000);
end

function event_timer(e)
	if (e.timer == "walk") then
		eq.stop_timer(e.timer);
		e.self:Emote("staggers about and looks at you, drowsy from his weakened state. 'My thanks to you. I am surprised to see you have made it here. We must get back to Norrath. The time has come for me to share my knowledge. Something is coming, a threat to us all, and the sands in the hourglass are thinning. Make haste and take me back the way you came.'");
		eq.set_timer("zeb1",23000);
		eq.start(1);
	elseif (e.timer == "zeb1") then
		e.self:Say("I am surprised at the gods for taking such drastic measures, though I suppose all of the creations of the Nameless are capable of displaying poor judgment and irrational behavior. These gods are burdened with powers and responsibilities beyond our comprehension, yet at times they do not understand the eventual effect of their actions. I am compelled to share the knowledge of the gods with the populace of Norrath, so that I might save their creations. They do not realize that if mortality ceases to exist... if they are not worshipped and held aloft by the beliefs of those that they now have grown to fear... they will fall from power and a new age of darkness will wash over existence as they know it. I did not seek to interfere with them or their  realms, only to free them from a fate that awaits all of us. It is this fate that now stands ready, greedily gathered on the edge of the void, ready to test the will of all mortals.");
		eq.stop_timer("zeb1");
		eq.set_timer("zeb2",23000);
	elseif (e.timer == "zeb2") then
		e.self:Say("If they have taken measures these extreme I must rethink what I have done, and what I will do. If there was this much cause for conc...");
		eq.zone_emote(MT.LightGray,"Suddenly in a bright flash a feminine figure appears before you. Your ears ring from the loud burst as she slowly materializes.");
		eq.spawn2(223213,0,0,-242,-1105,0,387);
		eq.set_timer("zeb3",14000);
		eq.stop_timer("zeb2");
	elseif (e.timer == "zeb3") then
		e.self:Say("Druzzil, I have missed you. Wasn't it you that taught me in your own realm to seek knowledge and share it in all forms?");
		eq.set_timer("zeb4",35000);
		eq.stop_timer("zeb3");
	elseif (e.timer == "zeb4") then
		eq.stop_timer("zeb4");
		e.self:Stop();
		e.self:GMMove(-582, -1100, 0, 127);
	end
end

function event_say(e)
	if (e.message:findi("hail")) then
		local qglobals = eq.get_qglobals();
		if (qglobals.xebuxoruk_unlock == "1") then
			-- The 72h defeat cooldown lives on the player's expedition
			-- lockout now (xebuxoruk_clone.lua), not on a world qglobal.
			-- Literals must match XEB_EXPEDITION / XEB_LOCKOUT_EVENT in
			-- potimea/player.lua.
			if (e.other:HasExpeditionLockout("The Forsaken Hourglass", "Xebuxoruk the Forsaken")) then
				e.self:Say("You have already unmade the one who wears my face -- for now. Time must gather itself before his malice can pool again. Return in three days' turn.");
			else
				e.self:Say("So you have felt it too -- the ripple in the hours. The gods chained me in Time's own heart, and when the moment of my intended execution came, Druzzil turned the hourglass rather than let it fall. But the ages you and yours had already pried open would not close cleanly -- the hourglass cracked, and in some timelines the execution still found me. That severed moment festers still, in the outer wastes of this plane: a reflection cut from my face, stranded on the wrong side of the glass, blooming with every seed of destruction your meddling planted. I cannot face it; my hands are too recently freed. But yours... Are you ready for me to [" .. eq.say_link("send you") .. "] to it?");
			end
		else
			e.self:Say("I am myself again, thanks to Druzzil and to you. But the hours still feel... wrong. As if something is missing from its proper place.");
		end
	elseif (e.message:findi("send you")) then
		local qglobals = eq.get_qglobals();
		if (qglobals.xebuxoruk_unlock == "1") then
			-- The fight lives in a potimea version-9 expedition now, and a
			-- character can hold only one expedition at a time: release the
			-- Time B claim first. RemoveAllMembers is the only script-side
			-- way out of an expedition, so this ejects the whole expedition
			-- to its courtyard safe return -- where the clocktower door
			-- waits (potimea/player.lua owns the door).
			local expedition = e.other:GetExpedition();
			if (expedition.valid) then
				e.self:Say("Stand fast. The way is not kind, and neither is what waits at the end of it. I cannot hold your claim on this place and turn the hourglass both -- I release it. Seek the sundial in the garden; it will carry you to him.");
				expedition:RemoveAllMembers();
			else
				e.self:Say("Stand fast. The way is not kind, and neither is what waits at the end of it. Take the road Druzzil opens, then seek the sundial in the garden; it will carry you to him.");
				e.other:MovePC(219, 298, 919, 8, 0);
			end
		else
			e.self:Say("The path has already closed. Time keeps its own counsel.");
		end
	end
end
