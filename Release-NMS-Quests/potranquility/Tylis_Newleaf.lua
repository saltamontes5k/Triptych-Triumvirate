function event_say(e)
	local saryrn_bucket = tonumber(e.other:GetAccountBucket("pop.flags.saryrn")) or 0
	if e.message:findi("hail") and saryrn_bucket == 1 then
		e.self:Say("Thank you for rescuing me. I am forever in your debt. For now, I just need to recover.")
	end
end
