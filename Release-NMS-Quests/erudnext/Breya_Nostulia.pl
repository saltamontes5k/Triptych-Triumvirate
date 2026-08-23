sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("Breya Nostulia stares off into the distance in meditation. Her eyes are a light blue, much like the tropical waters of the ocean between Odus and the mainland. She ignores your greeting.");
	}
	elsif ($text=~/tiam sent me/i) {
		quest::say("Seems you've slain quite a few kobolds, then. This is good. You will need to kill many more to fulfill your quest. While the kobolds are fairly primitive, they are an ancient race and have learned to wield the powers of the spirits. This ability is the only thing that has kept us from eradicating them completely. We need you to find [instruments] of their craft.");
	}
	elsif ($text=~/instruments/i) {
		quest::say("There are two items we seek. The shamans carry medicine pouches in which they hold the materials of their craft. Only the more adept shamans are allowed to carry the pouches; seek them out. The [other item] we seek is of greater importance.");
	}
	elsif ($text=~/other item/i) {
		quest::say("The other is a magical bowl from which a highly skilled shaman may divine the future or diagnose illness. Only the wisest of the kobold shamans have the intelligence to use the bowls, or perhaps an outcast with powers that the other, larger kobolds fear. Bring me a kobold medicine pouch and the diviner's bowl and you shall be rewarded with the armor of our trusted knights and priests");
	}
}

sub EVENT_ITEM {
	#:: Match a 17056 - Kobold Shaman's Pouch, and a 1766 - Diviner's Bowl
	if (plugin::check_handin(\%itemcount, 17056 => 1, 1766 => 1)) {
		quest::say("Well done, $name. I had a feeling you would return victorious. Here is your reward, the Leggings of Midnight Sea. Wear them with pride for the Ocean Lord. If you are interested in aiding us further, you may want to ask Gans about his brother.");
		#:: Give a 1762 - Midnight Sea Mail Leggings
		quest::summonitem(11762);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(242, 2);			#:: + Deepwater Knights
		quest::faction(266, 2);			#:: + High Council of Erudin
		quest::faction(265, -2);		#:: - Heretics
		#:: Grant a moderate amount of experience
		quest::exp(1000);	
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
