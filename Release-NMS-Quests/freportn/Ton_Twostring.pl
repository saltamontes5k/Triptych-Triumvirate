sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Die, like a motherless gnoll!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name--are you [interested] in helping the League of Antonican Bards by delivering some [mail]?");
	}
	elsif ($text=~/mail/i) {
		quest::say("The League of Antonican Bards has a courier system made up of travelers and adventurers.  We pay good gold to anyone who will take messages from bards such as myself to one of our more distant offices.  Are you [interested]?");
	}
	elsif ($text=~/interested/i) {
		quest::say("I have messages that need to go to Highpass, Kelethin, and Qeynos.  Will you deliver mail to [Kelethin], [Highpass], or [Qeynos] for me?");
	}
	elsif ($text=~/kelethin/i) {
		quest::say("Take this pouch to Idia in Kelethin.  You can find her at the bard guild hall.  I am sure she will compensate you for your troubles.");
		#:: Summon 18167 - Pouch of Mail (Kelethin)
		quest::summonitem(18167);
	}
	elsif ($text=~/qeynos/i) {
		quest::say("Take this pouch to Eve Marsinger in Qeynos.  You can find her at the bard guild hall.  I am sure she will compensate you for your troubles.");
		#:: Summon 18165 - Pouch of Mail (Highpass)
		quest::summonitem(18165);
	}
	elsif ($text=~/highpass/i) {
		quest::say("Take this pouch to Lislia Goldtune in Highpass.  You can find her at the entrance to HighKeep.  I am sure she will compensate you for your troubles.");
		#:: Summon 18156 - Pouch of Mail (Qeynos)
		quest::summonitem(18156);
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18164 or 18166 - both identify as Pouch of Mail (Freeport)
	if (plugin::check_handin(\%itemcount, 18164 => 1) || plugin::takeItems(18166 => 1)) {
		quest::say("Incoming mail - very good! Please take this gold for your troubles.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 5);			#:: + League of Antonican Bards
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(262, 1);			#:: + Guard of Qeynos
		quest::faction(304, -1);		#:: - Ring of Scale
		quest::faction(285, -1);		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 850 to 1000cp
		my %cash = plugin::RandomCash(850,1000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
