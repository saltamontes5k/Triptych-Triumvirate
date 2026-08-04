sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, good adventurer!  Do you bring word from my [husband]?");
	}
	elsif ($text=~/husband/i) {
		quest::say("Tolkar is his name. My beloved husband. He still lives in Felwithe while I study here. It must be hard on him.");
	}
}

sub EVENT_ITEM {
	#:: Match a 1598 - Black Stone Candlestick
	if (plugin::check_handin(\%itemcount, 1598 => 1)) {
		quest::say("I sense a great evil power in this candlestick. I will need you to concoct a divinatory aid for me before I can discern more. Take this suspension and brew it in a brew barrel with one white hellebore, a pouch of the red dust created by the Fire Peak Goblin Wizards, and the caustic substance used by the werebats in Unrest.");
		#:: Give item 1596 - Magical Suspension Fluid
		quest::summonitem(11596);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(1500);
	}
	#:: Match a 1597 - Divinatory Concoction
	elsif (plugin::check_handin(\%itemcount, 1597 => 1)) {
		quest::emote("performs a subtle divinatory ritual. 'This is a powerful evil indeed. The smoke from special candles crafted by the Teir'Dal and burned in this candlestick allows the creation of undead of unordinary might. The Ghasts are only one of its many possible creations. I will concoct a powder for you to take back to Yeolarn that will assist in defeating the monstrosities the candle has produced. The candlestick itself will remain here within the High Tower of Erudin for the time being.'");
		#:: Give item 1599 - Powder of Unanimation
		quest::summonitem(11599);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 10);		#:: + Faydark's Champions
		quest::faction(275, 10);		#:: + Keepers of the Art
		quest::faction(279, 10);		#:: + King Tearis Thex
		quest::faction(239, -30);		#:: - The Dead
		#:: Grant a moderate amount of experience
		quest::exp(1500);
	}
	#:: Match a 1056 - Faded Cloak
	elsif (plugin::check_handin(\%itemcount, 1056 => 1)) {
		quest::say("Oh my lord Tunare! I did not know my daughter was in trouble. I thank you for saving her. Here, I have returned the once lost power to this cloak. Wear it with my humblest gratitude.");
		#:: Give item 1057 - Mystic Cloak
		quest::summonitem(11057);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(275, 15);		#:: + Keepers of the Art
		quest::faction(279, 3);			#:: + King Tearis Thex
		quest::faction(246, 2);			#:: + Faydark's Champions
		quest::faction(239, -3);		#:: - The Dead
		#:: Grant a moderate amount of experience
		quest::exp(1500);
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
