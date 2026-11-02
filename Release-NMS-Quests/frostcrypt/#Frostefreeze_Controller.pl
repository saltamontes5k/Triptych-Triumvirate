#Frostefreeze_Controller.pl
# Frostefreeze (frostcrypt version 220 instances only) egress + ambience.
# The Freezer stands at the safe point. It murmurs. It offers the way out.
# IDs live in migration v294 (20261031_frostefreeze.sql): npc 1120002551,
# spawn2 1520028451. poknowledge is zoneid 202; the return spot is Grimble's
# corner (497,-30,-90).

sub EVENT_SAY {
	my $name = $client->GetCleanName();
	if ($text =~ /hail/i) {
		plugin::Whisper("It is cold in here, $name. It is always cold in here. Say [leave] and I will show you the way out. Or stay. The scoops are endless.");
	}
	elsif ($text =~ /leave/i) {
		plugin::Whisper("Mind the fifth step. There is no fifth step.");
		$client->MovePC(202, 497, -30, -90, 250);
	}
}

sub EVENT_SPAWN {
	quest::ze(15, "Somewhere behind the frost, something hums a lullaby off-key.");
}
