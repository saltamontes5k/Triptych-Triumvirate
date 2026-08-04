sub EVENT_SPAWN {
	#:: Set a timer for four hours
	quest::settimer("HastenDepop",14400);
	#:: Clear out items
	$npc->ClearItemList();
	#:: Clear out gold
	$gold = 0;
}

sub EVENT_TIMER {
	#:: Match the four hour timer
	if ($timer eq "HastenDepop") {
		#:: Stop the timer HastenDepop
		quest::stoptimer("HastenDepop");
		#:: Depop and start the spawn point timer
		quest::depop_withtimer();
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Stopped I have done. Greet you I will. What business do we have? Hmm? Speak up!!");
	}
	elsif ($text=~/journeyman boots/i) {
		quest::say("Journeyman Boots are what you seek? Ha!! I have those upon my feet and disinigrate will they if my life is taken. Extra pair have I and [rare trade] can we make.");
	}
	elsif ($text=~/rare trade/i) {
		quest::say("I call for three things and Journeyman Boots are yours. I call for a [Shadowed Rapier], call for the [Ring of the Ancients] and call for Gold.. 3250 Gold Coins!! This the trade that I call.");
	}
	elsif ($text=~/shadowed rapier/i) {
		quest::say("Shadowed Men, foes to all, have appeared. Many lands do they walk. Invisible are they, but items they wield can be seen. Seek them out and return to me a Shadowed Rapier. Return it with haste before 'poof' goes the rapier!! No time to camp have you.");
	}
	elsif ($text=~/ring of the ancients/i) {
		quest::say("Ancient cyclops do march the land.  Long have they lived and crafted the rings of the ancients.  I must have one and you shall go and fetch one for me.  Seek the lands of the oldest cyclops clans.  Seek the plains. seek the island in tears and search the dunes for there is one who is last.  His clan was blown from the sands.");
	}
}

sub EVENT_ITEM {
	#:: Let's MultiqQuest!
	plugin::mq_process_items(\%itemcount);
	#:: Match a 7100 - Shadowed Rapier and 12268 - Ring of the Ancients and 3250 gold
	if (plugin::check_handin(\%itemcount, 7100 => 1, 12268 => 1, "gold" => 3250)) {
		quest::say("The time to trade has come!! I am now rich and you are now fast. Take the Journeyman Boots and run like the wind.");
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(1250);
		#:: Give a 2300 - Journeyman's Boots
		quest::summonitem(12300);
		#:: Clear out items
		$npc->ClearItemList();
		#:: Clear out gold
		$gold = 0;
	}
	#:: Match a 7100 - Shadowed Rapier and 3250 gold
	elsif (plugin::check_handin(\%itemcount, 7100 => 1, "gold" => 3250)) {
		plugin::mq_process_items(7100 => 1);
		#:: Match a 7100 - Shadowed Rapier and 12268 - Ring of the Ancients
		if (plugin::check_mq_handin(12268 => 1, 7100 => 1)) {
			quest::say("The time to trade has come!! I am now rich and you are now fast. Take the Journeyman Boots and run like the wind.");
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1250);
			#:: Give a 2300 - Journeyman's Boots
			quest::summonitem(12300);
			#:: Clear out items
			$npc->ClearItemList();
			#:: Clear out gold
			$gold = 0;
		} else {
			quest::say("A Ring of the Ancients you still owe me!");
		}
	}
	#:: Match a 12268 - Ring of the Ancients and 3250 gold
	elsif (plugin::check_handin(\%itemcount, 12268 => 1, "gold" => 3250)) {
		plugin::mq_process_items(12268 => 1);
		#:: Match a 7100 - Shadowed Rapier and 12268 - Ring of the Ancients
		if (plugin::check_mq_handin(12268 => 1, 7100 => 1)) {
			quest::say("The time to trade has come!! I am now rich and you are now fast. Take the Journeyman Boots and run like the wind.");
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1250);
			#:: Give a 2300 - Journeyman's Boots
			quest::summonitem(12300);
			#:: Clear out items
			$npc->ClearItemList();
			#:: Clear out gold
			$gold = 0;
		} else {
			quest::say("A Shadowed Rapier you still owe me!");
		}
	}
	#:: Match a 7100 - Shadowed Rapier
	elsif (plugin::check_handin(\%itemcount, 7100 => 1)) {
		#:: Match a 7100 - Shadowed Rapier and 12268 - Ring of the Ancients
		if (plugin::check_mq_handin(12268 => 1, 7100 => 1)) {
			quest::say("The time to trade has come!! I am now rich and you are now fast. Take the Journeyman Boots and run like the wind.");
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1250);
			#:: Give a 2300 - Journeyman's Boots
			quest::summonitem(12300);
			#:: Clear out items
			$npc->ClearItemList();
			#:: Clear out gold
			$gold = 0;
		} else {
			quest::say("A Ring of the Ancients and 3250 Gold you owe me!");
		}

	}
	#:: Match a 12268 - Ring of the Ancients
	elsif (plugin::check_handin(\%itemcount, 12268 => 1)) {
		#:: Match a 7100 - Shadowed Rapier and 12268 - Ring of the Ancients
		if (plugin::check_mq_handin(12268 => 1, 7100 => 1)) {
			quest::say("The time to trade has come!! I am now rich and you are now fast. Take the Journeyman Boots and run like the wind.");
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1250);
			#:: Give a 2300 - Journeyman's Boots
			quest::summonitem(12300);
			#:: Clear out items
			$npc->ClearItemList();
			#:: Clear out gold
			$gold = 0;
		} else {
			quest::say("A Shadowed Rapier and 3250 Gold you owe me!");
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
