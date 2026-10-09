# A Silly Puppet - Kithicor Forest, beside Cathil.
# Entry for "Out With the Old" (task 620017): hand in Bristlebane's Ticket of
# Admission (85062) to start the Void Legion defense event.
# Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		return;
	}
	if ($text=~/hail/i) {
		quest::say("TICKET! TICKET! Hand over Bristlebane's Ticket of Admission and [imagine] the old war!");
		if (quest::istaskactive(620017)) { quest::say("The Legion is already afoot - defend the trail!"); }
	}
	elsif ($text=~/imagine/i) {
		quest::say("Give me the ticket, give me the ticket! Then watch the mist!");
	}
}

sub EVENT_ITEM {
	if ($itemcount{85062} >= 1 && quest::is_content_flag_enabled('peq_halloween') && !quest::istaskactive(620017)) {
		quest::assigntask(620017);
		quest::say("*The puppet's jaw clacks wildly* ONCE UPON A TIME the Void Legion came for Rivervale - and HERE THEY COME! Repel them! WAVE AFTER WAVE! And mind the one with the big hat!");
		quest::signal(1500200084, 1);
	}
	else {
		plugin::return_items(\%itemcount);
	}
}
