local thunder_dome_locs 		= {[1] = {-1833.56, -1077.92, -16.87, 133}, [2] = {-1831.30, 1639.81, -16.87, 133}, [3] = {-66.72, 1639.5, -18.12, 133} };
local hut_locs = {-629.07, 289.83, -13.75, 133};
local controllers				= {281145, 281164, 281185};
local mass_of_stones			= {281146, 281076, 281041};
local encounter_names			= {"thunder_dome_one", "thunder_dome_two", "thunder_dome_three"};
local thunder_dome_id;
local raid_id_by_thunder_dome	= {};
local zone_id					= eq.get_zone_id();
task_ids = require('task_ids')

function event_say(e)
	local qglobals = eq.get_qglobals(e.self, e.other);
	local instance_id = eq.get_zone_instance_id();
	local raid = e.other:GetRaid();
	local raid_id = raid:GetID();
	local event_up_1 = eq.get_entity_list():GetMobByNpcTypeID(mass_of_stones[1]);
	local event_up_2 = eq.get_entity_list():GetMobByNpcTypeID(mass_of_stones[2]);
	local event_up_3 = eq.get_entity_list():GetMobByNpcTypeID(mass_of_stones[3]);
	local x = e.self:GetX();
	local y = e.self:GetY();

	if x ~= -640 and y ~= 257 then
		if e.message:findi("depart") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan nods his head and focuses on the small piece of rock.  In a flash, you are transported back to his hut.")
			local instance_id = eq.get_zone_instance_id();
			local event_group = e.other:GetGroup();
			if (event_group ~= nil and event_group.valid) then
				MoveGroup(event_group, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 75, unpack(hut_locs));
			else 
				e.other:MovePCInstance(zone_id, instance_id, unpack(hut_locs));
			end
		elseif e.message:findi("hail") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'Amazing!  I did not believe that anyone could stand up to the commanders of these muramite forces and live to tell the tale!  I hope you found something useful in your search of her body.  If you are ready to [" .. eq.say_link("depart") .. "] this place, please just say so.'");
		end
  elseif e.other:IsTaskActivityActive(task_ids.bic_qinimi, 11) or e.other:IsTaskActivityActive(task_ids.bic_qinimi, 12) or e.other:GetGM() then
		if e.message:findi("ritual") then
			e.other:Message(MT.NPCQuestSay, "While animating stone comes easy for us, sometimes we need an extremely powerful stone worker to help with the city. These stone servants were made through a ritual which combined the power of eight geomancers into a ninth. This geomancer would then imbue a stone worker with this power, resulting in a more powerful construct. We stopped doing the ritual when we discovered that it could take away our ability over time. If [" .. eq.say_link('she') .. "] has somehow figured out a way to absorb this power, then my people could be in more danger than I thought possible.'");
		elseif e.message:findi("she") then
			e.other:Message(MT.NPCQuestSay, "We refer to her as the silent one, but the legion calls her Xictic. She is one of their kind who can use magic and she seems to be quite feared by everyone in this area. She comes here sometimes and takes three of us into the building with the glowing dome around it. Along with her are eight magic-using invaders and some of the slavers. When they are finished, only members of the legion leave. None of my people who enter are ever seen again. If what this says is true, you must stop her. If she succeeds, she will be able to control our stone servants at will and cause even more destruction. I beg you to stop her. I will help you in any way if you [" .. eq.say_link('promise') .. "] to stop her.'");
		elseif e.message:findi("promise") then
			e.other:Message(MT.NPCQuestSay, "I cannot tell you how relieved this makes me. Now to the issue at hand. While Xictic and those she chooses can roam freely in and out of the magical dome surrounding the chamber, if anyone else tries to enter they are held back. As a councilman, I was granted a device that allows access into the dome and I've managed to keep it away from the prying eyes of the Mata Muram. Using it is not without its consequences, though. As soon as an outsider shows up within the dome, they will know what has occurred and will come searching for the culprit so be certain you are ready to face the challenges ahead before you embark upon this venture. Only eighteen of you will be allowed into the chamber at one time so gather your forces and tell me you are [" .. eq.say_link('ready') .. "] to face Xictic.'");
      e.other:UpdateTaskActivity(task_ids.bic_qinimi, 11, 1)
    end
	  if e.message:findi("ready") then
			e.self:Emote("pulls out a small stone and closes it in his hand. 'Please be careful. What you are about to see may shock you at first, but don't let yourself be distracted for too long. These beings are merciless and once they have discovered your presence, they will stop at nothing to add your corpse to the others in the area.'");
			if qglobals["gates_thunder_dome_event_1"] == nil and event_up_1.valid and raid_id_by_thunder_dome[1] == nil then
				raid_id_by_thunder_dome[1] = raid_id;	-- assign new raid id
				thunder_dome_id = 1;					-- thunder_dome_id 1 available
			elseif qglobals["gates_thunder_dome_event_2"] == nil and event_up_2.valid and raid_id_by_thunder_dome[2] == nil then
				raid_id_by_thunder_dome[2] = raid_id;	-- assign new raid id
				thunder_dome_id = 2;					-- thunder_dome_id 2 available
			elseif qglobals["gates_thunder_dome_event_3"] == nil and event_up_3.valid and raid_id_by_thunder_dome[3] == nil then
				raid_id_by_thunder_dome[3] = raid_id;	-- assign new raid id
				thunder_dome_id = 3;					-- thunder_dome_id 3 available
			else
				thunder_dome_id = -1;					-- no thunder_dome_ids available
			end

      -- Force players into Thunder Dome 2
      thunder_dome_id = 2
      raid_id_by_thunder_dome[2] = raid_id;

			if thunder_dome_id > 0 and thunder_dome_id < 4 and raid_id_by_thunder_dome[thunder_dome_id] == raid:GetID() then
				local instance_id = eq.get_zone_instance_id();
				local event_group = e.other:GetGroup();
				if (event_group ~= nil and event_group.valid) then
					MoveGroup(event_group, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 75, unpack(thunder_dome_locs[thunder_dome_id]));
				else 
					e.other:MovePCInstance(zone_id, instance_id, unpack(thunder_dome_locs[thunder_dome_id]))
				end
				eq.depop_all(mass_of_stones[thunder_dome_id]) -- Depop TD_Status_One Prior
				eq.load_encounter(encounter_names[thunder_dome_id]);
			else
				e.self:Say("Heroes, it is too dangerous to confront Xictic at this time. You must wait until a more opportune moment to strike.");
			end
		end
  elseif e.other:IsTaskActivityActive(task_ids.bic_qinimi, 6) then
		if e.message:findi("thing") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'The geomantic device which raises you into the courtroom is an ancient one and takes time to reset after it has been used. If you are having trouble entering, be patient. You will know it is ready to receive a key when you hear a grinding sound from the base of the device as it settles into place. Please be sure you are fully prepared before entering. While it once was a place of peaceful discussion, the courtroom is now a place where terrible torture is conducted by those the legion wants information from. When they see uninvited guests, they will not be very happy. The leader of this area's force is known as Tixxrt and stopping him is the only way you can save the small one, called Kreshin.'");
    end
	elseif e.other:IsTaskActivityActive(task_ids.bic_qinimi, 4) then
		if e.message:findi("stone of entry") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'Gaining access to such a private place has always been reserved for the elders of my people. While the legion may have destroyed our home, they have yet to figure out a way around many of our wards that bar access to our sacred areas. Unfortunately, their frustration at gaining entry resulted in the painful torture of many of my people until they were given the keys to enter. The courtroom requires one of these keys and while the invaders hold all of the existing keys, I can create one if you can retrieve the proper [" .. eq.say_link('items') .. "].'");
		elseif e.message:findi("items") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'The key consists of mud, some stonedust particles, and a piece of chalk. The mud can be found in the sewers beneth the city. The stonedust is plentiful near the coliseum, and the chalk can be found all over this area. Bring these to me and I will make you a temporary key which will grant you access to the courtroom. I implore you to hurry. I fear the one you seek may not be alive much longer.'");
		end
	else
		if e.message:findi("hail") then
			e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'While I place my own life at risk by helping you, I feel a strong sense of honor amongst you and those who have come with you. It is because of this that I will try to help in anyway I can.'")
		end
	end
end

function event_signal(e)
	raid_id_by_thunder_dome[e.signal] = nil;
	eq.delete_global("gates_thunder_dome_event_" .. e.signal);
	eq.depop_all(controllers[e.signal])									-- Depop TD_Status Prior
	eq.unload_encounter(encounter_names[e.signal]);						-- Unload Encounter
	eq.spawn2(controllers[e.signal],0,0,-1745.66,-1078.70,-16.50,128);	-- TD_Status
	eq.signal(controllers[e.signal],1);									-- TD_Status - Start booting anyone who zones in after event
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 67700}) then -- Item: Kreshin's Journal Page
		e.other:Message(MT.NPCQuestSay, "Councilman Sislono Nislan says, 'Yes, I have seen this and others like it before. While we do not understand where it comes from, we have come to the conclusion that these strange glyphs express somthing important to your people. These particular glyphs were made by the small one they hold captive in the courtroom. If you wish to help him, you will have to retrieve the [" .. eq.say_link('stone of entry') .. "]. Only with this stone can you enter the courtroom and help the one who calls himself Kreshin.");
  elseif item_lib.check_turn_in(e.trade, {item1 = 67398, item2 = 67399, item3 = 67400}) then --Stonedust Particles
      give_stone(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 67400}) then -- Piece of Chalk
    e.other:UpdateTaskActivity(task_ids.bic_qinimi, 3, 1)
    if not e.other:IsTaskActivityActive(task_ids.bic_qinimi, 3) and not e.other:IsTaskActivityActive(task_ids.bic_qinimi, 4) and not e.other:IsTaskActivityActive(task_ids.bic_qinimi, 5) then
      give_stone(e)
    end
	elseif item_lib.check_turn_in(e.trade, {item1 = 67403}) then -- Writ of the Magi
		e.other:Message(MT.NPCQuestSay, "These glyphs look quite familiar. They are definitely in my language, but it seems as if the one who etched them did so against his will. Where did you get this? Wait, don't tell me. I know. Kreshin must have been successful in finding out what was going on in the Chamber of Souls. These glyphs detail how to animate stone using our geomancy abilities. There are some strange symbols toward the bottom, but for the most part, this is our language. Could he be trying to conduct the [" .. eq.say_link('ritual') .. "] of my people?'");
    e.other:UpdateTaskActivity(task_ids.bic_qinimi, 10, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function give_stone(e)
  e.other:Message(MT.NPCQuestSay, "Sislono covers the three pieces in his hands, closes his eyes, and begins to chant. A glow begins to emanate from his hands and he begins to chant louder. Then, just as quickly as it began, the glow in his hands dims and the chanting stops. 'There you are -- the key which grants you and your party access to the courtroom. Just stand on the pedestal in the center of the large building in this part of the city with the key in your hand and say you wish to enter. There is one more [" .. eq.say_link('thing') .. "] I must tell you before you go.'");
  e.other:SummonItem(67415)
end

