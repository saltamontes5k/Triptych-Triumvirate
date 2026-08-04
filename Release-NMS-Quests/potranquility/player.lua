local door_requirements = {
	[16] = {
		flags = {
			"mavuin", "tribunal", "valor"
		},
		zones = {
			Zone.povalor, Zone.postorms
		},
		level = 55
	},
	[21] = {
		flags = {
			"mavuin", "tribunal", "valor"
		},
		zones = {
			Zone.povalor, Zone.postorms
		},
		level = 55
	},
	[12] = {
		flags = {
			"adler", "elder", "grummus"
		},
		zones = {
			Zone.codecay
		},
		level = 55,
		alt_access = "codecay"
	},
	[93] = {
		flags = {
			"adler", "bertox", "codecay", "construct",
			"grummus", "hedge", "poxbourne", "terris"
		}, 
		zones = {
			Zone.potorment
		},
		level = 55,
		alt_access = "potorment"
	},
	[48] = {
		flags = {
			"askr", "mavuin", "tribunal", "valor"
		},
		zones = {
			Zone.bothunder
		},
		level = 62
	},
	[23] = {
		flags = {
			"aerin", "mavuin", "tribunal", "valor"
		},
		zones = {
			Zone.hohonora
		},
		level = 62,
		alt_access = "hohonora"
	},
	[24] = {
		flags = {
			"behemoth"
		},
		zones = {
			Zone.potactics
		},
		alt_access = "potactics"
	},
	[22] = {
		flags = {
			"agnarr", "behemoth", "marr", "rallos", "saryrn", "tallon", "vallon"
		}, 
		zones = {
			Zone.solrotower
		},
		alt_access = "solrotower"
	},
	[82] = {
		flags = {
			"solusek"
		}, 
		zones = {
			Zone.pofire
		},
		alt_access = "solrotower"
	},
	[81] = {
		flags = {
			"aerin", "agnarr", "adler", "askr",
			"bertox", "codecay", "construct", "elder",
			"faye", "garn", "librarian", "grummus", "hedge", "marr",
			"mavuin", "poxbourne", "saryrn",  "shadyglade",
			"terris", "tribunal", "trell", "valor"
		}, 
		zones = {
			Zone.poair, Zone.powater, Zone.poeartha
		}
	},
	[83] = { same_as = 81 },
	[84] = { same_as = 81 },
	[222] = {
		flags = {
			"arbitor"
		},
		zones = {
			Zone.poearthb
		}
	},
	[145] = {
		flags = {
			"maelin"
		},
		zones = {
			Zone.potimea, Zone.potimeb
		}
	}
}

function event_click_door(e)
	local door_id = e.door:GetDoorID()
	local req = door_requirements[door_id]
	if not req then
		return
	end

	if req.same_as then
		req = door_requirements[req.same_as]
	end

	local has_all_flags = true
	for _, flag in ipairs(req.flags or {}) do
		local current_flag = string.format("pop.flags.%s", flag)
		local required_value = 1

		if flag == "askr" then
			required_value = 4
		elseif (
			flag == "behemoth" or
			flag == "codecay" or
			flag == "saryrn"
		) then
			required_value = 2
		end

		if tonumber(e.self:GetAccountBucket(current_flag)) ~= required_value then
			has_all_flags = false
			break
		end
	end

	if has_all_flags then
		for _, zone in ipairs(req.zones) do
			if not e.self:HasZoneFlag(zone) then
				e.self:SetZoneFlag(zone)
				e.self:Message(MT.LightBlue, "You receive a character flag!")
			end
		end
	end
end

function event_enter_zone(e)
	for _, req in pairs(door_requirements) do
		if req.same_as then
			req = door_requirements[req.same_as]
		end

		local has_all_flags = true
		for _, flag in ipairs(req.flags or {}) do
			local current_flag = string.format("pop.flags.%s", flag)
			local required_value = 1
	
			if flag == "askr" then
				required_value = 4
			elseif (
				flag == "behemoth" or
				flag == "codecay" or
				flag == "saryrn"
			) then
				required_value = 2
			end
	
			if tonumber(e.self:GetAccountBucket(current_flag)) ~= required_value then
				has_all_flags = false
				break
			end
		end
	
		if has_all_flags then
			for _, zone in ipairs(req.zones) do
				if not e.self:HasZoneFlag(zone) then
					e.self:SetZoneFlag(zone)
					e.self:Message(MT.LightBlue, "You receive a character flag!")
				end
			end
		end
	end
end