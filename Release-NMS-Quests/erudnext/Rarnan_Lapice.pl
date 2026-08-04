sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("It is good to meet you. $name.  To enter the Temple of Divine Light is to invite Quellious into your body and soul.  Tranquility is our way, and as such, we do all we can to uphold it.  Are you a [cleric of Quellious], or am I mistaken?");
	}
	elsif ($text=~/cleric of quellious/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("I have a small task for you then. Go to the city library and ask the librarian for the book 'The Testament of Vanear'. I shall require it for further studies. Do not return empty-handed or you shall know my rage.");
		}
		else {
			quest::say("You have not done much to upset the Peacekeepers of this temple. but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13991 -  Testament of Vanear
	if (plugin::check_handin(\%itemcount, 13991 => 1)) {
		quest::say("I sent you after that book ages ago! What took you so long? I have already completed my studies. Luckily I found the original manuscript under my bedroll. I forgot I had kept it there. Take this as a token of my apology. Maybe it will aid you in your next book hunt. I know how cunning those books can be.");
		#:: Give a random reward: 15302 - Spell: Languid Pace, 6351 - Fine Steel Morning Star, 16647 - Aged Platinum Bloodstone Earring
		quest::summonitem(quest::ChooseRandom(15302, 6351, 16647));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(298, 50); 		#:: + Peace Keepers
		quest::faction(266, 12); 		#:: + High Council of Erudin
		quest::faction(265, -12); 		#:: - Heretics
		#:: Grant a large amount of experience
		quest::exp(12500);
		#:: Create a hash for storing cash - 5000 to 5500cp
		my %cash = plugin::RandomCash(5000,5500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
