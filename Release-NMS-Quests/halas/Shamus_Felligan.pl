sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetin's! Justice speaks through us. We're the followers o' the Tribunal. We act as judge. jury and executioner fer all misled Northmen. Sometimes we must also execute our swift justice upon evil races. such as th' [ice goblins].");
	}
	elsif ($text=~/ice goblins/i) {
		quest::say("The ice goblins are a weak race. They pose no threat to our community. but lately we've heard rumors of ice goblins that can cast spells. They're said to be as weak as the goblin warriors. so I seek to employ the talents of our young shamans to [hunt the goblin casters].");
	}
	elsif ($text=~/hunt the goblin casters/i) {		
		quest::say("Aye. ye'll serve justice.  I must find the source o' their recent spellcasting ability.  I hear reports o' glowing necklaces upon these wicked beasts' necks. Get me one o' these casters' necklaces. Return them in any condition at all. Go! Justice awaits yer return.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13968 - Shattered Caster Beads
	if (plugin::check_handin(\%itemcount, 13968 => 1)) {
		quest::say("Shattered! This has happened frequently! These beads are very delicate. They're useless to me now, however, I'll reward ye fer the execution of yet more goblin casters. Continue yer work. The Tribunal watches ye!");
		#:: Give a random reward: 15270 - Spell: Drowsy, 15275 - Spell: Frost Rift, 15075 - Spell: Sicken, 15271 - Spell: Fleeting Fury, 15212 - Spell: Cure Blindness, 15079 - Spell: Spirit Sight
		quest::summonitem(quest::ChooseRandom(15270, 15275, 15075, 15271, 15212, 15079));
		#::Ding!
		quest::ding();
		#:: Set factions
		quest::faction(327, 10);			#:: + Shamen of Justice
		quest::faction(328, 1);				#:: + Merchants of Halas
		quest::faction(223, -1);			#:: - Circle of Unseen Hands
		quest::faction(336, -1);			#:: - Coalition of Tradefolk Underground
		quest::faction(244, -2);			#:: - Ebon Mask
		#:: Grant a small amount of experience
		quest::exp(800);
		#:: Create a hash for storing cash - 1500 to 2000cp
		my %cash = plugin::RandomCash(1500,2000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 13969 - Caster Beads
	elsif (plugin::check_handin(\%itemcount, 13969 => 1)) {
		quest::say("Finally! Intact! This IS good news! I can continue me investigation now. As fer yer loyal deed, I'll offer ye this, the Gavel of Justice. May ye employ it well in the service o' justice.");
		#:: Give a 6028 - Gavel of Justice
		quest::summonitem(16028);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(327, 25);		#:: + Shamen of Justice
		quest::faction(328, 3);			#:: + Merchants of Halas
		quest::faction(223, -3);		#:: - Circle of Unseen Hands
		quest::faction(336, -3);		#:: - Coalition of Tradefolk Underground
		quest::faction(244, -5);		#:: - Ebon Mask
		#:: Grant a moderate amount of experience
		quest::exp(1600);
		#:: Create a hash for storing cash - 900 to 1100cp
		my %cash = plugin::RandomCash(900,1100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
    	#:: Return unused items
	plugin::return_items(\%itemcount);
}
