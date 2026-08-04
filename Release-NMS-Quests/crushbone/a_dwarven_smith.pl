sub EVENT_SAY {
	if ($text=~/ringmail/i) {
		quest::say("The king was the last person I heard of who was wearing what sounded like my ringmail. Return it to me and I will reward you with a fine weapon I forged myself.");
	}
	if ($text=~/interested/i) {
		quest::say("Okay, then! The first item you can get back for me is my brass shield. Up on that hill, over where the trainees practice, there is usually an instructor. Last time I saw my shield, it was in the hands of one of those blasted lackeys. Bring it back to me!");
	}
}

sub EVENT_ITEM {
	#:: Match a 10351 - Brass Earring
	if (plugin::check_handin(\%itemcount, 10351 => 1)) {
		quest::say("Outstanding! If you can kill the taskmaster, you might prove useful in recovering the items the orcs took from me when they caught me out in the Faydarks. [Interested] in helping me out?");
		#:: Give item 13850 - Unfinished Blade Mold
		quest::summonitem(13850);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(3000);
	}
	#:: Match a 9307 - Shiny Brass Shield
	elsif (plugin::check_handin(\%itemcount, 9307 => 1)) {
		quest::say("MY SHIELD!! Excellent, laddie! Next item on the list is my ringmail. Once I have my [ringmail], I am out of here for good. I will finally be able to leave!");
		#:: Give item 13850 - Unfinished Sledge Mold
		quest::summonitem(13851);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(3000);
	}
	#:: Match a 3301 - Dwarven Ringmail Tunic
	elsif (plugin::check_handin(\%itemcount, 3301 => 1)) {
		quest::say("AHA!! My ringmail!! My, you ARE a resourceful one! Here is your reward as promised. It is exquisite, if I do say so myself. You might also wish to tell the priest in the cell over there that the king is dead. I am sure he will be pleased to hear that and might even be able to help you further. Farewell! It's time for me to make my escape!");
		#:: Give item 6315 - Dwarven Mace
		quest::summonitem(16315);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(3000);
		#:: Create a timer 'depop' that triggers every 60 seconds (1 min)
		quest::settimer("depop", 60);
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
