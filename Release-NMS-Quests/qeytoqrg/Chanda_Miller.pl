sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 1 or 12
	if ($wp == 1 || $wp == 12) {
		#:: Sit down
		plugin::SetAnim("sit");
	}
	#:: Match waypoint 5
	elsif ($wp == 5) {
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: Match waypoint 9
	elsif ($wp == 9) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /qeytoqrg/Baobob_Miller.pl
	if ($signal == 1) {
		quest::say("I am f.. fff.. fff.. fine, brother. You um.. don't need to worry about me so much. I am a big girl now.");
		#:: Send a signal '1' to The Qeynos Hills >> Baobob_Miller (4055) with a 5 second delay
		quest::signalwith(4055, 1, 5);
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Um.. I do not know you. Please um.. leave me be.");
	}
	elsif ($text=~/baobob sent me/i) {
		quest::say("oh.. Hello. My name is Chanda. $name is your name? That's a nice name. My [brother] sent you to talk to me? You must want some bear um.. [clothes].");
	}
	elsif ($text=~/brother/i) {
		quest::say("um.. My bother.. Um.. I mean BROTHER.. He is the finest tanner there is. His name is Baobob and I love him very much.");
	}
	elsif ($text=~/clothes/i) {
		quest::say("'I um.. Know how to make.. um.. [cloaks] and [boots]. Oh yes! And belts! I love to make bear skin belts! Um.. I really like [belts]. My [brother] says I have to start charging gold for my stuff though..");
	}
	elsif ($text=~/cloaks/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("I.. um.. can make.. um.. a good cloak for you. You have to get me a bear skin of high quality and my brother says I should not make them unless you also give me 21 gold pieces. I used to give them away but Baobob got mad at me so I don't do that anymore.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
	elsif ($text=~/boots/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("I know how to make boots. Um.. I don't like them as much as belts. They are harder to make. You have to get me a medium quality bear skin and give me 15 gold pieces if you want some bear boots. They are really good though. At least that is what Baobob tells me.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
	elsif ($text=~/belts/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Oh yes I like making belts! They are easy. All I need is a bear skin and 5 gold pieces. The bear skin doesn't have to be that great but don't bring me a ruined one. The gold was my brother's idea.. sorry.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13752 - High Quality Bear Skin and 21 gold pieces
	if (plugin::check_handin(\%itemcount, 13752 => 1, "gold" => 21)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Oh, good! I can make you a nice new cloak now. Here. Here. Oh, this.. it is a good one. Nice bear fur. Here you go!");
			#:: Give a 2902 - Bear-hide Cape
			quest::summonitem(12902);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(345, 2); 		#:: + Karana Residents
			quest::faction(262, 1);			#:: + Guards of Qeynos
			quest::faction(341, 1);			#:: + Priests of Life
			quest::faction(280, 1);			#:: + Knights of Thunder
			#:: Grant a small amount of experience
			quest::exp(500);
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
			#:: Return a 13752 - High Quality Bear Skin and 21 gold pieces
			quest::summonitem(13752);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Match a 13751 - Medium Quality Bear Skin and 15 gold pieces
	elsif (plugin::check_handin(\%itemcount, 13751 => 1, "gold" => 15)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Ohh good.. good! I.. um.. can make.. Oh great. Here you go. I hope you like it. I always um.. try my best. Tell your um.. friends where you got your bear things!");
			#:: Give a 2903 - Bear-hide Boots
			quest::summonitem(12903);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(345, 2); 		#:: + Karana Residents
			quest::faction(262, 1);			#:: + Guards of Qeynos
			quest::faction(341, 1);			#:: + Priests of Life
			quest::faction(280, 1);			#:: + Knights of Thunder
			#:: Grant a small amount of experience
			quest::exp(500);
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
			#:: Return a 13751 - Medium Quality Bear Skin and 15 gold pieces
			quest::summonitem(13751);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Match a 13750 - Low Quality Bear Skin and 5 gold pieces
	elsif (plugin::check_handin(\%itemcount, 13750 => 1, "gold" => 5)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Great. Oh, here, now I can make the.. um.. ok.. here. Yes.. good. I love making bear skin belts. Here you go. I hope you like it.");
			#:: Give a 2904 - Bear-hide Belt
			quest::summonitem(12904);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(345, 2); 		#:: + Karana Residents
			quest::faction(262, 1);			#:: + Guards of Qeynos
			quest::faction(341, 1);			#:: + Priests of Life
			quest::faction(280, 1);			#:: + Knights of Thunder
			#:: Grant a small amount of experience
			quest::exp(500);
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
			#:: Return a 13750 - Low Quality Bear Skin and 5 gold pieces
			quest::summonitem(13750);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
