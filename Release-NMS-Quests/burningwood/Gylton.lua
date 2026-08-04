function event_combat(e)
	local random_result = math.random(60);
	
	if e.joined then
		e.self:Say("You will perish!!  You are weak and should have kept to your own realm!!");
		if random_result <=20  then
			e.self:Say(e.other:GetClassName() .. " like you always bring out the worst in me!");
		elseif random_result <= 40 then
			e.self:Say("I really hate " .. e.other:GetClassName() .. " like you!");
		else
			e.self:Say(e.other:GetClassName() .. " like you are an affront to my senses!");
		end
	end
end

function event_death_complete(e)
	e.self:Emote("slams to the ground with a loud THUD!!  The ground around you still trembles.  'Now.. I shall never slay my blasphemous.. brother..  Xyl..'");
end
