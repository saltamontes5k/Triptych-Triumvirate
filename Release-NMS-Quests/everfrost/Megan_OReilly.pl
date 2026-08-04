sub EVENT_WAYPOINT_ARRIVE {
	if ($wp == 3) {
		 quest::SetRunning(1);
	}
	elsif ($wp == 6) {
		 quest::SetRunning(0);
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Brrrr.. It.. Is sooo.. c-cold!! I never.. sh-should've j-joined.. the.. the W-wolves of the N-north!!");
	}
	elsif ($text=~/ivan's remains/i) {
		quest::say("You were sent to retrieve the remains? I am sorry, I lost them. It was not my fault! There was no escort as I was told. I got lost returning to Halas and ended up on a frozen river. The ice broke and the remains were scattered into the freezing water. Will you [dive for the remains]?");
	}
	elsif ($text=~/dive for the remains/i) {
		quest::say("Thank the Tribunal!! I would have, but I cannot swim. Take this chest. Fill it with the four pieces which fell below the surface. I know not what else lies within. When you fill the box and combine the items, return it to Renth. Good luck, $name.");
		#:: Give a 17945 - Empty Box
		quest::summonitem(17945);
	}
}

sub EVENT_ITEM {
	#:: Match a 13244 - One Quarter of Elixir
	if (plugin::check_handin(\%itemcount, 13244 => 1)) {
		quest::say("Oh thank you. Sorry, but the bottle is empty now. I hope you did't need any. Take the empty bottle back to Dargon. He may refill it for you.");
		#:: Give a 13245 - Empty Bottle of Elixir
		quest::summonitem(13245);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 1);		#:: + Merchants of Halas
		quest::faction(327, 1);		#:: + Shaman of Justice
		quest::faction(311, 1);		#:: + Steel Warriors
		quest::faction(320, 1);		#:: + Wolves of the North
		#:: Grant a small amount of experience
		quest::exp(150);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
