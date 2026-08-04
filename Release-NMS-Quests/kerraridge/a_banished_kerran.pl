sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Rrrrrr..  Away frrrom this isle of death and.. prrrr.. punishment.");
	}
	elsif ($text=~/Puab sent me/i) {
		quest::say("Prrr... Master Puab? Show me prrroof");
	}
	elsif ($text=~/remains of thipt/i) {
		quest::say("Clawknight Thipt wished to learn the ways of Ashen.  Prrr.. Together we go into green goblins' lair to train.  Prrr.. We find too many and he is too weak.  Separated and unable to find him, I hear his death cry.  Prr.. I cannot make it back, eyes upon me.  Now I must find one sent by Ashen to aid in the recoverrry of his remains.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12369 - Puab's Token
	if (plugin::check_handin(\%itemcount, 12369 => 1)) {
		quest::say("Ashen Order!!  Prrr.. My order.  I have been expecting one of us.  Prrr.. Help me rejoin my native land.  Take this box.  Combine all the [remains of Thipt] within the box and return it to me.  This shall aid me in my redemption.");
		#:: Give a 17985 - Box With Pawprints
		quest::summonitem(17985);
	}
	#:: Match a 12371 - Box of Cat Bones
	elsif (plugin::check_handin(\%itemcount, 12371 => 1)) {
		quest::say("Prrr.. Thank you brother of Ashen. I can now spend my time upon this island in peace, until my penance is serrrved. He dabs his paw into the mud and places it upon a tattered parchment. Take this message to Puab. Farrrwell.");
		#:: Give a 28055 - Tattered Parchment
		quest::summonitem(28055);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
