local sirran_six_cheese	= false;

function event_spawn(e)
	eq.set_timer("bye", 20 * 60 * 1000);
end

function event_say(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	local airplane_sirran_status = tonumber(eq.get_data("airplane-sirran-".. instance_id)) or 0;
	if e.message:findi("hail") then
		eq.set_timer("bye", 20 * 60 * 1000);
		if airplane_sirran_status == 1 then		--island1
			e.self:Say("Ehem! What? Oh, hello there! Sirran be my name. Yes? So, come to the Plane of Sky, have you? Killed all my fairies! Hah! So! Do you wish to know how to traverse this plane? Or should I just go away? I know much about this plane. You would do well to listen!");
		elseif airplane_sirran_status == 2 then	--island2
			e.self:Say("Ah! Come far you have! You are all crazy! I like it! Swords spin no more! Spin, spin. Unlucky they were! I thought them [vain]!");
		elseif airplane_sirran_status == 3 then	--island3
			e.self:Say("What! Die already! Come so far. Can't you see I am cold! Give me a cloak or something! Bah! You don't look the type to give anything! Be off with you, then!");
			e.self:Say("Always want something for nothing? Oh yes, you gave me something! Here you go! Take this! Used one you have. [Teleport] away you will! Let me know, or no kill! Haha!");
		elseif airplane_sirran_status == 4 then	--island4
			e.self:Say("What is this? Bah! Take that! And this! What was I thinking? I was thinking you had best let me know when you use those teleporters. Just say, [Icky Bicky Barket]. Aye, that is what I was thinking.");
		elseif airplane_sirran_status == 5 then	--island5
			e.self:Say("Children, run to the wall and give the deputies some milk. Oh, I almost forgot. Give me your trinkets, or give me death!");
		elseif airplane_sirran_status == 7 then	--island7
			e.self:Say("Nyah! The tears are welling up in my eyes! I am so proud. I think of you as if I were your father! Sniff. Sniff. Give me Veeshan, and I give you death");
		end
	elseif e.message:findi("citanul eht narris, liah") and (airplane_sirran_status == 6 or (airplane_sirran_status == 7 and sirran_six_cheese)) then 	--island6
		e.self:Say("Lortap llaw taerg eht fo lahsram, Narris lahsram ma I. Flesym ecudortni ot em wolla. Sgniteerg");
	elseif e.message:findi("llaw eht htiw eno I ma") and (airplane_sirran_status == 6 or (airplane_sirran_status == 7 and sirran_six_cheese)) then --island6
		e.self:Say("Kcul doog! Ouy rof ydaer si erips eht fo retsis eht won, sdik boj doog.");
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(71076) then -- NPC: Sister of the Spire
			eq.spawn2(71076,0,0,-929,-1035,1093,128); -- NPC: Sister of the Spire
		end
	elseif e.message:findi("traverse this plane") and airplane_sirran_status == 1 then
		e.self:Say("Ahah! Wise you are and tell you I will. Hrm? Don't have wings, do you? Fairies have swords! Fairies stole my lucky feet! Hand me them, one by one, and be in for a treat! Haha!");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 20920}) then 		-- Item: A Miniature Sword
		e.self:Say("These are the keys! Use them well! Hold them in your hand and touch them to the runed platforms! Guide you thy will! Hah! The last to go, must tell me so, or be in for a [hassle]! If there's a hassle, I will go!");
		e.other:QuestReward(e.self,{itemid = 20911}); -- Item: Key of Swords
	elseif item_lib.check_turn_in(e.trade, {item1 = 20921}) then 	-- Item: Lost Rabbit's Foot
		e.self:Say("These are the keys! Use them well! Hold them in your hand and touch them to the runed platforms! Guide you thy will! Hah! The last to go, must tell me so, or be in for a [hassle]! If there's a hassle, I will go!");
		e.other:QuestReward(e.self,{itemid = 20912}); -- Item: Key of the Misplaced
	elseif item_lib.check_turn_in(e.trade, {item1 = 20922}) then 	-- Item: Broken Mirror
		e.self:Say("You move fast, you crazy kids! Keep going! Prod you I will! Stuck here I have been! Oh! Let me know when you are [done] or this will be no fun! Haha");
		e.other:QuestReward(e.self,{itemid = 20913}); -- Item: Key of Misfortune
	elseif item_lib.check_turn_in(e.trade, {item1 = 20923}) then 	-- Item: Animal Figurine
		e.self:Say("Always want something for nothing? Oh yes, you gave me something! Here you go! Take this! Used one you have. [Teleport] away you will! Let me know, or no kill! Haha!");
		e.other:QuestReward(e.self,{itemid = 20914}); -- Item: Key of Beasts
	elseif item_lib.check_turn_in(e.trade, {item1 = 20924}) then 	-- Item: Bird Whistle
		e.self:Say("What is this? Bah! Take that! And this! What was I thinking? I was thinking you had best let me know when you use those teleporters. Just say, [Icky Bicky Barket]. Aye, that is what I was thinking.");
		e.other:QuestReward(e.self,{itemid = 20915}); -- Item: Avian Key
	elseif item_lib.check_turn_in(e.trade, {item1 = 20925}) then 	-- Item: Noise Maker
		e.self:Say("Phew! These are heavy. Well, not really. I'm sure I don't have to remind you to remind me when you are [leaving].");
		e.other:QuestReward(e.self,{itemid = 20916}); -- Item: Key of the Swarm
	elseif item_lib.check_turn_in(e.trade, {item1 = 20926}) then 	-- Item: Dull Dragon Scale
		e.self:Say("Dnib a ni era uoy ro esarhp eht yas dna yrruh!! Sruoy era syek eht dna romra em evig. Erom on gnits seixib eht ahahahahah!");
		e.other:QuestReward(e.self,{itemid = 20917}); -- Item: Key of Scale
	elseif item_lib.check_turn_in(e.trade, {item1 = 20927}) then 	-- Item: Replica of the Wyrm Queen
		e.self:Say("Not too much farther. I spit on thee knave! Ehem. Take these. Go on! Make your fortunes. No one cares about Narris. I mean Sirran. Hah! See if I care what you think! Oh, when did you say you were [leaving]?");
		e.other:QuestReward(e.self,{itemid = 20918}); -- Item: Veeshan's Key (not the one purchased on island --1 which is 20919)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_combat(e)
	if e.joined then
		e.self:Shout("What?! Now you've done it! The bunnies are angry! ANGRY I TELL YOU!");
	end
end

function event_timer(e)
	if e.timer == "bye" then
		eq.stop_timer("bye");
		eq.depop();
	elseif e.timer == "cheese" then
		eq.stop_timer("cheese");
		sirran_six_cheese = false;
	end
end

function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	eq.delete_data("airplane-sirran-".. instance_id);
end

function event_signal(e)
	if e.signal == 1 then
		eq.set_timer("cheese", 20 * 60 * 1000);
		sirran_six_cheese = true;
	end
end
