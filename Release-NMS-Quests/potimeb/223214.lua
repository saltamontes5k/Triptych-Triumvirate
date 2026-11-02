--NPCID: 223214 (Zeb's cage)
--potimeb
-- Killing the cage frees Zebuxoruk (223212), who monologues (Zebuxoruk.lua)
-- and summons Druzzil Ro. An earlier pass pointed this at 223238 -- then the
-- clone -- which silently skipped the entire post-Quarm dialogue.

function event_death_complete(e)
	-- spawn Zebuxoruk
   eq.spawn2(223212,0,0,-582,-1100,0,127);
end
