sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("These are dangerous times, " . $client->GetCleanName() . ". The dead walk these hills, and not all of them mean us well. If you are [interested], I could use a hand escorting a traveler to Surefall Glade.");
		if (quest::istaskactive(620007)) { quest::updatetaskactivity(620007, 2, 1); }
	}
	elsif ($text =~ /interested/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("Bless you. Take this torch -- its flames ward off the undead. Say [ready] when you are prepared to depart.");
			quest::assigntask(620007);
			quest::summonitem(80041);
		} else {
			quest::say("The spirits are quiet... return during the Nights of the Dead.");
		}
	}
	elsif ($text =~ /ready/i) {
		if (quest::istaskactive(620007)) {
			quest::say("Then let us be off! Keep the traveler safe, and burn the minions of Pyzjn with the torch!");
			my $x = $npc->GetX(); my $y = $npc->GetY(); my $z = $npc->GetZ(); my $h = $npc->GetHeading();
			quest::spawn2(1500200023, 0, 0, $x + 15, $y, $z, $h);
			for my $i (0 .. 5) {
				quest::spawn2(1500200024, 0, 0, $x + 30 + ($i * 6), $y + 25 - ($i * 10), $z, $h);
			}
			quest::updatetaskactivity(620007, 0, 1);
		}
	}
}
