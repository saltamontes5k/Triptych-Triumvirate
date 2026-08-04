sub EVENT_SPAWN {
	#:: Create a timer 'Beware' that triggers every 600 seconds (10 min)
	quest::settimer("Beware", 600);
	#:: Create a timer 'SpawnCondition' that triggers every 5 seconds
	quest::settimer("SpawnCondition", 5);
}

sub EVENT_SAY {
	if ($text=~/gandan has failed in his task/i) {
		quest::emote("'s thoughts begin to pervade your own, they creep into your mind with great force. You feel pressure as if your head will explode. You see his thoughts becoming your own. You see in these visions a tome bound in flesh dropped to the ground. You then open your eyes to see that same book, and take it knowing that it was meant for you.");
		#:: Give a 18898 - Flayed Skin Tome
		quest::summonitem(18898);
	}
}

sub EVENT_ITEM {
	#:: Match a 8226 - Satchel of Cazic-Thule, a 18898 - Flayed Skin Tome, and a 18899 - Flayed Skin Tome
	if (plugin::check_handin(\%itemcount, 8226 => 1, 18898 => 1, 18899 => 1)){
		quest::emote("seems pleased with the amount of pain that you have been able to inflict. Cazic Thule then grabs your hands and begins to infuse them with his power. Your hands burn like they were placed in lava for a moment, then feel cool as ice. You can feel the sheer power flowing through your new weapons of pain.");
		#:: Give a 7836 - Whistling Fists
		quest::summonitem(17836);
		#:: Ding!
		quest::ding();
		#:: Grant a huge amount of experience
		quest::exp(100000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_TIMER {
	#:: Match timer 'SpawnCondition'
	if ($timer eq "SpawnCondition") {
		#:: This was added to PEQ to prevent the entire zone from popping at once
		quest::spawn_condition("fearplane",0,1,0);
		quest::spawn_condition("fearplane",0,1,1);
		#:: Stop the timer 'SpawnCondition'
		quest::stoptimer("SpawnCondition");
	}
	#:: Match timer 'Beware'
	elsif ($timer eq "Beware") {
		quest::shout("Beware all infidels who dare to taint my plane, for I shall rend your minds with fright, dread, and terror!");
		#:: Send a signal '1' to the indicated npc_type id without delay
		quest::signalwith(72029, 1, 0);		#:: Amygdalan_knight
		quest::signalwith(72015, 1, 0);		#:: Amygdalan_warrior
		quest::signalwith(72062, 1, 0);		#:: a_boogeyman
		quest::signalwith(72074, 1, 0);		#:: a_broken_golem
		quest::signalwith(72103, 1, 0);		#:: a_decrepit_warder
		quest::signalwith(72090, 1, 0);		#:: a_dracoliche
		quest::signalwith(72059, 1, 0);		#:: a_fetid_fiend (male)
		quest::signalwith(72065, 1, 0);		#:: a_fetid_fiend (female)
		quest::signalwith(72081, 1, 0);		#:: a_frightfinger
		quest::signalwith(72076, 1, 0);		#:: a_glare_lord
		quest::signalwith(72031, 1, 0);		#:: a_gorgon
		quest::signalwith(72087, 1, 0);		#:: a_nightmare
		quest::signalwith(72102, 1, 0);		#:: a_phantasm
		quest::signalwith(72052, 1, 0);		#:: a_samhain
		quest::signalwith(72094, 1, 0);		#:: a_scareling
		quest::signalwith(72050, 1, 0);		#:: a_shiverback
		quest::signalwith(72058, 1, 0);		#:: a_spinechiller_spider
		quest::signalwith(72057, 1, 0);		#:: a_tentacle_tormentor
		quest::signalwith(72055, 1, 0);		#:: a_turmoil_toad
		quest::signalwith(72022, 1, 0);		#:: a_worry_wraith
		quest::signalwith(72071, 1, 0);		#:: phoboplasm
		quest::signalwith(72001, 1, 0);		#:: Wraith_of_a_Shissir
		quest::signalwith(72000, 1, 0);		#:: Dread
		quest::signalwith(72004, 1, 0);		#:: Fright
		quest::signalwith(72002, 1, 0);		#:: Terror
	}
	#:: Match timer 'dt'
	elsif ($timer eq "dt") {
		$target = $npc->GetHateTop();
		if ($target->IsPet()) {
			$owner = $target->GetOwnerID();
			$npc->CastSpell(982, $owner);
		}
		else {
			$npc->CastSpell(982, $target);
		}
	}
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::shout("Denizens of Fear, your master commands you to come forth to his aid!!");
		#:: Send a signal '2' to the indicated npc_type id without delay
		quest::signalwith(72029, 2, 0);		#:: Amygdalan_knight
		quest::signalwith(72015, 2, 0);		#:: Amygdalan_warrior
		quest::signalwith(72062, 2, 0);		#:: a_boogeyman
		quest::signalwith(72074, 2, 0);		#:: a_broken_golem
		quest::signalwith(72103, 2, 0);		#:: a_decrepit_warder
		quest::signalwith(72090, 2, 0);		#:: a_dracoliche
		quest::signalwith(72059, 2, 0);		#:: a_fetid_fiend (male)
		quest::signalwith(72065, 2, 0);		#:: a_fetid_fiend (female)
		quest::signalwith(72081, 2, 0);		#:: a_frightfinger
		quest::signalwith(72076, 2, 0);		#:: a_glare_lord
		quest::signalwith(72031, 2, 0);		#:: a_gorgon
		quest::signalwith(72087, 2, 0);		#:: a_nightmare
		quest::signalwith(72102, 2, 0);		#:: a_phantasm
		quest::signalwith(72052, 2, 0);		#:: a_samhain
		quest::signalwith(72094, 2, 0);		#:: a_scareling
		quest::signalwith(72050, 2, 0);		#:: a_shiverback
		quest::signalwith(72058, 2, 0);		#:: a_spinechiller_spider
		quest::signalwith(72057, 2, 0);		#:: a_tentacle_tormentor
		quest::signalwith(72055, 2, 0);		#:: a_turmoil_toad
		quest::signalwith(72022, 2, 0);		#:: a_worry_wraith
		quest::signalwith(72071, 2, 0);		#:: phoboplasm
		quest::signalwith(72001, 2, 0);		#:: Wraith_of_a_Shissir
		quest::signalwith(72000, 2, 0);		#:: Dread
		quest::signalwith(72004, 2, 0);		#:: Fright
		quest::signalwith(72002, 2, 0);		#:: Terror
		#:: Create a timer 'dt' that triggers every 45 seconds
		quest::settimer("dt", 45);
	}
	#:: Match combat state 0 - left combat
	elsif ($combat_state == 0) {
		#:: Send a signal '3' to the indicated npc_type id without delay
		quest::signalwith(72029, 3, 0);		#:: Amygdalan_knight
		quest::signalwith(72015, 3, 0);		#:: Amygdalan_warrior
		quest::signalwith(72062, 3, 0);		#:: a_boogeyman
		quest::signalwith(72074, 3, 0);		#:: a_broken_golem
		quest::signalwith(72103, 3, 0);		#:: a_decrepit_warder
		quest::signalwith(72090, 3, 0);		#:: a_dracoliche
		quest::signalwith(72059, 3, 0);		#:: a_fetid_fiend (male)
		quest::signalwith(72065, 3, 0);		#:: a_fetid_fiend (female)
		quest::signalwith(72081, 3, 0);		#:: a_frightfinger
		quest::signalwith(72076, 3, 0);		#:: a_glare_lord
		quest::signalwith(72031, 3, 0);		#:: a_gorgon
		quest::signalwith(72087, 3, 0);		#:: a_nightmare
		quest::signalwith(72102, 3, 0);		#:: a_phantasm
		quest::signalwith(72052, 3, 0);		#:: a_samhain
		quest::signalwith(72094, 3, 0);		#:: a_scareling
		quest::signalwith(72050, 3, 0);		#:: a_shiverback
		quest::signalwith(72058, 3, 0);		#:: a_spinechiller_spider
		quest::signalwith(72057, 3, 0);		#:: a_tentacle_tormentor
		quest::signalwith(72055, 3, 0);		#:: a_turmoil_toad
		quest::signalwith(72022, 3, 0);		#:: a_worry_wraith
		quest::signalwith(72071, 3, 0);		#:: phoboplasm
		quest::signalwith(72001, 3, 0);		#:: Wraith_of_a_Shissir
		quest::signalwith(72000, 3, 0);		#:: Dread
		quest::signalwith(72004, 3, 0);		#:: Fright
		quest::signalwith(72002, 3, 0);		#:: Terror
		#:: Stop the timer 'dt' from triggering
		quest::stoptimer("dt");
	}
}

sub EVENT_DEATH_COMPLETE {
	#:: Send a signal '3' to the indicated npc_type id without delay
	quest::signalwith(72029, 3, 0);		#:: Amygdalan_knight
	quest::signalwith(72015, 3, 0);		#:: Amygdalan_warrior
	quest::signalwith(72062, 3, 0);		#:: a_boogeyman
	quest::signalwith(72074, 3, 0);		#:: a_broken_golem
	quest::signalwith(72103, 3, 0);		#:: a_decrepit_warder
	quest::signalwith(72090, 3, 0);		#:: a_dracoliche
	quest::signalwith(72059, 3, 0);		#:: a_fetid_fiend (male)
	quest::signalwith(72065, 3, 0);		#:: a_fetid_fiend (female)
	quest::signalwith(72081, 3, 0);		#:: a_frightfinger
	quest::signalwith(72076, 3, 0);		#:: a_glare_lord
	quest::signalwith(72031, 3, 0);		#:: a_gorgon
	quest::signalwith(72087, 3, 0);		#:: a_nightmare
	quest::signalwith(72102, 3, 0);		#:: a_phantasm
	quest::signalwith(72052, 3, 0);		#:: a_samhain
	quest::signalwith(72094, 3, 0);		#:: a_scareling
	quest::signalwith(72050, 3, 0);		#:: a_shiverback
	quest::signalwith(72058, 3, 0);		#:: a_spinechiller_spider
	quest::signalwith(72057, 3, 0);		#:: a_tentacle_tormentor
	quest::signalwith(72055, 3, 0);		#:: a_turmoil_toad
	quest::signalwith(72022, 3, 0);		#:: a_worry_wraith
	quest::signalwith(72071, 3, 0);		#:: phoboplasm
	quest::signalwith(72001, 3, 0);		#:: Wraith_of_a_Shissir
	quest::signalwith(72000, 3, 0);		#:: Dread
	quest::signalwith(72004, 3, 0);		#:: Fright
	quest::signalwith(72002, 3, 0);		#:: Terror
}
