-- Modified from original by Jaekob and Cata
function event_spawn(e)
        eq.zone_emote(1, "The ground rumbles as the Guardian of Doomfire collapses to the ground dead. Then a loud booming voice is heard saying. 'Come little mortals! Feel the chaos of the fires that flame the dark rage. Test yourselves against the might of my armies!'")
        eq.spawn_condition("pofire", eq.get_zone_instance_id(), 1, 0)
        eq.spawn_condition("pofire", eq.get_zone_instance_id(), 2, 0)
        eq.set_timer("Wave", 30 * 1000) -- 30 seconds
end

function event_timer(e)
        if e.timer == "Wave" then
                local spawnwave = true
                local mobIDs = {
                        217102,
                        217103,
                        217101,
                        217100,
                        217087,
                        217088,
                        217077,
                        217078,
                        217079,
                        217080,
                        217081,
                        217082,
                        217083,
                        217084,
                }
                local entityList = eq.get_entity_list()
                for _, npcTypeID in ipairs(mobIDs) do
                        if entityList:IsMobSpawnedByNpcTypeID(npcTypeID) then
                                spawnwave = false
                                break
                        end
                end
                if spawnwave then
                        local fennin = tonumber(eq.get_zone():GetVariable("Fennin")) or 0
                        if fennin == 1 then
                                eq.spawn_condition("pofire", eq.get_zone_instance_id(), 1, 1)
                                eq.zone_emote(1, "Four enraged roars of fury echo from further down the bridge over the cacophany of an army waiting to hand out death. The powerful voice is then heard saying, 'Rexanous, Azobian, Hebabbilys, and Javonn! Come destroy these intruders.'")
                                eq.spawn2(217079, 0, 0, -1325, -1521.6, -202.2, 197.8) -- NPC: Javonn_the_Overlord
                                eq.spawn2(217080, 0, 0, -1283.4, -1568.4, -222.5, 191.2) -- NPC: Reaxnous_the_Chaoslord
                                eq.spawn2(217077, 0, 0, -1285.1, -1520.2, -202.2, 176.6) -- NPC: Azobian_the_Darklord
                                eq.spawn2(217078, 0, 0, -1350.4, -1559, -202.2, 171)      -- NPC: Hebabbilys_the_Ragelord
                                eq.get_zone():SetVariable("Fennin", "2")
                        elseif fennin == 2 then
                                eq.spawn_condition("pofire", eq.get_zone_instance_id(), 1, 0)
                                eq.zone_emote(1, "As the last of the army is defeated visions of endless burning flames intrude into your mind. Suddenly the visions ends as a call comes from just ahead saying, 'Prepare to meet your end at the hands of the Council of Fire!'")
                                eq.spawn2(217083, 0, 0, -1459.5, -1150, -197.2, 255.2) -- NPC: Chancellor_Traxom
                                eq.spawn2(217084, 0, 0, -1545.1, -1147.5, -197.2, 261.2) -- NPC: Chancellor_Kirta
                                eq.spawn2(217082, 0, 0, -1432.1, -902.2, -185.8, 269.6) -- NPC: Omni_Magus_Crato
                                eq.spawn2(217081, 0, 0, -1578.1, -904.1, -185.8, 265.6) -- NPC: Warlord_Prollaz
                                eq.get_zone():SetVariable("Fennin", "3")
                        elseif fennin == 3 then
                                eq.spawn_condition("pofire", eq.get_zone_instance_id(), 2, 1)
                                eq.zone_emote(1,"A maddened call of endless fury erupts as a burning creature of pure destructions stands tall before you. The creature then speaks in the loud booming voice of immense power saying, 'You are fools to have come this far. Prepare to tremble at the might of Doomfire!'")
                                eq.stop_timer("Wave")
                                eq.spawn2(217054, 0, 0, -1578.1, -904.1, -185.8, 265.6) -- NPC: Fennin_Ro_the_Tyrant_of_Fire
                                eq.get_zone():SetVariable("Fennin", "4")
                        else
                                eq.stop_timer("Wave")
                        end
                end
        end
end


-- End of File  Zone: PoFire  ID: 217076  -- #Fennin_Ro_the_Tyrant_of_Fire
-- Untargetable
-- Zone Emotes added by Covou
