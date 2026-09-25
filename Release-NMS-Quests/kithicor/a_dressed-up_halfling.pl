sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("My costume is missing its final pieces! A Bloody Vampire in Castle Mistmoore stole my cloak and fangs. Are you [willing to search]?");
	}
	elsif ($text =~ /willing to search|willing|help/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("Oh thank you! Slay the Bloody Vampire in Castle Mistmoore and bring back my Bloody Vampire Cloak and Fangs.");
			quest::assigntask(620008);
		} else {
			quest::say("Not now... the season is not right.");
		}
	}
}

sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 85060 => 1, 85061 => 1)) {
		quest::say("My cloak and fangs! My costume is complete. Here, take this ticket with my thanks.");
		if (quest::istaskactive(620008)) { quest::updatetaskactivity(620008, 2, 1); }
	} else {
		plugin::return_items(\%itemcount);
	}
}
