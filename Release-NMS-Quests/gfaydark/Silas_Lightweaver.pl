sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("Have you come about the [troublemakers]? The faeries and pixies of this forest have grown bold!");
		if (quest::istaskactive(620005)) { quest::updatetaskactivity(620005, 2, 1); }
	}
	elsif ($text =~ /troublemakers|willing|help/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("Take this Faerie Catching Bottle. Capture ten of the troublemakers here, then release them in the Lesser Faydark where they belong.");
			quest::assigntask(620005);
			quest::summonitem(80040);
		} else {
			quest::say("The faeries are calm... return during the Nights of the Dead.");
		}
	}
}
