sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("It is a good thing to see new faces visiting our temple. We are the source of strength within this city. Do not be fooled by the Freeport Militia. They are not warriors of valor.  [Join the fight] against the Freeport Militia.");
	}
	elsif ($text=~/join the fight/i) {
		quest::say("You are wise. If you are a paladin, either speak with Theron of this temple or visit the Hall of Truth here in North Freeport. Clerics should concetrate on keeping the knights strong and healthy. Would you care to [assist] the Temple of Marr?");
	}
	elsif ($text=~/assist/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Good. Take this Potion of Marr to the Sentries of Passion. They are the protectors of this temple. Start in alphabetical order and the first shall take but a sip then you shall take it to the next in order of the alphabet. There are but eight sentries. Sentry Andlin to Sentry Xyrin. Go.");
			#:: Summon 12127 - Full Potion of Marr
			quest::summonitem(12127);
		}
		else {
			quest::say("The path you walk is correct, but you have further to travel before you need worry about this.");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 10 Gold and 12126 - Shark Bones x3
	if (plugin::check_handin(\%itemcount, 12126 => 3, "gold" => 10)) {
		quest::say("I thank you for your ten gold coins. Now we can pay the weekly oxygen tax imposed by the militia. Here is the shark powder.");
		#:: Give item 12125 - shark Powder
		quest::summonitem(12125);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 5); 		#:: + Priests of Marr
		quest::faction(330, -10); 		#:: - Freeport Militia
		quest::faction(281, 5); 		#:: + Knights of Truth
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Turn in for 13983 - Inert Potion 
	elsif (plugin::check_handin(\%itemcount, 13983 => 1 )) {
		quest::say("I see Tonmerk has found a use for my shark powder. We agreed to this trade when last we met. Unfortunately, I am out of it. If you desire the shark powder you will have to get me three shark bones. I wish you luck. Oh. I also require a payment of ten gold pieces. The taxes in Freeport are fierce.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 5); 		#:: + Priests of Marr
		quest::faction(330, -10); 		#:: - Freeport Militia
		quest::faction(281, 5); 		#:: + Knights of Truth	
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Turn in for 12135- Empty Potion of Marr
	elsif (plugin::check_handin(\%itemcount, 12135 => 1 )) {
		quest::say("The Sentries of Passion informed me of your journey to the Ocean of Tears and the demise of Sentry Xyrin. You performed beyond the call of duty. This is what makes an exceptional person. Take this for your great deed. The twin deities would wish it so.");
		#:: Give item 15207 - Spell: Divine Aura
		quest::summonitem(15207);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 15); 		#:: + Priests of Marr
		quest::faction(330, -1); 		#:: - Freeport Militia
		quest::faction(281, 2); 		#:: + Knights of Truth
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}