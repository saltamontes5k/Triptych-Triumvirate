sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $name. I welcome you to the Temple of Divine Light. I am the resident healer. If you should ever require the power of Quellious to [bind wounds], [cure disease] or [cure poison], speak with me and I shall help you.");
	}
	elsif ($text=~/bind wounds/i) {
		quest::say("I shall be pleased to help you with your wounds. The Temple of Divine Light requires a tribute of four gold before I may perform the service.");
	}
	elsif ($text=~/cure disease/i) {
		quest::say("Your malady will be nothing more than a memory, but before that can be, we ask that a donation of two gold coins be offered.");
	}
	elsif ($text=~/cure poison/i) {
		quest::say("You must pay the tribute of three gold before I cast the toxin from your body.");
	}
}

sub EVENT_ITEM {
	#:: Match four gold pieces
	if (plugin::takeCoin(0, 0, 4, 0)) {
		#:: Cast spell 12 - Healing
		$npc->CastSpell(12,$userid);
	}
	#:: Match three gold pieces
	elsif (plugin::takeCoin(0, 0, 3, 0)) {
		#:: Cast spell 203 - Cure Poison
		$npc->CastSpell(203,$userid);
	}
	#:: Match two gold pieces
	elsif (plugin::takeCoin(0, 0, 2, 0)) {
		#:: Cast spell 213 - Cure Disease
		$npc->CastSpell(213,$userid);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
