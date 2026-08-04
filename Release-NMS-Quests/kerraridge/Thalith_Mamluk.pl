sub EVENT_SAY {
	if ($text=~/Hail/i) {
		quest::say("Wha?  Rarrrr!  Thalith try to fish but with [rrrats] and you botherring him, he cannot concentrate on water!  Go away, let Thalith fish!");
	}
	if ($text=~/rats/i) {
		quest::say("Rats. Yes. Small, furry, brown, with teeth. They come, bite my paws, steal my bait, chew on lines and rods. They nasty little beasts and easy to kill but me not able to leave this position or fish get away. Errr. Maybe you keep the rats away? You kill baddest rat, Sharptooth. You bring me his tooth. I be very happy.");
	}
}

sub EVENT_ITEM {
	#:: Match a 6347 - Sharp Tooth
	if (plugin::check_handin(\%itemcount, 6347 => 1)) {
		quest::say("You.. You kill the rats? Errr. Thalith thanks you. Here. Take this. It's good luck charm I've had for years.");
		#:: Give a 1061 - Fishbone Necklace
		quest::summonitem(1061);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(382,10);	# + Kerra Isle
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
