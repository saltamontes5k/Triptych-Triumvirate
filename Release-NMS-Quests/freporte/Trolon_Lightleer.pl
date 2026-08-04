sub EVENT_SPAWN {
	#:: Create a timer 'ready' that loops every 30 seconds
	quest::settimer("ready", 30);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings!! I am Trolon Lightleer. Harmonizer of the soul. Please sit and order an ale. I shall be playing soon.");
	}
}

sub EVENT_TIMER {
	#:: Match timer 'ready'
	if ($timer eq "ready") {
		quest::say("What a cheerful crowd.");
		#:: Stop the timer
		quest::stoptimer("ready");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /freporte/Henna_Treghost.pl
	if ($signal == 1) {
		#:: Create a scalar to store a random number
		my $singasong = quest::ChooseRandom(1, 2);
		#:: Match singasong = 1
		if ($singasong == 1) {
			quest::say("Here's one for Sir Lucan... He's just a ruler. In a long line of rulers. Looking for a few more orcs to slay. They say that he fights them with one hand tied to his back. And he won't leave Freeport till you remember his name. Thank you.");
			#:: Send a signal '1' to East Freeport >> Plnorrick_Spinecracker (10163) with no delay
			quest::signalwith(10163, 1, 0);
			#:: Send a signal '3' to East Freeport >> Talym_Shoontar (10182) with a three second delay
			quest::signalwith(10163, 3, 3);
		}
		#:: Match singasong = 2
		elsif ($singasong == 2) {
			quest::say("Look around you. Stand up tall!! Feel for the poor and never have a cold heart. Becausee we are all in this. We are not like the rest. We're all here together and know we are the best. So Norrath, can't you see the error in your ways? You're living separated each and every day. Don't be thinking that we don't want you, because, Norrath, we do. Freeport is the only place where your friend can be from afar. I hope you enjoyed that one.");
			#:: Send a signal '1' to East Freeport >> Sir_Edwin_Motte (10199) with no delay
			quest::signalwith(10199, 1, 0);
		}
		elsif ($singasong == 3) {
			quest::say("My city is mighty and all shall learn to cower. We are nothing less than the ultimate power. My city is pure and filled with beautiful charm. I shall conquer you to save you from harm. My city shall first send its guards to back you in times of need. Soon you shall learn to live under my laws, indeed. So bow down when you see me and give out my favorite cheer, 'All Hail Antonius Bail!' My city is Qeynos and there is nothing to fear.");
			#:: Send a signal '1' to East Freeport >> Tlin_Bowfright (10186) with no delay
			quest::signalwith(10186, 1, 0);
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
