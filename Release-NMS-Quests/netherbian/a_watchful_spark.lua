-- netherbian/a_watchful_spark.lua
-- Derelict Space Station (netherbian v66): the station's monitor. A harmless
-- floating wisp by the zone-in that hails the Master Officers with rotating
-- jumbled monitor lines -- half forgotten machine-liturgy, half Luclin
-- nonsense. It has never once been helpful.

local LINES = {
	"A Master Officer! We last spoke when you were someone else entirely. Or was I someone else entirely? The schedules blur.",
	"Firing the station would purge the Mildew. Or the Mildew would fire the station. I have prepared both paperwork.",
	"The Nexus storms scattered my schematics across the tunnels, and the Grey ate the rest. I have been a monitor of very little for some centuries now.",
	"This is your grave. Or mine. There were so many graves, Master Officer, and I was there for every one of them. Excellent attendance.",
	"The crew is still on duty, you know. Dedicated. Rotten, but dedicated.",
	"The Leapers of the Dark were never there. Statistically speaking, then, they cannot be here either. I would not look behind you regardless.",
	"I was there when the Deep went deep, deep into space. DEEPER. It is a matter of degrees. I keep the degrees.",
	"When the station is quiet, say my name into the dark. I do not remember my name either, but the echo enjoys the company.",
}

local next_line = 1

function event_spawn(e)
	next_line = math.random(#LINES)
	eq.zone_emote(15, "A Watchful Spark bobs in the dark, humming to itself.")
end

function event_say(e)
	e.self:Say(LINES[next_line])
	next_line = next_line % #LINES + 1
end
