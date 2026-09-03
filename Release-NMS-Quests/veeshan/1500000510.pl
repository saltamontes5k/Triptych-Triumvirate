# Veeshan's Peak 2.0 - expedition gatekeeper.
# Grants an expedition into the version-100 instance of veeshan where the
# Gates-of-Discord era revamp content (level 70 brood + Phara Dar) resides.
# The classic zone (version 0) is left untouched.
#
# Acts like the server's Echo-of-the-Past givers: after the expedition is
# created the player speaks "ready" (via the saylink) and is moved into the
# instance from the zone safe point. Each bound member enters on their own
# "ready".

my $vp2_zone     = "veeshan";
my $vp2_version  = 100;
my $vp2_duration = 6 * 60 * 60;      # expedition lifetime
my $vp2_name     = "Veeshan's Peak 2.0";
my $vp2_min      = 1;
my $vp2_max      = 54;
my $vp2_lockout  = "Veeshan's Peak";

sub EVENT_SAY {
	my $text = defined $_[0] ? $_[0] : $text;
	return if (!defined $text);

	my $multiclass = quest::get_rule("Custom:MulticlassingEnabled");
	if ($multiclass ne "false") {
		$vp2_max = 6;
	}

	my $dz     = $client->GetExpedition();
	my $has_dz = ($dz && $dz->GetName() eq $vp2_name);

	if ($text =~ /hail/i) {
		if ($has_dz) {
			my $ready = quest::silent_saylink("ready");
			quest::say("The way to Veeshan's Peak 2.0 is open before you. When you are [$ready], speak the word and I will send you through.");
		} else {
			quest::say("The brood stirs anew upon the peak, hardened by the ages and hoarding treasures far greater than those of old. If you and your companions wish to [" . quest::saylink("challenge the peak", 1) . "], I will open the way.");
		}
		return;
	}

	if ($text =~ /ready/i) {
		if ($has_dz) {
			my $zone_id = $dz->GetZoneID();
			$client->MovePCInstance(
				$zone_id,
				$dz->GetInstanceID(),
				quest::GetZoneSafeX($zone_id),
				quest::GetZoneSafeY($zone_id),
				quest::GetZoneSafeZ($zone_id),
				quest::GetZoneSafeHeading($zone_id)
			);
		} else {
			quest::say("I hold no open way for you. If you wish to brave the peak, [" . quest::saylink("challenge the peak", 1) . "].");
		}
		return;
	}

	if ($text =~ /challenge the peak/i) {
		if ($has_dz) {
			my $ready = quest::silent_saylink("ready");
			quest::say("You are already bound to the peak. When you are [$ready], speak the word and I will send you through.");
			return;
		}

		my $lock = quest::get_expedition_lockout_by_char_id($client->CharacterID(), $vp2_name, $vp2_lockout);
		if ($lock && $lock->{remaining}) {
			my $mins = int($lock->{remaining} / 60);
			quest::say("The memory of the peak is still too fresh. Return in roughly " . int($mins / 60) . " hours.");
			return;
		}

		my $count = 1;
		my $group = $client->GetGroup();
		if ($group && $group->GroupCount() > 0) {
			$count = $group->GroupCount();
		}

		if ($count > $vp2_max) {
			quest::say("Too many of you wish to walk the peak. I can only guide " . $vp2_max . " at a time.");
			return;
		}
		if ($count < $vp2_min) {
			quest::say("You will need at least " . $vp2_min . " to survive the peak.");
			return;
		}

		my $created = $client->CreateExpedition($vp2_zone, $vp2_version, $vp2_duration, $vp2_name, $count, $count);
		if ($created) {
			my $ready = quest::silent_saylink("ready");
			quest::say("The wards part. Slay the five warders that bar Phara Dar's lair, then face the Queen of the Brood herself. When your company is ready, [$ready] and I will send you through.");
		} else {
			$client->Message(13, "The expedition could not be created. Are you in a group, and do all members meet the requirements?");
		}
	}
}

sub EVENT_SPAWN {
	if (defined($instanceversion) && $instanceversion > 0) {
		quest::depop();
	}
}
