sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Why, hello there fellow scholar!  Don't you just love books?  I am quite a bookworm myself.  I could read forever!  I am currently working my way through the 'T's.");
	}
	elsif ($text=~/erud's tonic/i) {
		quest::say("Erud's Tonic! That is none of your concern!");
	}
	elsif ($text=~/phloatin/i) {
		quest::say("Phloatin Highbrow is my brother. He spends his time grogging it up.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13121 - Innoruuk's Kiss of Death
	if (plugin::check_handin(\%itemcount, 13121 => 1)) {
		quest::say("It's about time you figured it out, genius! Maybe you should spend more time in the library. Here, take this tonic and get out of here before they see me giving it to you and turn us both inside out.");
		#:: Give a 13118 - Erud's Tonic
		quest::summonitem(13118);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(694, 5); 		#:: + Erudite Citizen
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
