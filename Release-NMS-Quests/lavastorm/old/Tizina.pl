sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, I am Tizina.");
	}
}

sub EVENT_ITEM {
	#:: Match 50 gold pieces
	if (plugin::takeCoin(0, 0, 50, 0)) {
		quest::say("Since you have given me gold, I will give you gloves. For more magic gloves, give a bloodstone to Tarn Visilin in the Highkeep library.");
		#:: Give a 2354 - Enchanted Gloves
		quest::summonitem(12354);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
