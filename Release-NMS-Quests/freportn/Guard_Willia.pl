sub EVENT_SPAWN {
	#:: Create a timer that loops every 20 minutes
	quest::settimer("depop",1200);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Please, let me go. I shall leave the  [Freeport Militia]. I did not know they were such a vile group.");
		quest::stoptimer("depop");
		#:: Create a timer that loops every 30 seconds
		quest::settimer("cry",30);
	}
	elsif ($text=~/Freeport Militia/i) {
		quest::say("I thought they were nothing more than the local militia. Little did I know they were so vile. Now I am stuck [here] and I ask for your forgiveness.");
	}
	elsif ($text=~/here/i) {
		quest::say("I came here to escape the militia and ask [Merko to forgive] me.");
	}
	elsif ($text=~/Merko to forgive/i) {
		quest::say("I had a small encounter with his wife, my aunt. She was quite red after that altercation. I guess I upset her in a great way, somehow. Could you please go ask Merko to forgive Willia. I shall wait here for his answer..");
	}
}


sub EVENT_TIMER {
	#:: Match if timer named "depop"
	if ($timer eq "depop") {
		#:: Stop the timer "depop"
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
	#:: Match if timer named "cry"
	elsif ($timer eq "cry") {
		quest::say("Please do not harm me!! I am a lady underneath this garb. I just wanted to join the [Freeport Militia] to help my people.. Please.. Please.. I am nobody. Marr have mercy. I give you the truth. Is that not what you stand for? Merko is my Uncle!!");
		#:: Stop the timer "cry"
		quest::stoptimer("cry");
		#:: Create a timaer run" that loops every 60 seconds
		quest::settimer("run",60);
	}
	#:: Match if timer name "run"
	elsif ($timer eq "run") {
		quest::say("Thank you, my friend. I shall mend my ways.. maybe.");
		#:: Stop the timer "run"
		quest::stoptimer("run");
		#:: Create a timer that loops every 60 seconds
		quest::settimer("cry",60);
		#:: Start running
		quest::SetRunning(1);
		#:: Start pathing grid 14
		quest::start(14);
	}		
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
