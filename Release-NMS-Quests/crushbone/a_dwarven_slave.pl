sub EVENT_SAY {	
	if ($text=~/hail/i) {
		quest::say("Slavedrivers are just lackeys for the [taskmaster]. He is the real orc in charge.");
	}
	elsif ($text=~/taskmaster/i) {
		quest::say("The taskmaster?? He is that large orc who runs around with that [brass earring] in his ear.");
	}
	elsif ($text=~/brass earring/i) {
		quest::say("Yeah, a bronze earring; He wears it like a newly crowned king. If I ever had that earring I know I would stand a chance at escape.");
	}
}

sub EVENT_ITEM {
	#:: Create scalar variables for mob race and gender
	my $npcrace = $npc->GetRace();
	my $npcgender = $npc->GetGender();

	#:: Match copper
	if ($copper == 1) {
		if ($npcrace == 8 && $npcgender == 0) {
			quest::say("No, no!! I do not need this!! Get me key number 16!!");
		}
		elsif ($npcrace == 8 && $npcgender == 1) {
			quest::say("What is this!!? Get me key number 17!!");
		}
	}
	#:: Match a 20016 - Shackle Key 16
	elsif (plugin::check_handin(\%itemcount, 20016 => 1)) {
		if ($npcrace == 8 && $npcgender == 0) {
			quest::say("Good work!! I shall be on my way. Farewell my friend!!");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(274, 1); 		#:: + Kazon Stormhammer
			quest::faction(312, 1); 		#:: + Storm Guard
			quest::faction(322, 1); 		#:: + Miners Guild 628
			quest::faction(290, 1); 		#:: + Merchants of Kaladim
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 700 to 750cp
			my %cash = plugin::RandomCash(700,750);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Create a timer 'depop' that triggers every 30 seconds
			quest::settimer("depop",30);
		}
		elsif ($npcrace == 8 && $npcgender == 1) {
			quest::say("I have no need for this item $name, you can have it back.");
			#:: Give a 20016 - Shackle Key 16
			quest::summonitem(20016);
		}
	}
	#:: Match a 10351 - Brass Earring
	elsif (plugin::check_handin(\%itemcount, 10351 => 1)) {
		if ($npcrace == 8 && $npcgender == 0) {
			quest::say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			#:: Give a 18905 - Worn Rune (Csb 1.O.U. Dwf 1)
			quest::summonitem(18905);
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a timer 'depop' that triggers every 30 seconds
			quest::settimer("depop",30);
		}
		elsif ($npcrace == 8 && $npcgender == 1) {
			quest::say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			#:: Give a 18906 - Small Wood Carving (Csb 1.O.U. Dwf 2)
			quest::summonitem(18906);
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a timer 'depop' that triggers every 30 seconds
			quest::settimer("depop",30);
		}
	}
	#:: Match a 20017 - Shackle Key 17
	elsif (plugin::check_handin(\%itemcount, 20017 => 1)) {
		if ($npcrace == 8 && $npcgender == 1) {
			quest::say("Good work!! I shall be on my way. Farewell my friend!!");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(274, 1); 		#:: + Kazon Stormhammer
			quest::faction(312, 1); 		#:: + Storm Guard
			quest::faction(322, 1); 		#:: + Miners Guild 628
			quest::faction(290, 1); 		#:: + Merchants of Kaladim
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 700 to 750cp
			my %cash = plugin::RandomCash(700,750);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Create a timer 'depop' that triggers every 30 seconds
			quest::settimer("depop",30);
		}
		elsif ($npcrace == 8 && $npcgender == 0) {
			quest::say("I have no need for this item $name, you can have it back.");
			#:: Give a 20017 - Shackle Key 17
			quest::summonitem(20017);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_TIMER {
	#:: Match the timer 'depop'
	if ($timer eq "depop") {
		#:: Stop the timer 'depop'
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
}
