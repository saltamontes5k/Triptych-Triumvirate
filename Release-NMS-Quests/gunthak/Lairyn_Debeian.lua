-- Lairyn Debeian in Gunthak for Wizard quest Rog epic 2.0

local add_waves;
local named_spawn = false;

function event_say(e)
	local epic_pre_onefive	= 0;
	local epic_onefive		= 0;
	local epic_two			= 0;
	local epic_twofive		= 0;

	if e.other:HasClass(Class.ROGUE) then
		local data_bucket				= ("Epic-Rogue-"..e.other:CharacterID());
		if eq.get_data(data_bucket) ~= "" then
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');

			epic_pre_onefive	= tonumber(s[1]);
			epic_onefive		= tonumber(s[2]);		
			epic_two			= tonumber(s[3]);
			epic_twofive		= tonumber(s[4]);
		end
	end

	if e.other:HasClass(Class.WIZARD) then
		if e.message:findi("hail") then
			e.self:Emote("peers up from his journal and smiles at you warmly, 'Greetings, friend. I was so involved in my research that I did not hear you approaching.' He closes the leather-bound tome and pats it with one slender hand. 'Please forgive my lack of courtesy. I am Lairyn from the order of the Crimson Hands, and this little book here is my life's work. I am currently unraveling the secret of a [" .. eq.say_link("What new power?", false, "new power") .. "] that has emerged on Broken Skull Rock.");
		elseif e.message:findi("new power") then
			e.self:Say("The strange beasts known as Luggalds that reside on Broken Skull Rock have an amazing power over the dark waters of the deep. They are able to conjure it up in the form of an immense spear of ice. I have seen them do so with my own eyes, though I was watching from afar, of course. I would not dare venture close enough to anger the foul beasts. Their grasp of this magic is simply breathtaking, and from my observations alone, I am very close to unlocking their methods. Unfortunately, I have run into an obstacle, as I cannot complete my research without something more tangible. If only I were [" .. eq.say_link("I am brave enough!", false, "brave enough") .. "] to get closer, or foolish enough. As you can see, I am more intellectual than adventurer.' At this, Lairyn chuckles and his spectacles slip a little further down his nose");
		elseif e.message:findi("brave enough") then
			e.self:Emote("gasps in apparent surprise, 'What? Are you certain you wish to put yourself in such a perilous position? Well I certainly can't turn down good help, so I'll tell you what I know. The Luggalds often utilize their spells against creatures in the waters of the harbor. Whether this is for practice, or for sport, or to ward off attackers I am not sure. I would suggest investigating the harbor for further evidence. Take this bag and bring me whatever you can find.");
			e.other:SummonItem(17194); -- Small Pouch
		end
	else
		if e.message:findi("hail") then
			e.self:Emote("stares at you directly in the eyes. 'Greetings, " .. e.other:GetName() .. ".  I suppose you're here like everyone else in search of fame and fortune.  Good luck to you, and good day.  I have many things to attend to.");
		elseif epic_two == 1 and e.message:findi("lirprin sent me") then
			e.other:Message(MT.NPCQuestSay, "Lairyn Debeian is disturbingly pale for an Erudite. He looks terribly frightened. 'They'll return any moment! The shadows are everywhere, always watching . . . Waiting for me to rest so they can kill me. I try to fight them off but they always return. They whisper to me when I am all alone. No one else in the gulf believes me. You must help! Please believe that what I say is true! Oh no, here they come - please don't let the shadows take me away!'");
			add_waves = 0;
			e.self:SetRunning(true);
			e.self:MoveTo(-54.34,1584,2.9,138,true);
			eq.set_timer("move1",2 * 1000);
		end
	end
end

function event_spawn(e)
	eq.depop_all(224433);
	eq.depop_all(224434);
	eq.depop_all(224435);
	eq.depop_all(224436);
end

function event_timer(e)
	if e.timer == "move1" then
		eq.stop_timer("move1");
		e.self:MoveTo(-309,339,-45,135,true);
		eq.set_timer("move2", 45 * 1000);
	elseif e.timer == "move2" then
		eq.stop_timer("move2");
		e.self:MoveTo(-315.17,-474.23,18.2,0,true);
		eq.set_timer("move3", 30 * 1000);
	elseif e.timer == "move3" then	
		eq.stop_timer("move3");
		e.self:Shout("They're still following me! Help!");
		eq.set_timer("adds", 3 * 1000);
	elseif e.timer == "adds" then
		eq.set_timer("adds", 55 * 1000);		
		if add_waves < 5 then
			eq.spawn2(224433,0,0,e.self:GetX()-15,e.self:GetY()-15,e.self:GetZ()+3,e.self:GetHeading()):AddToHateList(e.self,500); -- NPC: a_shadowed_thug
			eq.spawn2(224434,0,0,e.self:GetX()+15,e.self:GetY()-15,e.self:GetZ()+3,e.self:GetHeading()):AddToHateList(e.self,500); -- NPC: a_shadowed_assassin
			eq.spawn2(224435,0,0,e.self:GetX()   ,e.self:GetY()-15,e.self:GetZ()+3,e.self:GetHeading()):AddToHateList(e.self,500); -- NPC: a_shadowed_enforcer
		else
			eq.stop_timer("adds");
		end		
		add_waves=add_waves+1;
		eq.set_global("rog_epic_wave",tostring(add_waves),3,"H2");		
	end
end 

function event_signal(e)
	if e.signal == 1 and not named_spawn then
		e.self:Say("Oh no . . . I'd recognize the echo of those footfalls anywhere. That sounds like Krill . . .'");
		named_spawn = true;
		eq.spawn2(224436,0,0,e.self:GetX()-15,e.self:GetY()-15,e.self:GetZ()+3,e.self:GetHeading()):AddToHateList(e.self,500); -- NPC: Krill_the_Backbleeder
	else
		e.self:Say("For my own knowledge and to bring some closure to this terror, can you bring me his head? I want to see with my own eyes. I need to know if it was him.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if e.other:HasClass(Class.WIZARD) and item_lib.check_turn_in(e.trade, {item1 = 58009}) then -- Item: Pouch of Dark Ice
		e.self:Say("You did it. I can scarely believe my eyes! This is wonderful. Let me have a closer look. Lairyn unbuckles the leather satchel and pours out the contents then begins arranging the shards in a pattern on the ground. He slides them around like pieces of a complex puzzle, swapping them backwards and forwards faster than your eyes can track. Ah yes, very clever. I am beginning to understand. This is not such a challenge after all, once you know the trick. Enough talk, I would like you to be the first to try it! Lairyn withdraws his journal again and flips through it until he locates a blank page. He scribbles furiously with a quill for several moments, then tears the page from the binding and hands it to you.");
		e.other:QuestReward(e.self,0,0,0,0,59021,eq.ExpHelper(51)); -- Spell: Frozen Harpoon
	elseif item_lib.check_turn_in(e.trade, {item1 = 52354}) then -- Cloudy Silver Potion
		e.self:SetHP(e.self:GetHP() + 3000);
	elseif e.other:HasClass(Class.ROGUE) and e.other:HasItem(52347) and item_lib.check_turn_in(e.trade, {item1 = 52344}) then -- Item: Krill's Head
		e.self:Emote("adjusts his spectacles and peers at the head, 'True enough. This is a Wayfarer . . . Errr, was at one time. I imagine he renounced his membership in the Brotherhood sometime before he took up a career of tormenting a poor scholar. They must have been trying to get to Nedaria by coming after me. I am famliar with Krill and he is a follower, not a leader. Someone else is the mastermind behind this - a person with access to magical disguises to hide their identity. [Lirprin] must know of this at once, ".. e.other:GetName() .. ".");
		eq.set_data("Epic-Rogue-Lairyn-"..e.other:CharacterID(), "1");
		eq.depop_with_timer();
		e.other:Message(MT.Yellow, "You have confirmed Lairyn's innocence.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
