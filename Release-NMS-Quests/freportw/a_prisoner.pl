sub EVENT_SPAWN {
	#:: Set a timer "goog" to loop every 180 seconds (3 min)
	quest::settimer("goog", 180);
}

sub EVENT_TIMER {
	#:: Match the timer "goog"
	if ($timer eq "goog") {
		#:: Create a scalar for storing a random number
  		my $RandomResponse = quest::ChooseRandom(1, 2, 3);
  		if ($RandomResponse == 1) {
			quest::say("unngh!!.. Biggle and boo.. Goggle froo..");
  		}
  		elsif ($RandomResponse == 2) {
    			quest::say("ahhhh!!.. Tiggle bumble coo.. Bog n' Goo..");
		}
		else {
			quest::say("Bog n Goo.. Blanket too!!");
  		}
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Aaaarghhh!!.. Buggl n gump.. Figgle and fump..");
	}
	elsif ($text=~/ariska zimel/i) {
		quest::emote("stares deeply into your eyes.. Very eerie!!");
	}
}

sub EVENT_ITEM {
	#:: Match a 12196 - Bunker Cell #1, a 16581 - Bog Juice, and a 13498 - Edible Goo
	if (plugin::check_handin(\%itemcount, 12196 => 1, 16581 => 1, 13498 => 1)) {
		quest::say("Hide, hide, safe, cee.. lerk has the clue.. Must travel.. Travel.. Travel.. Tunaria's corridor.");
		#:: Give a 12143 - H.K. 102
		quest::summonitem(12143);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 1);			#:: + Coalition of Tradefolk
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(291, 1);			#:: + Merchants of Qeynos
		quest::faction(336, 1);			#:: + Coalition of Tradefolk Underground
	}
	quest::say("Bog n Goo.. Blanket too!!");
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
