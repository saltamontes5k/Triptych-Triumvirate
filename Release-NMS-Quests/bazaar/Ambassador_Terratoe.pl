############################################
# ZONE: Bazaar
# TYPE: Custom (NMS)
#
# NAME: Ambassador Terratoe
# RACE: Halfling
#
# PURPOSE:
#   Offers a one-time "Return Home" service.
#
#   Normal path:
#     - Sets the player's home city (Character select -> Return Home)
#       to Rivervale (19).
#     - Forces the player's effective faction with the Vale factions to
#       the halfling defaults, regardless of race/class/deity.
#
#   Special path (worshipper of Bristlebane + Scars of Velious complete):
#     - Sets the home city to the Plane of Mischief (126) instead.
#     - Sets faction 437 (Denizens of Mischief) friendly.
#     The intentionally KOS trash (faction 5013) is left alone.
############################################

my $RIVERVALE_ZONE   = 19;
my $MISCHIEF_ZONE    = 126;
my $BRISTLEBANE      = 205;
my $DENIZENS_FACTION = 437;
my $SOV_STAGE        = 'SoV';

# faction_id => desired effective standing (halfling defaults)
my %VALE_FACTION_TARGETS = (
	292 => 100,  # Merchants of Rivervale
	286 => 375,  # Mayor Gubbin
	263 => 50,   # Guardians of the Vale
	300 => 50,   # Priests of Mischief
	241 => 50,   # Deeppockets
	355 => 50,   # Storm Reapers
);

sub EVENT_SAY {
	my $special = is_special_case();

	if ($text =~ /hail/i) {
		plugin::NPCTell(
			"Hail, $name. I am Ambassador Terratoe, steward of halfling hospitality."
		);

		if ($special) {
			plugin::NPCTell(
				"The Bristlebane-touched who have walked the frozen wastes are always welcome at my table. "
				. "Shall I [" . quest::saylink("home_pom", 1, "make the Plane of Mischief your home") . "]?"
			);
		}
		else {
			plugin::NPCTell(
				"Would you like me to [" . quest::saylink("home_rivervale", 1, "make Rivervale your home") . "]? "
				. "I will bind your return home there and restore your standing with the vale."
			);
		}
	}
	elsif ($text =~ /^home_rivervale$/i) {
		plugin::NPCTell(
			"Setting your home to Rivervale will change where the Return Home button takes you, "
			. "and will set your standing with the vale to that of a native halfling. "
			. "Do you wish to proceed? ["
			. quest::saylink("confirm_rivervale", 1, "Yes, bring me home")
			. "] or ["
			. quest::saylink("cancel", 1, "No, not yet")
			. "]?"
		);
	}
	elsif ($text =~ /^confirm_rivervale$/i) {
		$client->SetStartZone($RIVERVALE_ZONE);
		set_effective_factions(\%VALE_FACTION_TARGETS);
		plugin::NPCTell(
			"Welcome home, $name. Rivervale is yours, and the vale knows you as one of its own."
		);
	}
	elsif ($text =~ /^home_pom$/i && $special) {
		plugin::NPCTell(
			"The Plane of Mischief will become your home, and its denizens will count you a friend. "
			. "Do you wish to proceed? ["
			. quest::saylink("confirm_pom", 1, "Yes, take me to Mischief")
			. "] or ["
			. quest::saylink("cancel", 1, "No, not yet")
			. "]?"
		);
	}
	elsif ($text =~ /^confirm_pom$/i && $special) {
		$client->SetStartZone($MISCHIEF_ZONE);
		set_effective_factions({ $DENIZENS_FACTION => 100 });
		plugin::NPCTell(
			"Very well, $name. The Plane of Mischief is your home, and the Denizens will not raise a hand against you."
		);
	}
	elsif ($text =~ /^cancel$/i) {
		plugin::NPCTell("As you wish. Return when you are ready.");
	}
}

sub is_special_case {
	return $client->GetDeity() == $BRISTLEBANE && plugin::is_stage_complete($client, $SOV_STAGE);
}

# Forces the player's effective faction standing to the given targets,
# regardless of race/class/deity, by applying the delta through
# SetFactionLevel2 (which adds to the personal faction value).
sub set_effective_factions {
	my ($targets) = @_;

	foreach my $faction_id (keys %{$targets}) {
		my $target = $targets->{$faction_id};

		# A few correction passes absorb Heroic CHA scaling in UpdatePersonalFaction.
		for (my $pass = 0; $pass < 3; $pass++) {
			my $delta = $target - $client->GetModCharacterFactionLevel($faction_id);
			last if $delta == 0;

			$client->SetFactionLevel2(
				$client->CharacterID(),
				$faction_id,
				$client->GetClass(),
				$client->GetBaseRace(),
				$client->GetDeity(),
				$delta,
				0
			);
		}
	}
}
# END of FILE Zone:bazaar -- Ambassador_Terratoe.pl
