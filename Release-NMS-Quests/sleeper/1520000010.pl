#!/usr/bin/env perl
# Keeper of the Tomb - offers the classic "Sleeper's Tomb" expedition
# (zone sleeper, instance version 1). Echo-style flow: create the expedition,
# then "ready" sends the speaker into the instance.
use strict;
use warnings;

# Globals injected by the quest parser.
our ($client, $npc, $text, $instanceversion, $entity_list);

my $zone_short  = "sleeper";
my $version     = 1;
my $duration    = 6 * 60 * 60;              # expedition lifetime (seconds)
my $name        = "Sleeper's Tomb";
my $lockout     = "Sleeper's Tomb";
my $min_players = 1;
my $max_players = 72;

sub EVENT_SAY {
	if ($text =~ /hail/i) {
		my $dz = $client->GetExpedition();
		if ($dz && $dz->GetName() eq $name) {
			my $ready = quest::silent_saylink("ready");
			quest::say("When you are [$ready], I will open the way into the tomb.");
		} else {
			my $go = quest::saylink("tomb", 1);
			quest::say("This is the tomb as it stood before the wards fell and the ancients took it. Shall I send you into the [$go]?");
		}
	}
	elsif ($text =~ /tomb/i) {
		my $dz = $client->GetExpedition();
		if ($dz && $dz->GetName() eq $name) {
			my $ready = quest::silent_saylink("ready");
			quest::say("You are already bound to the tomb. When you are [$ready], step forward.");
			return;
		}

		my $lock = quest::get_expedition_lockout_by_char_id($client->CharacterID(), $name, $lockout);
		if ($lock && $lock->{remaining}) {
			my $mins = int($lock->{remaining} / 60);
			quest::say("The memory of the tomb is still too fresh. Return in roughly " . int($mins / 60) . " hours.");
			return;
		}

		my $count = 1;
		my $group = $client->GetGroup();
		if ($group) {
			$count = $group->GroupCount();
		}

		if ($count > $max_players) {
			quest::say("Too many of you wish to enter. I can guide only " . $max_players . " at a time.");
			return;
		}
		if ($count < $min_players) {
			quest::say("You will need at least " . $min_players . " to survive the tomb.");
			return;
		}

		my $created = $client->CreateExpedition($zone_short, $version, $duration, $name, $count, $count);
		if ($created) {
			$created->SetCompass($zone_short, $npc->GetX(), $npc->GetY(), $npc->GetZ());
			$created->SetSafeReturn($zone_short, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
			my $ready = quest::silent_saylink("ready");
			quest::say("The wards are parted. When your company is [$ready], step forward and I will send you in.");
		} else {
			$client->Message(13, "The expedition could not be created. Please make sure every group member is here with you.");
		}
	}
	elsif ($text =~ /ready/i) {
		my $dz = $client->GetExpedition();
		if ($dz && $dz->GetName() eq $name) {
			my $zone_id = $dz->GetZoneID();
			$client->MovePCInstance(
				$zone_id,
				$dz->GetInstanceID(),
				quest::GetZoneSafeX($zone_id),
				quest::GetZoneSafeY($zone_id),
				quest::GetZoneSafeZ($zone_id),
				quest::GetZoneSafeHeading($zone_id)
			);
		}
	}
}

sub EVENT_SPAWN {
	# Only suppressed inside the 1.0 expedition (instance version 1). The 2.0
	# encounter can run in the open zone (v0) and in static/farming instances
	# (v254/v255) where this script also bootstraps the seal set.
	if (defined($instanceversion) && $instanceversion == 1) {
		quest::depop();
		return;
	}

	# Sleepers 2.0 bootstrap.
	#
	# This NPC is an unconditional spawn, so its EVENT_SPAWN is the first reliable
	# post-Repop hook in the zone (the Lua encounter's event_encounter_load fires
	# too early, before Repop and before spawn conditions load). Swap the classic
	# Warder spawn set for the Ancients seal set and place Kerafyrm (#Kerafyrm,
	# 128089) in the chamber as a visible-but-untargetable bubble boss. The
	# encounter handler (encounters/sleeper_custom.lua) owns the seal gate and the
	# fight.
	our $sleepers2_ready;
	return if $sleepers2_ready;
	$sleepers2_ready = 1;

	quest::spawn_condition("sleeper", 2, 1); # Ancients on
	quest::spawn_condition("sleeper", 1, 0); # Warders/classic off
	quest::depopall(128045);                 # classic #The_Final_Arbiter
	quest::depopall(128094);                 # classic #The_Sleeper

	if (!$entity_list->GetMobByNpcTypeID(128089)) {
		quest::unique_spawn(128089, 0, 0, -1481, -2373, -1034, 520); # #Kerafyrm, sealed
	}
}
