# Cathil - Kithicor Forest, near the Rivervale trail.
# 2005 monster mission "Out With the Old", adapted as a scripted Void Legion
# defense event (no monster-mission tech on this server).  A_Silly_Puppet
# takes Bristlebane's Ticket of Admission (85062) to start it; this NPC takes
# the Void Artifact (3001014) afterwards.  Seasonal (peq_halloween).
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("The mist is thick tonight... return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		quest::say("Sit, sit! Tonight I tell the [tale] of the Void Legion - the night they marched on Rivervale.");
		if (quest::istaskactive(620017)) { quest::updatetaskactivity(620017, 3, 1); }
	}
	elsif ($text=~/tale/i) {
		quest::say("It was the night of the dead, long ago. The Void Legion poured out of the mist to burn Rivervale - and only six strange heroes stood against them. My puppet remembers it better than I do. Give him Bristlebane's Ticket of Admission and he will make you live it.");
	}
}

sub EVENT_ITEM {
	if ($itemcount{3001014} >= 1 && quest::istaskactive(620017)) {
		quest::updatetaskactivity(620017, 3, 1);
		quest::say("The Artifact of the Legion... and the tale ends the way Bristlebane likes them - the little folk still standing. Go on, tell Zigan Ribshard in the Plane of Knowledge what you saw. Wear a face that isn't yours when you do.");
	}
	else {
		plugin::return_items(\%itemcount);
	}
}
