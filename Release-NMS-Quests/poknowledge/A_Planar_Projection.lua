function event_say(e)
	local messages = {
		Hail = "I am not who you seek.",
		["Darkness Beckons"] = {
			check = {
				"construct", "hedge"
			},
			zone = "nightmareb",
			text = "Lair of Terris Thule"
		},
		["the war drums echo"] = {
			check = {
				"behemoth"
			},
			zone = "potactics",
			text = "Drunder, Fortress of Zek"
		},
		["I will destroy the plaguebringer"] = {
			check = {
				"adler", "elder", "grummus"
			},
			zone = "codecay",
			text = "Ruins of Lxanvom"
		},
		["I am familiar with the order"] = {
			check = {
				"mavuin", "tribunal", "valor"
			},
			zones = {"postorms", "povalor"},
			text = "Plane of Valor and Plane of Storms"
		},
		["My Valor is Unmatched"] = {
			check = {
				"aerin", "mavuin", "tribunal", "valor"
			},
			zone = "hohonora",
			text = "Halls of Honor"
		},
		["I will defeat the Storm Lord"] = {
			check = {
				"askr", "mavuin", "tribunal", "valor"
			},
			values = {
				4, -- askr
				1, -- mavuin
				1, -- tribunal
				1 -- valor
			},
			zone = "bothunder",
			text = "Bastion of Thunder"
		},
		["I am ready to face Lord Mithaniel Marr"] = {
			check = {
				"aerin", "askr", "faye", "mavuin",
				"trell", "tribunal", "valor"
			},
			values = {
				1, -- aerin
				4, -- askr
				1, -- faye
				1, -- mavuin
				1, -- trell
				1, -- tribunal
				1 -- valor
			},
			zone = "hohonorb",
			text = "Temple of Marr"
		},
		["I will defeat Saryrn"] = {
			check = {
				"adler", "bertox", "codecay", "construct", "elder",
				"grummus", "hedge", "poxbourne", "terris"
			},
			values = {
				1, -- alder
				1, -- bertox
				2, -- codecay
				1, -- construct
				1, -- elder
				1, -- grummus
				1, -- hedge
				1, -- poxbourne
				1 -- terris
			},
			zone = "potorment",
			text = "Plane of Torment"
		},
		["No gladiator shall match me"] = {
			check = {
				"behemoth", "marr", "saryrn", "tallon", "vallon"
			},
			values = {
				2, -- behemoth
				1, -- marr
				2, -- saryrn
				1, -- tallon
				1 -- vallon
			},
			zone = "solrotower",
			text = "Tower of Solusek Ro"
		},
		["I am a child of fire"] = {
			check = {
				"arlyxir", "behemoth",
				"dresolik", "jiva", "marr", "rallos",
				"rizlona", "saryrn", "solusek",
				"tallon", "vallon", "xuzl"
			},
			values = {
				1, -- arlyxir
				2, -- behemoth
				1, -- dresolik
				1, -- jiva
				1, -- marr
				1, -- rallos
				1, -- rizlona
				2, -- saryrn
				1, -- solusek
				1, -- tallon
				1, -- vallon
				1 -- xuzl
			},
			zone = "pofire",
			text = "Plane of Fire"
		},
		["I am worthy of the elemental planes"] = {
			check = {
				"aerin", "agnarr", "adler", "askr",
				"bertox", "codecay",
				"construct", "elder", "faye", "garn",
				"librarian", "grummus", "hedge",
				"marr", "mavuin", "poxbourne", "saryrn",
				"shadyglade", "terris",
				"trell", "tribunal", "valor"
			},
			values = {
				1, -- aerin
				1, -- agnarr
				1, -- alder
				4, -- askr
				1, -- bertox
				2, -- codecay
				1, -- construct
				1, -- elder
				1, -- faye
				1, -- garn
				1, -- librarian
				1, -- grummus
				1, -- hedge
				1, -- marr
				1, -- mavuin
				1, -- poxbourne
				2, -- saryrn
				1, -- shadyglade
				1, -- terris
				1, -- trell
				1, -- tribunal
				1 -- valor
			}.
			zones = {"poair", "powater", "poeartha"},
			text = "Reef of Corniav, Vegarlson, and Eryslai"
		}
	}
	
	for trigger, data in pairs(messages) do
		if e.message:findi(trigger) then
			if type(data) == "string" then
				e.other:Message(MT.DimGray, data)
				return
			end

			local pass = true
			for i, flag in ipairs(data.check) do
				local current_flag = string.format("pop.flags.%s", flag)
				if tonumber(e.other:GetAccountBucket(current_flag)) ~= (data.values and data.values[i] or 1) then
					pass = false
					break
				end
			end

			if pass then
				e.other:Message(
					MT.DimGray,
					string.format(
						"Very well mortal... you shall pass into %s.",
						data.text
					)
				)

				if data.zone then
					e.other:SetZoneFlag(Zone[data.zone])
				end

				if data.zones then
					for _, z in ipairs(data.zones) do
						e.other:SetZoneFlag(Zone[z])
					end
				end

				e.other:Message(
					MT.Green,
					string.format(
						"You now have access to %s!",
						data.text
					)
				)
			end

			return
		end
	end
end
