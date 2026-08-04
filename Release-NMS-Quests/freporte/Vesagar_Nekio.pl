sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome into our church of rage. I am Vesagar Nekio, servant of Innoruuk. If you should [require healing] or [cure poison] or [cure disease] then just let me know.");
	}
	elsif ($text=~/require healing/i) {
		#::  Match if faction is Indifferent or better
		if ($faction <= 5 ) {
			quest::say("If you wish me to lay my hands upon your wounds, you must first lay 10 gold coins upon my palm.");
		}
		else {
			quest::say("Blasphemer!!  You are no ally of the Dismal Rage.  Run while you still have legs!!");
		}
	}
	elsif ($text=~/cure disease/i) {
		#::  Match if faction is Indifferent or better
		if ($faction <= 5 ) {
			quest::say("I thought I sensed the the touch of Bertoxxulous within you. Before we can cast it out, we shall need a slab of zombie skin.");
		}
		else {
			quest::say("Blasphemer!!  You are no ally of the Dismal Rage.  Run while you still have legs!!");
		}
	}
	elsif ($text=~/cure poison/i) {
		#::  Match if faction is Indifferent or better
		if ($faction <= 5 ) {
			quest::say("Before the rage inside can force the poison from your blood, you will pay tribute by offering the Prince of Hate a spider venom sac.");
		}
		else {
			quest::say("Blasphemer!!  You are no ally of the Dismal Rage.  Run while you still have legs!!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match 10 gold pieces
	if (plugin::takeCoin(0, 0, 10, 0)) {
		quest::say("Your gold has proven your faith in our ways as well as having made my pockets a bit heavier. Let the power of the Prince of Hate bind your wounds.");
		#:: Cast spell 12 - Healing
		$npc->CastSpell(12,$client);
	}		
	#:: Match a 13074 - Zombie Skin
	elsif (plugin::check_handin(\%itemcount, 13074 => 1)) {
		quest::say("The malady which has overtaken your frail body shall be cast out and in its place, your hate shall grow.");
		#:: Cast spell 213 - Cure Disease
		$npc->CastSpell(213,$client);
	}
	#:: Match a 14018 - Spider Venom Sac
	elsif (plugin::check_handin(\%itemcount, 14018 => 1)) {
		quest::say("Your offering has strengthened your faith in our ways. Let the spittle of Innoruuk wash the poison from your body.");
		#:: Cast spell 203 - Cure Poison
		$npc->CastSpell(203,$client);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
