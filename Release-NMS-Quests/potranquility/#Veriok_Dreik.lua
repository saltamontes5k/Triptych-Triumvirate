function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings, fellow adventurer!")
	end
end

function event_trade(e)
end