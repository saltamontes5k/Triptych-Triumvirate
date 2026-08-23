sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Argh... The [beasts] are on my tail. They will find me soon... I gave them the [skull] and still they pursue me!");
	}
	elsif ($text=~/beasts|message/i) {
		quest::say("Here... No time left... Take this please... My brother [Hyrill] is staying in [Freeport]. Please... Ugh... Must keep moving...");
		#:: Give a 18010 - Torn Parchment
		quest::summonitem(18010);
		#:: Spawn one and only one The Western Plains of Karana >> a_Splitpaw_assassin (12182)
		quest::unique_spawn(12182, 0, 0, -15188.57, 1270.43, 68.72, 109.0);
	}
	elsif ($text=~/skull/i) {
		quest::say("The skull of Wun Toque! I have found it. And have learned the location of its eyes! But now the [beasts] have it and I must flee...");
	}
	elsif ($text=~/hyrill/i) {
		quest::say("There is no time... must keep moving... ugh.");
	}
	elsif ($text=~/freeport/i) {
		quest::say("There is no time... must keep moving... ugh.");
	}
	elsif ($text=~/hurry/i) {
		quest::say("I was in Paw recently and stole a skull and now an [assassin] is hunting me down, even after returning the skull to him.");
	}
	elsif ($text=~/assassin/i) {
		quest::say("Look $name, I don't have time to talk! If you want to help me deliver this [message].");
	}
	elsif ($text=~/message/i) {
		quest::say("Hurry now and take this to my brother, Hyrill Pon in Freeport, and before you go take that skull back from the assassin.");
		#:: Give a 18010 - Torn Parchment
		quest::summonitem(18010);
		#:: Spawn one and only one The Western Plains of Karana >> a_Splitpaw_assassin (12182)
		quest::unique_spawn(12182, 0, 0, -15188.57, 1270.43, 68.72, 109.0);
	}
}

sub EVENT_SIGNAL {
	#:: Match signal '1' from 
	if ($signal == 1) {
		quest::say("He has found me! Help meeeeeee!");
		quest::say("Leave me be! I have friends all over the Commonlands who will avenge me!");
		#:: Send a signal '1' to The Western Plains of Karana >> a_Splitpaw_assassin (12182)
		quest::signalwith(12182, 1, 0);	
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Argh... The secrets of Wun Toque shall never be yours! argh... argh...");
}
