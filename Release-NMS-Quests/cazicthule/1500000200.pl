#!/usr/bin/env perl
# Echo of the Temple - offers the "Revamped Cazic Thule" expedition (zone cazicthule, instance v1).
# Echo-style flow: create the expedition, then "ready" punts the speaker into the instance.
use strict;
use warnings;

my $zone_short  = "cazicthule";
my $version     = 1;
my $duration    = 6 * 60 * 60;              # expedition lifetime (seconds)
my $name        = "Revamped Cazic Thule";
my $min_players = 1;
my $max_players = 6;

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        my $dz = $client->GetExpedition();
        if ($dz && $dz->GetName() eq $name) {
            my $ready = quest::silent_saylink("ready");
            quest::say("When you are [$ready], proceed into the portal.");
        } else {
            my $go = quest::saylink("revamp", 1);
            quest::say("Long ago this temple burned with the fury of the Thul Tae Ew. I can show you the temple as it was - brutal, savage, and alive with power. Shall I send you into that [$go]?");
        }
    }
    elsif ($text =~ /revamp/i) {
        my $dz = $client->GetExpedition();
        if ($dz && $dz->GetName() eq $name) {
            my $ready = quest::silent_saylink("ready");
            quest::say("You are already bound to that expedition. When you are [$ready], proceed into the portal.");
            return;
        }
        my $lock = quest::get_expedition_lockout_by_char_id($client->CharacterID(), $name, "Ring of Fear");
        if ($lock && $lock->{remaining}) {
            my $mins = int($lock->{remaining} / 60);
            quest::say("The avatar of fear still grips this memory. Return in roughly " . int($mins / 60) . " hours.");
            return;
        }
        my $count = 1;
        my $group = $client->GetGroup();
        if ($group) {
            $count = $group->GroupCount();
        }
        if ($count > $max_players) {
            quest::say("Too many of you wish to walk this path. I can only guide " . $max_players . " at a time.");
            return;
        }
        if ($count < $min_players) {
            quest::say("You will need at least " . $min_players . " to survive.");
            return;
        }
        my $created = $client->CreateExpedition($zone_short, $version, $duration, $name, $count, $count);
        if ($created) {
            $created->SetCompass($zone_short, $npc->GetX(), $npc->GetY(), $npc->GetZ());
            $created->SetSafeReturn($zone_short, $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
            my $ready = quest::silent_saylink("ready");
            quest::say("The temple of old is ready. When your group is [$ready], step forward and you will be sent in.");
        } else {
            $client->Message(13, "The expedition could not be created. Please make sure every group member is in Cazic Thule with you.");
        }
    }
    elsif ($text =~ /ready/i) {
        my $dz = $client->GetExpedition();
        if ($dz && $dz->GetName() eq $name) {
            my $x = quest::GetZoneSafeX($dz->GetZoneID());
            my $y = quest::GetZoneSafeY($dz->GetZoneID());
            my $z = quest::GetZoneSafeZ($dz->GetZoneID());
            my $h = quest::GetZoneSafeHeading($dz->GetZoneID());
            $client->MovePCInstance($dz->GetZoneID(), $dz->GetInstanceID(), $x, $y, $z, $h);
        }
    }
}

sub EVENT_SPAWN {
    if ($instanceversion > 0) {
        quest::depop();
    }
}
