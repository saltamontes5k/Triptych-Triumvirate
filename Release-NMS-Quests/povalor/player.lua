function event_click_door(e)
	local door_id = e.door:GetDoorID()
	if door_id == 3 then
		local aerin_bucket = tonumber(e.self:GetAccountBucket("pop.flags.aerin")) or 0
		local alt_access_hohonora_bucket = tonumber(e.self:GetAccountBucket("pop.alt.hohonora")) or 0
		local mavuin_bucket = tonumber(e.self:GetAccountBucket("pop.flags.mavuin")) or 0
		local tribunal_bucket = tonumber(e.self:GetAccountBucket("pop.flags.tribunal")) or 0
		local valor_bucket = tonumber(e.self:GetAccountBucket("pop.flags.valor")) or 0
		if (
			e.self:GetLevel() >= 62 or
			alt_access_hohonora_bucket == 1 or
			(
				aerin_bucket == 1 and
				mavuin_bucket == 1 and
				tribunal_bucket == 1 and
				valor_bucket == 1
			)
		) then
			if not e.self:HasZoneFlag(Zone.hohonora) then
				e.self:SetZoneFlag(Zone.hohonora)
				e.self:Message(MT.LightBlue, "You receive a character flag!")
			end
		else
			e.self:Message(MT.Yellow, "For alternate access you will need to speak with Grenic Drere.")
			e.self:Message(
				MT.Yellow,
				string.format(
					"Flag: Halls of Honor A Alternate Access Current: %d Required: 1",
					alt_access_hohonora_bucket
				)
			)

			e.self:Message(MT.Yellow, "The flags required to enter Halls of Honor are as follows:")
			
			local flags_required = {
				"pop.flags.aerin",
				"pop.flags.mavuin",
				"pop.flags.tribunal",
				"pop.flags.valor"
			}

			for _, flag in pairs(flags_required) do
				local flag_name = string.gsub(flag, "pop.flags.", "")
				local flag_value = tonumber(e.self:GetAccountBucket(flag)) or 0
				e.self:Message(
					MT.Yellow,
					string.format(
						"Flag: %s Current: %d Required: 1",
						flag_name,
						flag_value
					)
				)
			end
		end
	end
end
