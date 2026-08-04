-- Berserker Pre Epic 1.5

local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

local weakened = false;
local client = nil;

function event_spawn(e)
    if not epic_disabled then
        eq.set_next_hp_event(20);
    end
end

function event_combat(e)
    if not epic_disabled then
        if e.joined then
            client = e.other;
        else
            eq.set_timer("reset", 5 * 60 * 1000); -- 5 Minute stop timers
        end
    end
end

function event_hp(e)
	weakened = true;
    e.self:Emote(" shows signs of fatigue, leaving critical areas of his torso open to attack. The cries of war, battle and chaos fill your mind, your rage wells up, you feel ready to unleash the cried of war, battle and chaos.");
    eq.set_timer("check",15 * 1000); -- 15s
end

function event_timer(e) 
	if e.timer == "check" and weakened then
        if client ~= nil and client.valid then
            local buff_check = client:CastToClient():FindBuff(5028); -- WarCry
            if buff_check then
                if client:GetClass() == Class.BERSERKER then
                    local data_bucket = ("Epic-Berserker-"..client:CastToClient():CharacterID());
            
                    if eq.get_data(data_bucket) ~= "" then
                        local temp = eq.get_data(data_bucket);
                        s = eq.split(temp, ',');
            
                        local epic_pre_onefive	= tonumber(s[1]);
            
                        if epic_pre_onefive == 7 then
                            client:Message(MT.NPCQuestSay, "Broken Skull Armsmaster falls victim to the berserkers cries of war, battle and chaos.");
                            eq.stop_timer(e.timer);
                        end
                    end
                end
            end
        end
    elseif e.timer == "reset" then
        weakened = false;
        client = nil;
        eq.stop_all_timers();
    end
end

function event_killed_merit(e) -- Triggers on everyone -- TODO This is WFH custom implementation of the berserker epic line. PEQ does not have the ZKR Pre epic 1.5
    if not epic_disabled then
        if e.other:HasClass(Class.BERSERKER) then
            local data_bucket = ("Epic-Berserker-"..e.other:CharacterID());

            if eq.get_data(data_bucket) ~= "" then
                local temp = eq.get_data(data_bucket);
                s = eq.split(temp, ',');

                local epic_pre_onefive	= tonumber(s[1]);
                local epic_onefive		= tonumber(s[2]);
                local epic_two			= tonumber(s[3]);
                local epic_twofive		= tonumber(s[4]);

                if epic_pre_onefive == 7 then
                    e.other:Message(MT.Red, "You feel the rage well up deep inside you. Within moments, your mind becomes cloudy, your judgment impaired, and your actions more fierce with each swing.");
                    e.other:SummonItem(13640); -- Item: Fine Steel Net
                    update_berserker_epic_databucket(e,8,epic_onefive,epic_two,epic_twofive);
                end
            end
        end
    end
end

function update_berserker_epic_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Berserker-"..e.other:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.other:Message(MT.Yellow, "Your quest has been advanced");
end
