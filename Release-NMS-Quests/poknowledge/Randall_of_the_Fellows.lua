function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Welcome! Press Control, Shift and F to open your Fellowship window. Create a fellowship, then target a friend and invite them. I can explain your [campfire], [experience sharing], or replace your [insignia].")
    elseif e.message:findi("campfire") then
        e.self:Say("Gather your fellowship within a hundred paces, outside combat. In your Fellowship window, open Camp, refresh the list, select Fellowship of Honor, and create your campfire. It lasts one hour. Click your registration insignia to return to it. You must still have permission to enter its zone or instance.")
    elseif e.message:findi("experience sharing") then
        e.self:Say("Use Toggle XP in your Fellowship window to participate. Combat experience is divided among participating members, including those offline. Their share becomes vitality, which they earn as bonus experience from later battles.")
    elseif e.message:findi("insignia") or e.message:findi("how") then
        if e.other:HasItem(34023) then
            e.self:Say("You already have your Fellowship Registration Insignia. Use it to return to your active campfire.")
        else
            e.other:SummonItem(34023)
            e.self:Say("Here is your Fellowship Registration Insignia. It can take you to your campfire while you belong to a fellowship.")
        end
    end
end
