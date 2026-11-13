-- a_summoned_minion_ (223229) part of Rallos Zek p5 adds
function event_signal(e)

        if e.signal == 1 then -- Attack!
                -- the old call chained a missing call-paren with an unbound
                -- CopyHateList method, so the add never joined Rallos's hate
                local rz = eq.get_entity_list():GetMobByNpcTypeId(223168);
                if rz ~= nil and rz:GetTarget() ~= nil then
                        e.self:AddToHateList(rz:GetTarget(), 1);
                end
        end

end
