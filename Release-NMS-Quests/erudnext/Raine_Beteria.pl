sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Welcome. I am Raine Beteria.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You are most welcome to the circle of the Craftkeepers, but I require more service before we can discuss such things.");
		}
		else {
			quest::say("You are lucky to be standing. Leave here immediately or suffer grave consequences! You are not welcome amongst the Craftkeepers.");
		}
		
	}
}

sub EVENT_ITEM {
	#:: Match 50 gold pieces and a 6339 - Blessed Silver Wand
	if (plugin::check_handin(\%itemcount, 6339 => 1, "gold" => 50)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Your silver wand has been fully enchanted. Take it and the pouch of silver dust back to the temple of Ro.");
			#:: Give a 6340 - Glowing Silver Wand
			quest::summonitem(16340);
			#:: Ding!
			quest::ding();
			#:: Set faction
			quest::faction(128, 10);
			#:: Grant a small amount of experience
			quest::exp(1000);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You are most welcome to the circle of the Craftkeepers, but I require more service before we can discuss such things.");
			#:: Return coin
			quest::givecash($copper, $silver, $gold, $platinum);
			#:: Return 6339 - Blessed Silver Wand
			quest::summonitem(16339);
		}
		else {
			quest::say("You are lucky to be standing. Leave here immediately or suffer grave consequences! You are not welcome amongst the Craftkeepers.");
			#:: Return coin
			quest::givecash($copper, $silver, $gold, $platinum);
			#:: Return 6339 - Blessed Silver Wand
			quest::summonitem(16339);
		}
	}
  	elsif (plugin::check_handin(\%itemcount, 10792 => 1)) {
		quest::say("Thank you very much. I have always wanted one of these! Hehehe? just kidding. I see that you have enchanted this coin. I have placed the final enchantment on it - take it back to Romar.");
		#:: Give a 10793 - Radiant Coin of Tash
		quest::summonitem(10793);
		#:: Ding!
		quest::ding();
    		#:: Grant a small amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}