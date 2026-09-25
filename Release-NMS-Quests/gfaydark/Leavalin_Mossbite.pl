sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("The dead have begun to take root in this forest! If you are [willing], take my Blessed Shillelagh and destroy the graveskulls sprouting to the northwest.");
	}
	elsif ($text =~ /willing|help/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("Bless you. Click the shillelagh on the graveskulls until they sink back into the earth.");
			quest::assigntask(620006);
			quest::summonitem(49061);
		} else {
			quest::say("The garden sleeps... return during the Nights of the Dead.");
		}
	}
}
