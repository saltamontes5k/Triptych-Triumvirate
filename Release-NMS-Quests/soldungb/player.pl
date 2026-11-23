sub EVENT_TARGET_CHANGE {
	if ($ulevel > 80) {
		if ($status < 80) {
			#:: OrigName + CleanNpcName so the banish also catches the Fabled
			#:: rename (The_Fabled_Lord_Nagafen) - FABLED-ENCOUNTERS.md 6.6
			if (plugin::CleanNpcName($client->GetTarget()->GetOrigName()) eq "Lord Nagafen") {
				quest::ze(0, "I will not fight you, but I will banish you!");
				#:: Move the client to Lavastorm at the specified coordinates
				$client->MovePC(27, 485, 911, 55, 106);
			}
		}
	}
}
sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	#:: The Fabled Lord Nagafen raid lives on soldungb version 2+
	#:: (requested from the Bazaar's #Sage_of_Anachronism).
	if (!$expedition || $expedition->GetZoneVersion() != 2) {
		return;
	}

	if ($client->GetGM()) {
		return;
	}

	$bind = $client->GetBindZoneID;
	$bindh = $client->GetBindHeading;
	$bindx = $client->GetBindX;
	$bindy = $client->GetBindY;
	$bindz = $client->GetBindZ;

	#:: Gate: Quarm dead (FNagafen stage objective) -- the design sheet's
	#:: tier rows describe future ordering, the live gate stays on Quarm.
	if (!plugin::is_stage_complete($client, 'FNagafen')) {
		$client->Message(7, "You don't belong here!");
		$client->MovePC($bind, $bindx, $bindy, $bindz, $bindh);
	}
}

# ---------------------------------------------------------------------------
# NMS: Old Man McKenzie's Defending the Lair (soldungb v44 monster mission).
# The controller (#Defending_the_Lair_Controller 1520002010) runs the encounter;
# this script is the player-facing voice. Player scripts receive EVERY say with
# identity (client.cpp dispatches EVENT_SAY to the zone player script for all
# channel messages), so no targeting is needed: every member of the expedition
# wears the dragon (race 49), and every form has say-driven abilities with
# per-character cooldowns, cast from the client itself ($client->CastSpell --
# perl_mob.cpp:970; Client inherits Mob). Being a real dragon means having fire.
# Version 0 and the Fabled versions are untouched.
# ---------------------------------------------------------------------------
my $lair_version = 44;

# ability => spell id / cooldown seconds
# (5145 Nagafen Fire is the real dragon's breath; 981 Dragon Roar is PBAE
# fear; 13 Complete Heal lands on the nearest living dragon; 732 Ice Comet
# and 453 Cascading Darkness hit the nearest raider)
my %LAIR_ABILITIES = (
	breath => { spell => 5145, cd => 10 },
	roar   => { spell => 981,  cd => 30 },
	bellow => { spell => 5162, cd => 120 },
	heal   => { spell => 13,   cd => 8 },
	nuke   => { spell => 732,  cd => 8 },
	tap    => { spell => 453,  cd => 12 },
);
my %lair_cd; # "name|ability" -> time() of the last cast

sub EVENT_SAY {
	return unless $client->GetZoneInstanceVersion() == $lair_version;
	return unless $client->GetRace() == 49; # only the dragon has a dragon's voice
	my $say = lc($message);
	$say =~ s/[^a-z]+//g; # "breath!", "Nuke", "tapthem" all match
	return unless exists $LAIR_ABILITIES{$say};
	my $def = $LAIR_ABILITIES{$say};

	my $key = $client->GetCleanName() . "|" . $say;
	my $left = (($lair_cd{$key} || 0) + $def->{cd}) - time();
	if ($left > 0) {
		$client->Message(15, ucfirst($say) . " is not ready yet (" . $left . " seconds).");
		return;
	}
	$lair_cd{$key} = time();

	my $target_id = 0;
	if ($say eq 'heal') {
		# the nearest living dragon (usually yourself)
		my ($best, $bestd);
		foreach my $c ($entity_list->GetClientList()) {
			next unless $c && $c->GetRace() == 49 && $c->GetHP() > 0;
			my $dx = $c->GetX() - $client->GetX();
			my $dy = $c->GetY() - $client->GetY();
			my $dz = $c->GetZ() - $client->GetZ();
			my $d2 = $dx * $dx + $dy * $dy + $dz * $dz;
			if (!defined $bestd || $d2 < $bestd) { $best = $c; $bestd = $d2; }
		}
		$best = $client if !$best;
		$target_id = $best->GetID();
	} elsif ($say eq 'nuke' || $say eq 'tap') {
		# nearest living raider
		my ($best, $bestd);
		foreach my $n ($entity_list->GetNPCList()) {
			next unless $n && $n->GetHP() > 0;
			my $tid = $n->GetNPCTypeID();
			next unless $tid >= 1520002011 && $tid <= 1520002018;
			my $dx = $n->GetX() - $client->GetX();
			my $dy = $n->GetY() - $client->GetY();
			my $dz = $n->GetZ() - $client->GetZ();
			my $d2 = $dx * $dx + $dy * $dy + $dz * $dz;
			if (!defined $bestd || $d2 < $bestd) { $best = $n; $bestd = $d2; }
		}
		if (!$best) {
			$client->Message(15, "No treasure-hunter within reach.");
			return;
		}
		$target_id = $best->GetID();
	} else {
		# breath / roar / bellow radiate from the dragon himself
		$target_id = $client->GetID();
	}

	$client->CastSpell($def->{spell}, $target_id);
}

sub EVENT_DEATH {
	return unless $client->GetZoneInstanceVersion() == $lair_version;
	# Silent unshroud so the bind release wakes the real character; no packets
	# here (client is on the death UI). In a delusion you do not really lose --
	# the controller's poll revives dead dragons every 30s, and its shroud work
	# re-dresses them. global_player.pl is the safety net for other exits.
	$client->RemoveShroudSilent();
}