sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		$random = quest::ChooseRandom(1, 2, 3);
		if ($random == 1) {
			quest::say("Death!! Death to all who oppose the Crushbone orcs!!");
		}
		elsif ($random == 2) {
			quest::say("Hail, Emperor Crush!!");
		}
		else {
			quest::say("Fall before the might of Clan Crushbone!!");
		}
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You shall have all the Crushbone orc legions on your tail for my death!");
}
