-- Innoruk Event

-- Spawn (Timer in ms)
function event_spawn(e)
    e.self:Shout("You fools! I shall tear the life from your bodies for this trespass, and what you have done to my creations!");
end

function event_death_complete(e)
    if killer and math.random(1, 100) == 1 then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end
end
