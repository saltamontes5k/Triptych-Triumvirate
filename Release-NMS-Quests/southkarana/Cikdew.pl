sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("Oh, hello. I've been trying to brew a dreadful potion, but I've lost the pieces. [Do this] for me and I'll reward you.");
	}
	elsif ($text =~ /do this|help|willing/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("Take this cauldron. I need my Lost Mirror from Erudin, my Broken Horseshoe from the Centaur Village, Rock Salt, and a Candied Spider. Brew the potion, pour it on a grave in Shadowrest, and bring me the Dreadful Mushroom that grows there.");
			quest::assigntask(620011);
			quest::summonitem(3001001);
		} else {
			quest::say("The spirits sleep... return during the Nights of the Dead.");
		}
	}
}

sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 3001004 => 1, 3001005 => 1, 75856 => 1, 13497 => 1)) {
		quest::say("You found everything! Here, I've mixed the brew for you. Take it to the third headstone southeast in Shadowrest, and pour it on the grave.");
		quest::summonitem(3001006);
		if (quest::istaskactive(620011)) { quest::updatetaskactivity(620011, 5, 1); }
	}
	elsif (plugin::check_handin(\%itemcount, 3001002 => 1)) {
		quest::say("The Dreadful Mushroom! Wonderful. As promised, take your reward.");
		if (quest::istaskactive(620011)) { quest::updatetaskactivity(620011, 7, 1); }
	} else {
		plugin::return_items(\%itemcount);
	}
}
