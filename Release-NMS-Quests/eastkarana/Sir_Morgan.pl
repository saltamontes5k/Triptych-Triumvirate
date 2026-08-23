sub EVENT_WAYPOINT_ARRIVE {
	if ($wp==1) {
		quest::say("Hello, Wimbley, old chap!");
	}
	elsif ($wp==8) {
		quest::say("Almost there...");
	}
	elsif ($wp==9) {
		quest::say("Well, here we are! It is just a short jaunt through the pass ahead. Just remember to take the high road. I'm off, then. Good luck!");
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	elsif ($wp==10) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, traveler! Might I escort you through to Highpass? The path ahead is filled with giants and many other hungry beasts. I assure you, you will be safe with me. I must admit, I am quite experienced in the ways of the warrior. Do you [wish an escort] or will you [travel alone]");
	}
	elsif ($text=~/wish an escort/i) {
		quest::say("I shall be honored to escort you to Highpass, but you shall have to wait for a spell. I make trips every few hours. I also would be grateful to any who wish to donate gold coins to the upkeep of my armor. The rains in the plains cause much rusting.");
	}
	elsif ($text=~/travel alone/i) {
		quest::say("Then, good luck to you! May your faith protect you. Or at the very least, guide you to a grand afterlife.");
		#:: Move the NPC to the coordinates and then path back (no guard)
		quest::moveto(-141.75, 1201.45, 141.42, 0);
	}
}

sub EVENT_ITEM {
	#:: Match 5 gold pieces
	if (plugin::takeCoin(0, 0, 5, 0)) {
		quest::say("What a grand donation!! You must be a rich noble to be making such a donation. Here, I am but a simple warrior, but I found this lying on the highway to Highpass Hold. The lifeless corpse next to it had no more need of it.");
		#:: Ding!!
		quest::ding();
		#:: Give a random reward: Patchwork cloak, Patchwork boots, Rusty Weapons, Silver Earring, Bloodstone, Halfling knife, Bronze Dagger, Belt pouch, Damask cap, Mountain Lion Cape, Highkeep Flask, Snakeskin Mask, Drom's Champagne
		quest::summonitem(quest::ChooseRandom(2106, 2112, 2041, 13944, 2307, 3829, 1331, 17002, 7012, 8306, 10006, 10019, 5013, 5019, 5021, 5022, 6011, 5023, 7007, 7008));
		#:: Set Factions
		quest::faction(262, 1);		#:: + Guards of Qeynos
		quest::faction(345, 1);		#:: + Karana Residents
		quest::faction(341, 1);		#:: + Priests of Life
		quest::faction(280, 1);		#:: + Knights of Thunder
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
