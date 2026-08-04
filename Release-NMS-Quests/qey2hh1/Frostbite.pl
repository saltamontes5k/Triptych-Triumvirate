sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("RUFF RUFF");
	}
}

sub EVENT_ITEM {
	#:: Match a 12140 - Regurgitonic
	if (plugin::check_handin(\%itemcount, 12140 => 1)) {
		#:: Give a 13383 - Koalindl Fish
		quest::summonitem(13383);
		#:: Ding!
		quest::ding();
	}
	#:: Match a 12226 - Sweaty Shirt
	elsif (plugin::check_handin(\%itemcount, 12226 => 1)) {
		quest::emote("takes a whiff of the sweaty shirt and barks.");
		#:: Create a timer "follow" that loops every 15 seconds
		quest::settimer("follow", 15);
		#:: Create a timer "depop" that loops every 1200 seconds (20 minutes)
		quest::settimer("depop", 1200);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_TIMER {
	#:: Match timer "follow"
	if ($timer eq "follow") {
		#:: Stop the timer "follow" from looping
		quest::stoptimer("follow");
		#:: Create a scalar variable to store a random npc_type id: The Western Plains of Karana >> Basil (12190) [80%] or Paglan (12191) [20%]
		my $mobid = quest::ChooseRandom(12190, 12190, 12190, 12190, 12190, 12191);
		#:: Create a scalar variable to store a random x location
		my $x = quest::ChooseRandom(-3461, -3902, -4011);
		#:: Create a scalar variable to store a random y location
		my $y = quest::ChooseRandom(-1457, -3240, -1362);
		#:: Spawn one and only one Basil or Paglan
		quest::unique_spawn($mobid, 188, 0, $x, $y, 10, 0);
		#:: Set running to true (run)
		quest::SetRunning(1);
		#:: Create a scalar variable to store the npc_type id of Basil or Paglan
        	my $getmobbynpctype = $entity_list->GetMobByNpcTypeID($mobid);
		#:: Create a scalar variable to store the entity id of Basil or Paglan
		my $follow_target = $getmobbynpctype->GetID();
		#:: Follow Basil or Paglan
		quest::follow($follow_target);
	}
	elsif ($timer eq "depop") {
		#:: Stop the timer "depop" from looping
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal "1" from The Western Plains of Karana >> Basil (12190)
	if ($signal == 1) {
		#:: Stop following Basil
		quest::sfollow();
		#:: Set running false (walk)
		quest::SetRunning(0);
		#:: Move to location provided and guard
		quest::moveto(-2236, -3532, 34, 110, 1);
		#:: Stop the timer "depop" from looping
		quest::stoptimer("depop");
	}
	#:: Match a signal "2" from The Western Plains of Karana >> Paglan (12191)
	elsif ($signal == 2) {
		#:: Stop following Paglan
		quest::sfollow();
		#:: Set running false (walk)
		quest::SetRunning(0);
		#:: Move to location provided and guard
		quest::moveto(-2236, -3532, 34, 110, 1);
		#:: Stop the timer "depop" from looping
		quest::stoptimer("depop");
	}
}
