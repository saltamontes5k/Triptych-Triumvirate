function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The ritual of destruction has begun. Tiv Barxt Qurat has completed the transfer of destructive energy from the Altar of Destruction into the Guardian of Destruction and it must be destroyed if there is any chance of disrupting his plans. Be wary of Barxt -- he is powerful and tricky. If he sees things are not going his way, he will use many different tactics to destroy you. When you are [ready] to enter, tell me so, and I will remove the seal. However, once you enter, I am afraid the only way out will be through death or victory.");
	elseif e.message:findi("ready") then
		e.self:Say("The seal has been removed. Good luck to you.");
		eq.get_entity_list():FindDoor(5):SetLockPick(0);
    eq.load_encounter("vbq")
	end
end
