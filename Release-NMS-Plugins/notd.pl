# Nights of the Dead shared quest helpers.
# Seasonal content, gated by the 'peq_halloween' content flag.

sub notd_skeleton_zapping_say {
	my ($client, $text) = @_;
	if ($text =~ /hail/i) {
		quest::say("Greetings, " . $client->GetCleanName() . ". You look familiar, but now is not the time for pleasantries. A skeleton uprising has begun to overwhelm this area. If we don't [act fast] we'll be out of a home in no time at all.");
	}
	elsif ($text =~ /act fast|lend a hand|help/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("If you are willing to lend a hand we just might expel the wretches back to their graves. Take this scythe and put them down!");
			quest::assigntask(620004);
			quest::summonitem(87296, 10);
		}
		else {
			quest::say("The spirits are quiet... return during the Nights of the Dead.");
		}
	}
}
