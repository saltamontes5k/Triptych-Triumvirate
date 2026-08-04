sub EVENT_SPAWN {
	#:: Create a timer 'sing' that loops every 120 seconds (2 minutes)
	quest::settimer("sing", 120);
}

sub EVENT_TIMER {
	#:: Match timer 'sing'
	if ($timer eq "sing") {
		#:: Create a scalar to store a random
		my $singit = quest::ChooseRandom(1,2,3,4,5,6);
		#:: Match singit = 1
		if ($singit == 1) { 
			quest::say("Let's hear some music.");
			bard_sing();
		}
		elsif ($singit == 2) { 
			quest::say("Music!! Music!!");
			bard_sing();
		}
		elsif ($singit == 3) { 
			quest::say("Play us some music bard!!");
			bard_sing();
		}
		elsif ($singit == 4) { 
			quest::say("Let's liven this pub up!");
			bard_sing();
		}
		elsif ($singit == 5) { 
			quest::say("Try to cheer this place up, bard.");
			bard_sing();
		}
		elsif ($singit == 6) { 
			quest::say("Where is the music? I don't pay you bards to drink all the grog!!");
			bard_sing();
		}
	}
}

sub bard_sing {
	#:: Send a signal '1' to East Freeport >> Trolon_Lightleer (10141) with no delay
	quest::signalwith(10141, 1, 0);
	#:: Send a signal '1' to East Freeport >> Branis_Noolright (10158) with no delay
	quest::signalwith(10158, 1, 0);
	#:: Send a signal '1' to East Freeport >> Palana_Willin (10165) with no delay
	quest::signalwith(10165, 1, 0);
}
