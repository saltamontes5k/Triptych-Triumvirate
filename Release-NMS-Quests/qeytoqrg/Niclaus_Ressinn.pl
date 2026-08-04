sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail $name. I am Niclaus Ressinn, loyal Paladin of Life. I am scouting the Qeynos Hills on orders from High Priestess Jahnda. We have received reports of the undead prowling these hills as of late.");
	}
	#:: This quest appears to be original, but it was broken after players abused it
	elsif ($text=~/undead/i) {
		quest::say("I believe undead prowl these hills at night. I have found the remains of several adventurers who obviously had the misfortune of running into one of Bertoxxulous' dark minions. One young human was still cluching this parchment in his rigored fist.");
	}
	elsif ($text=~/parchment/i) {
		quest::say("I believe it is from a spell book of some kind and I do not have a working knowledge of things arcane. Perhaps you could help? Take it. I am sure someone in Qeynos could decipher it. I must remain here to gather more evidence but please return to me with anything you discover.");
		#:: Give a 13718 - Torn Parchment
		quest::summonitem(13718);
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 4 or 8
	if ($wp == 4 || $wp == 8) {
		#:: Do Animation 62 - Kneel
		quest::doanim(62);
	}
	#:: Match waypoint 5
	elsif ($wp == 5) {
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: Match waypoint 6
	elsif ($wp == 6) {
		#:: Do Animation 29 - Wave
		quest::doanim(29);
	}
	#:: Match waypoint 7
	elsif ($wp == 7) {
		quest::say("Guard! Come quick! The undead gather near the ruins of Geupal!");
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
	#:: Match waypoint 9
	elsif ($wp == 9) {
		#:: Do animation 7 - Secondary Bash
		quest::doanim(7);
	}
	#:: Match waypoint 10
	elsif ($wp == 10) {
		quest::say("Shh.. The fiends seems to dwell amongst the ruins. They wander off but eventually congregate back here. Shh.. OK NOW! RODCET PROTECT US!");
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: Match waypoint 11
	elsif ($wp == 11) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
}

sub EVENT_ITEM {
	#:: Match a 18970 - Note to Niclaus
	if (plugin::check_handin(\%itemcount, 18970 => 1)) {
		quest::say("Oh, things are becoming dire here in Norrath. May Rodcet protect us! I have gathered most of the evidence I will need to present to Jahnda, but I could still use your assistance with one final piece. I need to recover a rib bone from of the undead beasts that wander these hills. Be sure the rib bone comes from one of the putrid skeletons. They are the spawn of Bertoxxulous.");
	}
	#:: Match a 13722 - Putrid Rib Bone
	elsif (plugin::check_handin(\%itemcount, 13722 => 1)) {
		quest::say("Excellent! Rodcet smiles upon us this day! Here, please take this pouch of evidence to Jahnda in the Temple of Life. She will know what we must do. I will remain here to keep an eye out for the minions of Bertoxxlous. Also, accept this small reward as a token of my appreciation of your efforts to rid Norrath of the influence of the Plaguebringer.");
		#:: Give a 13724 - Pouch of Evidence
		quest::summonitem(13724);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(341, 50);		#:: + Priests of Life
		quest::faction(280, 15);		#:: + Knights of Thunder
		quest::faction(262, 25);		#:: + Guards of Qeynos
		quest::faction(221, -12);		#:: - Bloodsabers
		quest::faction(219, 7);			#:: + Antonius Bayle
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 100 to 1500cp
		my %cash = plugin::RandomCash(100,150);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
