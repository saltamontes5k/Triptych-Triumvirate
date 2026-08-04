# Agent of Retribution Library

use POSIX qw(ceil);

sub OfferStandardInstance {
	my $client = plugin::val('$client');
	my $npc = plugin::val('$npc');
	my $text = plugin::val('$text');
	my $zonesn = plugin::val('$zonesn');
	my $dz_version = 254;
	my $non_respawning_duration = 14 * 60 * 60; # 14 Hours
	my $respawning_duration =  30 * 60; # 30 minutes
	my $dz_lifetime = 7 * 24 * 60 * 60; # 7 Days
	my ($expedition_name, $min_players, $max_players, $dz_zone, $x, $y, $z, $heading) = @_;

	# Zones that are entirely long-respawn (>= 2h) content. A Respawning (Farming) instance
	# suppresses every such mob (see spawn2.cpp suppress_spawn) so it comes up empty - only offer
	# Non-Respawning for these. Add zone short names as needed.
	my %non_respawning_only = (
		growthplane => 1,
	);
	my $allow_respawning = !$non_respawning_only{$dz_zone};

	if ($client->IsTaskActivityActive(4, 4)) {
		$client->UpdateTaskActivity(4, 4, 1);
	}

	if (plugin::IsSeasonal($client) || plugin::MultiClassingEnabled()) {
		$max_players = 6;
	}

	if ($text =~ /hail/i) {
		my $dz = $client->GetExpedition();
		if (
			$dz &&
			(
				$dz->GetName() eq "$expedition_name (Respawning)" ||
				$dz->GetName() eq "$expedition_name (Non-Respawning)"
			)
		) {
			my $ready_link = quest::silent_saylink("ready");
			plugin::NPCTell("When you are [$ready_link], proceed into the portal.");
		} else {
			my $respawning_link = quest::silent_saylink("Respawning");
			my $non_respawning_link = quest::silent_saylink("Non-Respawning");

			plugin::NPCTell("I offer you a Trial. $expedition_name lies before you, do you accept the challenge?");

			if (plugin::IsNMS()) {
				plugin::YellowText("Notice: Instances will become more difficult for each player in your group beyond the second.");
				plugin::YellowText("[$non_respawning_link] will not repopulate over time, and the most powerful enemies may be found within.");
				if ($allow_respawning) {
					plugin::YellowText("[$respawning_link] will repopulate over time, but many rare enemies may not be found inside.");
				}
			} else {
				if ($allow_respawning) {
					plugin::YellowText("You can select from [$respawning_link] or [$non_respawning_link] versions.");
				} else {
					plugin::YellowText("You can select the [$non_respawning_link] version.");
				}
			}
		}
	} elsif ($text eq "Respawning" || $text eq "Non-Respawning") {
		if ($text eq "Respawning" && !$allow_respawning) {
			plugin::YellowText("A Respawning trial is not available here - this zone's inhabitants are too powerful to reappear over time. Choose Non-Respawning.");
			return;
		}
		$dz_version = (
			$text eq "Non-Respawning" ?
			(quest::get_rule("Custom:StaticInstanceVersion") || 100) :
			(quest::get_rule("Custom:FarmingInstanceVersion") || 100)
		);
		$expedition_name .= " ($text)";
	
		my $dz = $client->CreateExpedition($dz_zone, $dz_version, $dz_lifetime, $expedition_name, $min_players, $max_players);
		if ($dz) {
			my $ready_link = quest::silent_saylink("ready");

			$dz->SetCompass($zonesn, $npc->GetX(), $npc->GetY(), $npc->GetZ());
			$dz->SetSafeReturn($zonesn, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());

			if ($text eq "Respawning") {
				$dz->AddReplayLockout($respawning_duration);
			} elsif ($text eq "Non-Respawning") {
				$dz->AddReplayLockout($non_respawning_duration);
			}
	
			plugin::YellowText("The instance is [$ready_link].");
		} else {
			plugin::YellowText("Unable to create instance.");
		}
	}
	elsif ($text =~ /ready/i) {
		my $dz = $client->GetExpedition();
		if (
			$dz &&
			(
				$dz->GetName() eq "$expedition_name (Respawning)" ||
				$dz->GetName() eq "$expedition_name (Non-Respawning)"
			)
		) {
			# Fallback to safe zone coordinates if x, y, z, or heading are not defined
			my $final_x = defined $x ? $x : quest::GetZoneSafeX($dz->GetZoneID());
			my $final_y = defined $y ? $y : quest::GetZoneSafeY($dz->GetZoneID());
			my $final_z = defined $z ? $z : quest::GetZoneSafeZ($dz->GetZoneID());
			my $final_heading = defined $heading ? $heading : quest::GetZoneSafeHeading($dz->GetZoneID());

			$client->MovePCInstance($dz->GetZoneID(), $dz->GetInstanceID(), $final_x, $final_y, $final_z, $final_heading);
		}
	}	
}

sub ScaleInstanceNPC {
	my $instanceversion = plugin::val('$instanceversion');
	if ($instanceversion != quest::get_rule("Custom:StaticInstanceVersion")) {
		return;
	}

	my $npc = shift;
	my $player_count = shift;

	if (!$npc || !$player_count || $player_count <= 2 || ($npc->GetOwner() && $npc->GetOwner()->IsClient())) {
		return;
	}

	my $scale_percentage = 0.25;
	if ($npc->GetEntityVariable("scale_percentage")) {
		$scale_percentage = $npc->GetEntityVariable("scale_percentage");
	}

	$player_count -= 2;
	my $player_scale_factor = ($player_count * $scale_percentage);

	# Ensure original stats are stored
	if (!$npc->GetEntityVariable("original_max_hp")) {
		$npc->SetEntityVariable("original_max_hp", $npc->GetMaxHP());
		$npc->SetEntityVariable("original_max_hit", $npc->GetNPCStat("max_hit"));
		$npc->SetEntityVariable("original_min_hit", $npc->GetNPCStat("min_hit"));
		$npc->SetEntityVariable("original_atk", $npc->GetNPCStat("atk"));
		$npc->SetEntityVariable("original_avoidance", $npc->GetNPCStat("avoidance"));
		$npc->SetEntityVariable("original_accuracy", $npc->GetNPCStat("accuracy"));
		$npc->SetEntityVariable("original_hp_regen", $npc->GetNPCStat("hp_regen"));
		$npc->SetEntityVariable("original_ac", $npc->GetNPCStat("ac"));
		
		# Resistances
		$npc->SetEntityVariable("original_mr", $npc->GetNPCStat("mr"));
		$npc->SetEntityVariable("original_fr", $npc->GetNPCStat("fr"));
		$npc->SetEntityVariable("original_cr", $npc->GetNPCStat("cr"));
		$npc->SetEntityVariable("original_dr", $npc->GetNPCStat("dr"));
		$npc->SetEntityVariable("original_pr", $npc->GetNPCStat("pr"));
	}

	# Calculate the new scaled values based on original stats
	my $scale_factor = 1 + $player_scale_factor;
	my $minor_scale_factor = 1 + ($player_scale_factor * 0.5);

	# Scale max_hp, max_hit, min_hit, and hp_regen by 1 + $scale_factor
	my $new_max_hp = ceil($npc->GetEntityVariable("original_max_hp") * $scale_factor);
	my $hp_ratio	 = $npc->GetHPRatio();
	$npc->ModifyNPCStat("max_hp", $new_max_hp);
	$npc->SetHP($npc->GetMaxHP() * $hp_ratio / 100);

	my $new_max_hit = ceil($npc->GetEntityVariable("original_max_hit") * $scale_factor);
	$npc->ModifyNPCStat("max_hit", $new_max_hit);

	my $new_min_hit = ceil($npc->GetEntityVariable("original_min_hit") * $scale_factor);
	$npc->ModifyNPCStat("min_hit", $new_min_hit);

	my $new_hp_regen = ceil($npc->GetEntityVariable("original_hp_regen") * $scale_factor);
	$npc->ModifyNPCStat("hp_regen", $new_hp_regen);

	# Scale all other stats by minor_scale_factor (50% of 1 + player_scale_factor)
	my $new_atk = ceil($npc->GetEntityVariable("original_atk") * $minor_scale_factor);
	$npc->ModifyNPCStat("atk", $new_atk);

	my $new_avoidance = ceil($npc->GetEntityVariable("original_avoidance") * $minor_scale_factor);
	$npc->ModifyNPCStat("avoidance", $new_avoidance);

	my $new_accuracy = ceil($npc->GetEntityVariable("original_accuracy") * $minor_scale_factor);
	$npc->ModifyNPCStat("accuracy", $new_accuracy);

	my $new_ac = ceil($npc->GetEntityVariable("original_ac") * $minor_scale_factor);
	$npc->ModifyNPCStat("ac", $new_ac);

	# Scale resistances by minor_scale_factor
	my $new_mr = ceil($npc->GetEntityVariable("original_mr") * $minor_scale_factor);
	$npc->ModifyNPCStat("mr", $new_mr);

	my $new_fr = ceil($npc->GetEntityVariable("original_fr") * $minor_scale_factor);
	$npc->ModifyNPCStat("fr", $new_fr);

	my $new_cr = ceil($npc->GetEntityVariable("original_cr") * $minor_scale_factor);
	$npc->ModifyNPCStat("cr", $new_cr);

	my $new_dr = ceil($npc->GetEntityVariable("original_dr") * $minor_scale_factor);
	$npc->ModifyNPCStat("dr", $new_dr);

	my $new_pr = ceil($npc->GetEntityVariable("original_pr") * $minor_scale_factor);
	$npc->ModifyNPCStat("pr", $new_pr);

	# These just use absolute values
	$npc->ModifyNPCStat("spellscale", $scale_factor * 100);
	$npc->ModifyNPCStat("healscale", $scale_factor * 100);
}
