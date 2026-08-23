sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Ah, greetings, young $name, how are you on this fine day? Perfect day for a nice stroll through the hills, if I do say so myself.");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 2 or 5
	if ($wp == 2 || $wp == 5) {
		#:: Sit down
		plugin::SetAnim("sit");
	}
	#:: Match waypoint 3
	elsif ($wp == 3) {
		#:: Stand up
		plugin::SetAnim("stand");
	}
}

sub EVENT_ITEM {
	#:: Match a 18921 - Message to Konem
	if (plugin::check_handin(\%itemcount, 18921 => 1)) {
		quest::say("Oh I see.. Phin's always after me about something. I mean, it's not my fault the order hasn't come in yet. Hey, since I'm so busy right now, why don't you be a friend and take this back to Phin for me, huh?");
		#:: Give a 18922 - Grathin's Invoice
		quest::summonitem(18922);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(309, 5);			#:: + Silent Fist Clan
		quest::faction(262, 1);			#:: + Guards of Qeynos
		quest::faction(361, 1);			#:: + Ashen Order
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My brothers and sisters in the Silent Fist Clan shall not rest until my death is avenged!");
}
