sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 3
	if ($wp == 3) {
		quest::say("Greetings, sister! I just wanted to make sure no harm had befallen you.");
		#:: Send a sigal '1' to The Qeynos Hills >> Chanda_Miller (4052) with a 5 second delay
		quest::signalwith(4052, 1, 5);
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: Match waypoint 4
	elsif ($wp == 4) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}
	#:: Match waypoint 7
	elsif ($wp == 7) {
		#:: Sit down
		plugin::SetAnim("sit");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /qeytoqrg/Chanda_Miller.pl
	if ($signal == 1) {
		quest::say("But, you will always be my little sister. Fare well, Chanda! See you soon!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, there. My name is Baobob Miller. My [sister] and I are the best tanners in all of Norrath. Wolves are my specialty. A nice wolf skin [garment] would be the perfect accessory to your stylish ensemble.");
	}
	elsif ($text=~/sister/i) {
		quest::say("My little sister Chanda is the second best tanner around! Seriously though, she is a very skilled artisan and people travel far and wide to aquire one of her fine bear skin cloaks. I am very proud of her. She doesn't really like to meet new people, but, if you tell her [Baobob sent you], I am sure she can help get you into some nice bear skin boots.");
	}
	elsif ($text=~/garment/i) {
		quest::say("I make the finest wolf skin [boots], [cloaks], and [belts] in all of Antonica.");
	}
	elsif ($text=~/boots/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("If you can bring me a wolf skin of medium quality and pay me a fee of say... hmmm... for you... 15 gold pieces, I think I can make you a pair of boots that will make all of Qeynos envy you.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
	elsif ($text=~/cloaks/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Yes! One of my wolf skin cloaks would go very well with your... eeerr... style... Ahem! Let's see... I think I can get you into one for 21 gold pieces, but, you have to provide the skin, and I make my cloaks with only the highest quality wolf skins.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
	elsif ($text=~/belts/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Belts are far more forgiving than cloaks or boots. A lesser quality pelt and 5 gold pieces would get you a nice wolf-hide belt.");
		}
		else {
			quest::say("Hmm.. I really would not feel comfortable helping you in that way. You need to prove yourself to me by aiding my friends and family in the Plains of Karana before I will help you.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13755 - High Quality Wolf Skin and 21 gold pieces
	if (plugin::check_handin(\%itemcount, 13755 => 1, "gold" => 21)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Here ya go! That should keep ya nice and warm! Be sure to tell all the friends you're going to impress where you got this fine cloak. Although I am sure they probably have heard of me already.");
			#:: Give a 2905 - Wolf-hide Cape
			quest::summonitem(12905);
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
			#:: Return a 13755 - High Quality Wolf Skin and 21 gold pieces
			quest::summonitem(13755);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Match a 13754 - Medium Quality Wolf Skin and 15 gold pieces
	elsif (plugin::check_handin(\%itemcount, 13754 => 1, "gold" => 15)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("They are exquisite, if I do say so myself. Hope they fit.");
			#:: Give a 2906 - Wolf-hide Boots
			quest::summonitem(12906);
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
			#:: Return a 13754 - Medium Quality Wolf Skin and 15 gold pieces
			quest::summonitem(13754);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Match a 13753 - Low Quality Wolf Skin and 5 gold pieces
	elsif (plugin::check_handin(\%itemcount, 13753 => 1, "gold" => 5)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("I hate working with such low quality hides. They lack the sheen that makes a high quality pelt look so fine! Anyhow, here's your belt.");
			#:: Give a 2907 - Wolf-hide Belt
			quest::summonitem(12907);
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
			#:: Return a 13753 - Low Quality Wolf Skin and 5 gold pieces
			quest::summonitem(13753);
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
