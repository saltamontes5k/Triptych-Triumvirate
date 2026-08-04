function event_say(e)
    local flags = {
        {
            key = "hedge",
            set_message = "You have spoken to Jezith within the Plane of Tranquility for the Hedge preflag by saying tormented by nightmares.",
            unset_message = "You have NOT spoken to Jezith within the Plane of Tranquility for the Hedge preflag by saying tormented by nightmares."
        },
        {
            key = "construct",
            set_message = "You have killed the Construct of Nightmares.",
            unset_message = "You have NOT killed the Construct of Nightmares."
        },
        {
            key = "terris",
            set_message = "You have killed Terris Thule.",
            unset_message = "You have NOT killed Terris Thule."
        },
        {
            key = "poxbourne",
            set_message = "You have talked to Poxbourne in the Plane of Tranquility after defeating Terris Thule.",
            unset_message = "You have NOT talked to Poxbourne in the Plane of Tranquility after defeating Terris Thule."
        },
        {
            key = "xanamech",
            set_message = "You have killed the dragon within the Plane of Innovation.",
            unset_message = "You have NOT killed the dragon within the Plane of Innovation."
        },
        {
            key = "behemoth",
            conditions = {
                {
                    required_value = 1,
                    set_message = "You have talked to the Gnome within the Plane of Innovation factory.",
                    unset_message = "You have NOT talked to the Gnome within the Plane of Innovation factory."
                },
                {
                    required_value = 2,
                    set_message = "You have defeated the Behemoth within the Plane of Innovation and then QUICKLY hailed the Gnome in the factory.",
                    unset_message = "You have NOT defeated the Behemoth within the Plane of Innovation and then QUICKLY hailed the Gnome in the factory."
                },
            }
        },
        {
            key = "adler",
            set_message = "You have talked to Adler Fuirstel outside of the Plane of Disease.",
            unset_message = "You have NOT talked to Adler Fuirstel outside of the Plane of Disease."
        },
        {
            key = "grummus",
            set_message = "You have defeated Grummus.",
            unset_message = "You have NOT defeated Grummus."
        },
        {
            key = "elder",
            set_message = "You have talked to Elder Fuirstel in the Plane of Tranquility.",
            unset_message = "You have NOT talked to Elder Fuirstel in the Plane of Tranquility."
        },
        {
            key = "mavuin",
            set_message = "You have talked to Mavuin, and have agreed to plea his case to The Tribunal.",
            unset_message = "You have NOT talked to Mavuin, and agreed to plea his case to The Tribunal."
        },
        {
            key = "tribunal",
            set_message = "You have shown the Tribunal the mark from the trial you have completed.",
            unset_message = "You have NOT shown the Tribunal the mark from the trial you have completed."
        },
        {
            key = "valor",
            set_message = "You have returned to Mavuin, letting him know the tribunal will hear his case.",
            unset_message = "You have NOT returned to Mavuin to tell him the tribunal will hear his case."
        },
        {
            key = "execution",
            set_message = "You have completed the Trial of Execution.",
            unset_message = "You have NOT completed the Trial of Execution."
        },
        {
            key = "flame",
            set_message = "You have completed the Trial of Flame.",
            unset_message = "You have NOT completed the Trial of Flame."
        },
        {
            key = "hanging",
            set_message = "You have completed the Trial of Hanging.",
            unset_message = "You have NOT completed the Trial of Hanging."
        },
        {
            key = "lashing",
            set_message = "You have completed the Trial of Lashing.",
            unset_message = "You have NOT completed the Trial of Lashing."
        },
        {
            key = "stoning",
            set_message = "You have completed the Trial of Stoning.",
            unset_message = "You have NOT completed the Trial of Stoning."
        },
        {
            key = "torture",
            set_message = "You have completed the Trial of Torture.",
            unset_message = "You have NOT completed the Trial of Torture."
        },
        {
            key = "aerin",
            set_message = "You have defeated the prismatic dragon, Aerin`Dar, within the Plane of Valor.",
            unset_message = "You have NOT defeated the prismatic dragon, Aerin`Dar, within the Plane of Valor."
        },
        {
            key = "askr",
            set_message = "You have killed the giants within the Plane of Storms and completed Askr's task.",
            unset_message = "You have NOT killed the giants within the Plane of Storms to complete Askr's task.",
            required_value = 4
        },
        {
            key = "codecay",
            conditions = {
                {
                    required_value = 1,
                    set_message = "You have completed the Carprin cycle within Ruins of Lxanvom.",
                    unset_message = "You have NOT completed the Carprin Cycle within Ruins of Laxanvom."
                },
                {
                    required_value = 2,
                    set_message = "You have killed Bertox and talked to Elder Fuirstel.",
                    unset_message = "You have NOT talked to Elder Fuirstel after killing Bertox."
                },
            }
        },
        {
            key = "bertox",
            set_message = "You have killed Bertox and hailed the planar projection.",
            unset_message = "You have NOT killed Bertox and hailed the planar projection."
        },
        {
            key = "shadyglade",
            set_message = "You have talked to Shadyglade within the Plane of Tranquility.",
            unset_message = "You have NOT talked to Shadyglade within the Plane of Tranquility."
        },
        {
            key = "newleaf",
            set_message = "You have killed the Keeper of Sorrows.",
            unset_message = "You have NOT killed the Keeper of Sorrows."
        },
        {
            key = "saryrn",
            conditions = {
                {
                    required_value = 1,
                    set_message = "You have killed Saryrn and hailed the planar projection.",
                    unset_message = "You have NOT killed Saryrn and hailed the planar projection."
                },
                {
                    required_value = 2,
                    set_message = "You have killed Saryrn, hailed the planar projection, and then talked to Shadyglade once more.",
                    unset_message = "You have NOT talked to Shadyglade after killing Saryrn."
                },
            }
        },
        {
            key = "faye",
            set_message = "You have completed the Halls of Honor trial given by Faye.",
            unset_message = "You have NOT completed the Halls of Honor trial given by Faye."
        },
        {
            key = "trell",
            set_message = "You have completed the Halls of Honor trial given by Rhaliq Trell.",
            unset_message = "You have NOT completed the Halls of Honor trial given by Rhaliq Trell."
        },
        {
            key = "garn",
            set_message = "You have completed the Halls of Honor trial given by Alekson Garn.",
            unset_message = "You have NOT completed the Halls of Honor trial given by Alekson Garn."
        },
        {
            key = "marr",
            set_message = "You have defeated Lord Marr within his temple.",
            unset_message = "You have NOT defeated Lord Marr within his Temple."
        },
        {
            key = "agnarr",
            set_message = "You have defeated Agnarr, the Storm Lord.",
            unset_message = "You have NOT defeated Agnarr, the Storm Lord."
        },
        {
            key = "tallon",
            set_message = "You have killed Tallon Zek.",
            unset_message = "You have NOT killed Tallon Zek."
        },
        {
            key = "vallon",
            set_message = "You have killed Vallon Zek.",
            unset_message = "You have NOT killed Vallon Zek."
        },
        {
            key = "rallos",
            set_message = "You have killed Rallos Zek the Warlord.",
            unset_message = "You have NOT killed Rallos Zek the Warlord."
        },
        {
            key = "librarian",
            set_message = "You have spoken with the grand librarian to receive access to the Elemental Planes.",
            unset_message = "You have NOT spoken with the grand librarian to receive access to the Elemental Planes."
        },
        {
            key = "arlyxir",
            set_message = "You have defeated Arlyxir within the Tower of Solusek Ro.",
            unset_message = "You have NOT defeated Arlyxir within the Tower of Solusek Ro."
        },
        {
            key = "dresolik",
            set_message = "You have defeated The Protector of Dresolik within the Tower of Solusek Ro.",
            unset_message = "You have NOT defeated The Protector of Dresolik within the Tower of Solusek Ro."
        },
        {
            key = "jiva",
            set_message = "You have defeated Jiva within the Tower of Solusek Ro.",
            unset_message = "You have NOT defeated Jiva within the Tower of Solusek Ro."
        },
        {
            key = "rizlona",
            set_message = "You have defeated Rizlona within the Tower of Solusek Ro.",
            unset_message = "You have NOT defeated Rizlona within the Tower of Solusek Ro."
        },
        {
            key = "xuzl",
            set_message = "You have defeated Xuzl within the Tower of Solusek Ro.",
            unset_message = "You have NOT defeated Xuzl within the Tower of Solusek Ro."
        },
        {
            key = "solusek",
            set_message = "You have defeated Solusek Ro within his own tower.",
            unset_message = "You have NOT defeated Solusek Ro within the Tower of Solusek Ro."
        },
        {
            key = "fennin",
            set_message = "You have defeated Fennin Ro, the Tyrant of Fire.",
            unset_message = "You have NOT defeated Fennin Ro, the Tyrant of Fire."
        },
        {
            key = "xegony",
            set_message = "You have defeated Xegony, the Queen of Air.",
            unset_message = "You have NOT defeated Xegony, the Queen of Air."
        },
        {
            key = "coirnav",
            set_message = "You have defeated Coirnav, the Avatar of Water.",
            unset_message = "You have NOT defeated Coirnav, the Avatar of Water."
        },
        {
            key = "arbitor",
            set_message = "You have defeated the arbitor within Plane of Earth A.",
            unset_message = "You have NOT defeated the Arbitor of Earth within Plane of Earth A."
        },
        {
            key = "rathe",
            set_message = "You have defeated the Rathe Council within Plane of Earth B.",
            unset_message = "You have NOT defeated the Rathe Council within Plane of Earth B."
        },
        {
            key = "maelin",
            set_message = "You have completed the Plane of Time flag.",
            unset_message = "You have NOT completed your Plane of Time flag."
        }
    }

    for _, entry in pairs(flags) do
        local bucket_value = tonumber(e.other:GetAccountBucket(string.format("pop.flags.%s", entry.key))) or 0

        if entry.conditions then
            for _, cond in ipairs(entry.conditions) do
                if bucket_value >= cond.required_value then
                    e.other:Message(MT.Tell, cond.set_message)
                else
                    e.other:Message(MT.Tell, cond.unset_message)
                end
            end
        else
            local req = entry.required_value or entry.required or 1
            if bucket_value == req then
                e.other:Message(MT.Tell, entry.set_message)
            else
                e.other:Message(MT.Tell, entry.unset_message)
            end
        end
    end
end
