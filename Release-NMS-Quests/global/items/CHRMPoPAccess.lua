function event_scale_calc(e)
	local ent_var_key = "pop_charm_flag_count";
	local ent_var_time = "pop_charm_flag_lastcalc";
	local cache_expire_time = 600; -- 10 minutes
	local now = os.time()

	-- Check if cached value exists and is fresh
	if e.owner:EntityVariableExists(ent_var_key) and e.owner:EntityVariableExists(ent_var_time) then
		local last_calc = tonumber(e.owner:GetEntityVariable(ent_var_time)) or 0
		if (now - last_calc) < cache_expire_time then
			local cached_count = tonumber(e.owner:GetEntityVariable(ent_var_key)) or 0
			eq.debug("returning cached pop_charm_flag_count " .. cached_count, 3)
			e.self:SetScale(cached_count / 10);
			return
		end
	end

	-- Recalculate
	local flags = {
		["pop.flags.aerin"] = 1,
		["pop.flags.askr"] = 4,
		["pop.flags.behemoth"] = 2,
		["pop.flags.codecay"] = 2,
		["pop.flags.elder"] = 1,
		["pop.flags.librarian"] = 1,
		["pop.flags.maelin"] = 1,
		["pop.flags.marr"] = 1,
		["pop.flags.solusek"] = 1,
		["pop.flags.valor"] = 1
	}

	local flag_count = 0
	for flag, required_value in pairs(flags) do
		local current_bucket = tonumber(e.owner:GetAccountBucket(flag)) or 0
		if current_bucket == required_value then
			flag_count = flag_count + 1
		end
	end

	eq.debug("Calculating new pop charm value " .. tostring(flag_count), 3)

	-- Cache new result and timestamp
	e.owner:SetEntityVariable(ent_var_key, tostring(flag_count))
	e.owner:SetEntityVariable(ent_var_time, tostring(now))

	e.self:SetScale(flag_count / 10);
end
