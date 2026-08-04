sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Why. hello there!!  Welcome to the Church of Mischief.  I am Hendi Mrubble. The 'R' is silent.  I am the resident healer of the church. so if you are in need of [healing], or want me to [cure poison] or [cure disease], let me know.  If you've got a touch of the crazy brain. I can't do a thing for you.");
	}
	elsif ($text=~/healing/i) {
		quest::say("Hmmm.  I would love to help you with that. but you will have to make a donation to the temple.  The Guardians asked me to charge one of the Rivervale piranha teeth.");
	}
	elsif ($text=~/cure disease/i) {
		quest::say("Eeww!! Careful. don't touch Hendi.  I figured there must have been something not quite right about you.  Well, now, before we can cast the disease from your body you will have to make a little donation of one gold for the service and eight gold to disinfect this place.  That would be 10 total!!  Let's see it.");
	}
	elsif ($text=~/cure poison/i) {
		quest::say("Cure poison. eh?  Before we do that, you must fetch me three bixie stingers."); 
	}
}

sub EVENT_ITEM {
	#:: Match ten gold pieces
	if (plugin::takeCoin(0, 0, 10, 0)) {
		quest::say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.");
		#:: Cast 213 - Cure Disease
		$npc->CastSpell(213,$userid);
	}
	#:: Match three 14029 - Bixie Stinger, 
	if (plugin::check_handin(\%itemcount, 14029 => 3)) { 
		quest::say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.");
		#:: Cast 203 - Cure Poison
		$npc->CastSpell(203,$userid);
	}
	#:: Match one 13870 - Piranha Tooth
	if (plugin::check_handin(\%itemcount, 13870 => 1)) { 
		quest::say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.");
		#:: Cast 12 - Healing
		$npc->CastSpell(12,$userid);
	}
	#:: Match 13936 - Squad Ring
	if (plugin::check_handin(\%itemcount, 13936 => 1)) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.");
			#:: Give a 13936 - Squad Ring
			quest::summonitem(13936);
			#:: Ding!
			quest::ding();
		}
		else {
			quest::say("Fizzlethorpe Bristlebane only smiles upon the worthy, come back after your deeds have proven your worth.");
			#:: Give back a 13936 - Squad Ring
			quest::summonitem(13936);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
