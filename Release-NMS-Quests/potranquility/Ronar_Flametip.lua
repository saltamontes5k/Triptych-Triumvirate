function event_say(e)
	if e.message:findi("Hail") then
		local events_link = eq.silent_say_link("events")
		e.self:Say(
			string.format(
				"Greetings travelers! Though the blessing Karana bestowed upon me seems to be waning, I was at least able to portend your arrival here and the role you would play in the [%s] I shall soon inform you of.",
				events_link
			)
		)
	elseif e.message:findi("events") then
		local move_the_portal_link = eq.silent_say_link("move the portal")
		e.self:Say(
			string.format(
				"My gift normally allows me to peer into other realms. I have used it many times to protect Norrath from dangerous outside forces. Now, however, I have lost the ability to peer into the planes under the domain of Fennin Ro. I suspect that his son, Solusek, may play a hand in these events, although I know not how. I fear that he has managed to somehow [%s] into the Plane of Fire for reasons that are not completely clear to me.",
				move_the_portal_link
			)
		)
	elseif e.message:findi("move the portal") then
		local fulfill_the_call_of_destiny_link = eq.silent_say_link("fulfill the call of destiny")
		e.self:Say(
			string.format(
				"Yes, and by doing so he has blocked my sight and access into the plane itself. Yet before I completely lost the ability to see into his realm, I glimpsed a giant stream of mystical fire coming from his tower and shooting upwards into the sky. Once the clouds had parted, another more sinister torrent of magic returned from the sky back to his tower. I believe that Solusek may have an accomplice for whatever he has planned. Though I much prefer subtlety, I fear the time for that has passed. No, you must simply stop Solusek from completing his plans and you must discover who his accomplice is lest he manages to continue their vile plans. Will you [%s]?",
				fulfill_the_call_of_destiny_link
			)
		)
	elseif e.message:findi("fulfill the call of destiny") then
		local efreeti_link = eq.silent_say_link("efreeti")
		e.self:Say(
			string.format(
				"Before you can gain access to Solusek's tower, you will need an enchantment to protect you from the searing heat that is contained within its walls. On my own I do not have the ability to grant such protection but I can still aid thee nonetheless. In the frigid landscapes of the Western Wastes there is a particularly powerful [%s] that wanders a path that only the mad would follow.",
				efreeti_link
			)
		)
	elseif e.message:findi("efreeti") then
		e.self:Say("Banished by his own kind for cruelty not even they could tolerate, he roams the wasteland forever searching for the entrance back to his home, an entrance forever denied to him. You must destroy this abomination and bring me the fiery heart that burns inside of him. Only then will you be able to survive the blistering environment in Solusek Ro's tower. Once inside though, you will need to gain access to his inner sanctum by getting his sanctum key. I know little of this but always be on the lookout for help for you never know when the gods may choose to aid you. Once you have destroyed Solusek, return to me with any information you find.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end