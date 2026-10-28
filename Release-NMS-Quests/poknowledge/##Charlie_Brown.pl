# Charlie Brown
# Inform people of the event in Kithicor

sub EVENT_SPAWN {
	quest::settimer(1,180);
}

sub EVENT_TIMER {
	if ($timer == 1) {
		quest::stoptimer(1);
		quest::settimer(1,900);
		if (!defined $qglobals{halloween_great_pumpkin}) {
			quest::shout("Help! Everyone! The undead are preparing to attack Freeport! We plan to head them off in the Kithicor Forest. Please, lend us your strength!");
		}
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		if (defined $qglobals{halloween_great_pumpkin}) {
			quest::say("You did it! The Great [" . quest::saylink("Pumpkin") . "] is done for and the horde scattered. Freeport owes you one - now go enjoy the festivities while the candy lasts!");
		}
		else {
			quest::say("They're coming, $name! The undead are massing for an attack on Freeport, and we mean to meet them in [" . quest::saylink("Kithicor Forest") . "]. Jack Lan'Turn is holding the line out there - lend him your strength!");
		}
	}
	elsif ($text=~/kithicor/i) {
		quest::say("East, past the old battleground. You'll hear the ghosts before you see them. Word is a [" . quest::saylink("Great Pumpkin") . "] leads the horde.");
	}
	elsif ($text=~/pumpkin/i) {
		quest::say("That's the legend anyhow - every year something rotten rises to lead them. Strike it down and the rest scatter. Bring friends, and plenty of them.");
	}
}
