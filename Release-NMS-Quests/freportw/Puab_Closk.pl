sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. I am Puab Closk, Master of the Ashen Order.  Our home is your home, friend. Feel free to stay as long as you like.  Learn our ways as many have done in the past.  To fight like the tiger and strike like the cobra are your goals.");
	}
	elsif ($text=~/treant fists/i) {
		#:: Match if faction with Ashen Order is Amiable or better
		if ($faction <= 4) {
			quest::say("You desire the treant fists?  I have them and I will offer them to any [skilled monk of the Ashen House].");
		}
	}
	elsif ($text=~/clawfist/i) {
		#:: Match if faction with Ashen Order is Amiable or better
		if ($faction <= 4) {
			quest::say("Clawfist is a Kerran, a catman. He braved the dangers of Norrath to reach the Ashen Order. He sought knowledge of our disiples. He learned well.");
		}
	}
	elsif ($text=~/where/i) {
		#:: Match if faction with Ashen Order is Amiable or better
		if ($faction <= 4) {
			quest::say("Clawfist has been banished by the Kerrans of Odus. Where they have sent him I am unsure.");
		}
	}
	elsif ($text=~/skilled monk of the Ashen House/i) {
		#:: Match if faction with Ashen Order is Amiable or better
		if ($faction <= 4) {
			quest::say("Then you shall aid our family. My former pupil [skilled monk of the Clawfist] has been banished by his people. You will go to him and hand him this token as proof of your origin. He shall be expecting you.");
			#:: Give a 12369 - Puab's Token
			quest::summonitem(12369);
		}
	}
} 

sub EVENT_ITEM {
	#:: Match a 18746 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18746 => 1 )) {
		quest::say("Oh my! Opal? She is providing these agents of Neriak with information regarding the Acedemy's secrets. I can not tell Cain about this. He will be furious. Show this to Toala. She will know what to do.");
		#:: Give a 13507 - Torn Cloth Tunic
		quest::summonitem(13507);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(361, 10); 		#:: + Ashen Order
		quest::faction(281, 5); 		#:: + Knights of Truth
		quest::faction(309, 5); 		#:: + Silent Fist Clan
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 28055 - Tattered Parchment
	if (plugin::check_handin(\%itemcount, 28055 => 1 )) {
		quest::say("You have performed a great service to one who is your brother. Your loyalty shines brightly, as does your skill. Take the treant fists. They are yours now.");
		#:: Give a 12344 - Treant Fists
		quest::summonitem(12344);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(361, 20); 		#:: + Ashen Order
		quest::faction(281, 3); 		#:: + Knights of Truth
		quest::faction(309, 2); 		#:: + Silent Fist Clan
		#:: Grant a small amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
