sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, mighty adventurer! I am Guard Cheslin Sydwend and I am here to serve and protect. Feel safe when we Qeynos guards are on watch. We are the best!");
	}
	elsif ($text=~/father sent me|chesgard sent me/i) {
		quest::say("My father has no need to worry and I do not need a baby sitter. I may be in training still, but a Qeynos guard in training is still a formidable opponent. EVIL, BEWARE!! HAIL ANTONIUS BAYLE!");
	}
	elsif ($text=~/donate/i) {
		quest::say("Of course I shall donate to that esteemed order. Here you are, my good friend. Now run along before you are injured by some nasty creature. By the way, you should speak with my fellow guard, Leopold. He also would donate.");
		#:: Give a 13295 - Donation
		quest::summonitem(13295);
	}
	elsif ($text=~/^illusion$/i) {
		quest::say("Yes!! I seem to have dropped some of my [Illusion cards].");
	}
	elsif ($text=~/illusion cards/i) {
		quest::say("Oh!! Do you play Illusion, too? I love that game. I have some very rare cards in my deck. I seem to have dropped four of them somewhere during my last patrol. Darn it! They probably blew away the minute I dropped them! I will never find those cards again.");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 1
	if ($wp == 1) {
		quest::say("Hail, fellow guards! I am off to protect the travelers of the hills from evil. I shall return!");
		#:: Send a signal '1' to The Qeynos Hills >> Hefax_Tinmar (4142) with no delay
		quest::signalwith(4142, 1, 0);
		#:: Send a signal '1' to The Qeynos Hills >> Mogan_Delfin (4069) with no delay
		quest::signalwith(4069, 1, 0);
	}
	#:: Match waypoint 3
	elsif ($wp == 3) {
		quest::say("Fear not, simple travelers. Cheslin the masterful is here to protect you.");
		#:: Create a 13905 - Library of Erudin at the current location with a 300,000 ms (5 min) decay time
		quest::creategroundobject(13905, $x, $y, $z, 0, 300000);
		quest::say("Hey! Did I just drop something?");
	}
	#:: Match waypoint 4
	elsif ($wp == 4) {
		quest::say("Fear not, simple travelers. Cheslin the masterful is here to protect you.");
		#:: Create a 13904 - Ebon Lotus at the current location with a 300,000 ms (5 min) decay time
		quest::creategroundobject(13904, $x, $y, $z, 0, 300000);
		quest::say("Hey! Did I just drop something?");
	}
	#:: Match waypoint 7
	elsif ($wp == 7) {
		quest::say("Fear not, simple travelers. Cheslin the masterful is here to protect you.");
		#:: Create a 13907 - Diamond Vale at the current location with a 300,000 ms (5 min) decay time
		quest::creategroundobject(13907, $x, $y, $z, 0, 300000);
		quest::say("Hey! Did I just drop something?");
	}
	#:: Match waypoint 9
	elsif ($wp == 9) {
		quest::say("Fear not, simple travelers. Cheslin the masterful is here to protect you.");
		#:: Create a 13906 - Chrono Cyclone at the current location with a 300,000 ms (5 min) decay time
		quest::creategroundobject(13906, $x, $y, $z, 0, 300000);
		quest::say("Hey! Did I just drop something?");
	}
	#:: Match waypoint 11
	elsif ($wp == 11) {
		quest::say("I lost some of my [illusion] playing cards. And they were the rare ones too! Darn it! If anyone finds them, please return them to me.");
	}
}

sub EVENT_ITEM {
	#:: Let's Multi-Quest!
	plugin::mq_process_items(\%itemcount);
	#:: Match a 13904 - Ebon Lotus, a 13905 - Library of Erudin, a 13906 - Chrono Cyclone, and a 13907 - Diamond Vale
	if (plugin::check_handin(\%itemcount, 13904 => 1, 13905 => 1, 13906 => 1, 13907 => 1)) {
		quest::say("Oh great! I have all my cards back. Here is a little something for assisting a Qeynos guard. And any time you are in trouble, just call on Cheslin, master swordsman. Take it to my father, Master Chesgard of the Knights of Thunder in Qeynos. No doubt he sent you to follow me on my watch.");
		#:: Give a 18839 - Sealed Letter
		quest::summonitem(18839);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(262, 20);			#:: + Guards of Qeynos
		quest::faction(219, 3);				#:: + Antonius Bayle
		quest::faction(230, -3);			#:: - Corrupt Qeynos Guards
		quest::faction(223, -5);			#:: - Circle of Unseen Hands
		quest::faction(291, 2);				#:: + Merchants of Qeynos
		#:: Grant a moderate amount of experience
		quest::exp(1500);
		#:: Create a hash for storing cash - 150 to 250cp
		my %cash = plugin::RandomCash(150,250);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Clear out items
		$npc->ClearItemList();
	}
	#:: Match a 13904 - Ebon Lotus
	elsif (plugin::check_handin(\%itemcount, 13904 => 1)) {
		plugin::mq_process_items(13904 => 1);
		if (plugin::check_mq_handin(13904 => 1, 13905 => 1, 13906 => 1, 13907 => 1)) {
			quest::say("Oh great! I have all my cards back. Here is a little something for assisting a Qeynos guard. And any time you are in trouble, just call on Cheslin, master swordsman. Take it to my father, Master Chesgard of the Knights of Thunder in Qeynos. No doubt he sent you to follow me on my watch.");
			#:: Give a 18839 - Sealed Letter
			quest::summonitem(18839);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(262, 20);		#:: + Guards of Qeynos
			quest::faction(219, 3);			#:: + Antonius Bayle
			quest::faction(230, -3);		#:: - Corrupt Qeynos Guards
			quest::faction(223, -5);		#:: - Circle of Unseen Hands
			quest::faction(291, 2);			#:: + Merchants of Qeynos
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a hash for storing cash - 150 to 250cp
			my %cash = plugin::RandomCash(150,250);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Clear out items
			$npc->ClearItemList();
		}
		else {
			quest::say("Wow!! I thought I lost this for good. All together I lost the [illusion] cards: Ebon Lotus, Library of Erudin, Chrono Cyclone and Diamond Vale. Man!! Those are rare cards!");
		}
	}
	#:: Match a 13905 - Library of Erudin
	elsif (plugin::check_handin(\%itemcount, 13905 => 1)) {
		plugin::mq_process_items(13905 => 1);
		if (plugin::check_mq_handin(13904 => 1, 13905 => 1, 13906 => 1, 13907 => 1)) {
			quest::say("Oh great! I have all my cards back. Here is a little something for assisting a Qeynos guard. And any time you are in trouble, just call on Cheslin, master swordsman. Take it to my father, Master Chesgard of the Knights of Thunder in Qeynos. No doubt he sent you to follow me on my watch.");
			#:: Give a 18839 - Sealed Letter
			quest::summonitem(18839);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(262, 20);		#:: + Guards of Qeynos
			quest::faction(219, 3);			#:: + Antonius Bayle
			quest::faction(230, -3);		#:: - Corrupt Qeynos Guards
			quest::faction(223, -5);		#:: - Circle of Unseen Hands
			quest::faction(291, 2);			#:: + Merchants of Qeynos
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a hash for storing cash - 150 to 250cp
			my %cash = plugin::RandomCash(150,250);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Clear out items
			$npc->ClearItemList();
		}
		else {
			quest::say("Wow!! I thought I lost this for good. All together I lost the [illusion] cards: Ebon Lotus, Library of Erudin, Chrono Cyclone and Diamond Vale. Man!! Those are rare cards!");
		}
	}
	#:: Match a 13906 - Chrono Cyclone
	elsif (plugin::check_handin(\%itemcount, 13906 => 1)) {
		plugin::mq_process_items(13906 => 1);
		if (plugin::check_mq_handin(13904 => 1, 13905 => 1, 13906 => 1, 13907 => 1)) {
			quest::say("Oh great! I have all my cards back. Here is a little something for assisting a Qeynos guard. And any time you are in trouble, just call on Cheslin, master swordsman. Take it to my father, Master Chesgard of the Knights of Thunder in Qeynos. No doubt he sent you to follow me on my watch.");
			#:: Give a 18839 - Sealed Letter
			quest::summonitem(18839);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(262, 20);		#:: + Guards of Qeynos
			quest::faction(219, 3);			#:: + Antonius Bayle
			quest::faction(230, -3);		#:: - Corrupt Qeynos Guards
			quest::faction(223, -5);		#:: - Circle of Unseen Hands
			quest::faction(291, 2);			#:: + Merchants of Qeynos
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a hash for storing cash - 150 to 250cp
			my %cash = plugin::RandomCash(150,250);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Clear out items
			$npc->ClearItemList();
		}
		else {
			quest::say("Wow!! I thought I lost this for good. All together I lost the [illusion] cards: Ebon Lotus, Library of Erudin, Chrono Cyclone and Diamond Vale. Man!! Those are rare cards!");
		}
	}
	#:: Match a 13907 - Diamond Vale
	elsif (plugin::check_handin(\%itemcount, 13907 => 1)) {
		plugin::mq_process_items(13907 => 1);
		if (plugin::check_mq_handin(13904 => 1, 13905 => 1, 13906 => 1, 13907 => 1)) {
			quest::say("Oh great! I have all my cards back. Here is a little something for assisting a Qeynos guard. And any time you are in trouble, just call on Cheslin, master swordsman. Take it to my father, Master Chesgard of the Knights of Thunder in Qeynos. No doubt he sent you to follow me on my watch.");
			#:: Give a 18839 - Sealed Letter
			quest::summonitem(18839);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(262, 20);		#:: + Guards of Qeynos
			quest::faction(219, 3);			#:: + Antonius Bayle
			quest::faction(230, -3);		#:: - Corrupt Qeynos Guards
			quest::faction(223, -5);		#:: - Circle of Unseen Hands
			quest::faction(291, 2);			#:: + Merchants of Qeynos
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a hash for storing cash - 150 to 250cp
			my %cash = plugin::RandomCash(150,250);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Clear out items
			$npc->ClearItemList();
		}
		else {
			quest::say("Wow!! I thought I lost this for good. All together I lost the [illusion] cards: Ebon Lotus, Library of Erudin, Chrono Cyclone and Diamond Vale. Man!! Those are rare cards!");
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
