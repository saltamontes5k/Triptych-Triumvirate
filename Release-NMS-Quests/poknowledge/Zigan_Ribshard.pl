# Zigan Ribshard - Plane of Knowledge.
# Final turn-in for the 2005 Bone Mask of Horror series: gives the
# level-appropriate mask. Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if($text=~/hail/i) {
		if(quest::is_content_flag_enabled('peq_halloween')) {
			my $lvl  = $client->GetLevel();
			my $mask = 90046;                 # Dusty (required level 0)
			if    ($lvl >= 60) { $mask = 90040; }  # Bone Mask of Horror (60)
			elsif ($lvl >= 50) { $mask = 90041; }  # Solid (50)
			elsif ($lvl >= 40) { $mask = 90042; }  # Calcified (40)
			elsif ($lvl >= 30) { $mask = 90043; }  # Strengthened (30)
			elsif ($lvl >= 20) { $mask = 90044; }  # Hardened (20)
			elsif ($lvl >= 10) { $mask = 90045; }  # Cracked (10)
			quest::say("You wear the face of the dead... take this mask, and may the Nights of the Dead fill your foes with fright!");
			quest::summonitem($mask);
		} else {
			quest::say("The spirits sleep. Return during the Nights of the Dead.");
		}
	}
}
