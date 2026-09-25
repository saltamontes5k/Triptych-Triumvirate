# Anderia - West Karana. Nights of the Dead "Carry the Torch" (2008) turn-in.
# Seasonal: Rongol only offers the task when peq_halloween is enabled.
sub EVENT_SAY {
	if($text=~/hail/i) {
		quest::say("The nights grow long, and the torches must be kept burning. If Rongol sent you, hand me the torches and I will see them lit.");
	}
}

sub EVENT_ITEM {
	if(plugin::check_handin(\%itemcount, 13002 => 4)) {
		quest::say("Ah, the torches! Thank you, $name. May their light keep the spirits at bay through the Nights of the Dead.");
		quest::ding();
		quest::exp(500);
		if(quest::istaskactive(620003)) {
			quest::updatetaskactivity(620003, 1);
		}
	} else {
		plugin::return_items(\%itemcount);
	}
}
