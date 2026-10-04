# A_Dust_Covered_Wayfarer.pl - LDoN Community Unlock Event (Guild Lobby)
# Adapted for Triptych/EQS from Ascendant-Server
#   (server/quests/guildlobby/A_Dust_Covered_Wayfarer.pl).
#
# Players turn in Lost Dungeon relics to unlock the LDoN content flag.
# 250 relics required; milestone world emotes every 50 turn-ins.
#
# Local adaptation:
#   * The Ascendant relic item 9544 collides with a live PEQ item, so this NPC
#     accepts the local LDoN spore tokens (items 56977-56991) instead.
#   * The Ascendant version rewrote zone.min_status/expansion for expansion 6;
#     that is removed here because EQS gates LDoN through NMS_progression_utils
#     stages, not the zone table.

use strict;
use warnings;

our ($client, $npc, %itemcount);

my $UNLOCK_COUNT = 250;
my $DATA_KEY     = "ldon_relic_count";
my @RELIC_IDS    = (56977 .. 56991);

sub EVENT_SAY {
    my $text = plugin::val('$text');

    if ($text =~ /hail/i) {
        if (quest::is_content_flag_enabled("ldon")) {
            plugin::Whisper("I have done everything I can. The way is open now. Seek out adventurers in the frontier towns... they will know what to do.");
        } else {
            plugin::Whisper("The old seals are weakening... forgotten passages beneath Norrath stir with ancient power. Fragments of expedition sigils have been found scattered across the world. If enough " . quest::saylink("recovered fragments") . " could be gathered, the way might finally be revealed...");
        }
    }
    elsif ($text =~ /recovered fragments/i) {
        if (quest::is_content_flag_enabled("ldon")) {
            plugin::Whisper("The fragments served their purpose. I have done what I can. Speak with those who dwell near the old places.");
        } else {
            my $count = int(quest::get_data($DATA_KEY) || 0);
            plugin::Whisper("Dungeon relics... remnants of ancient expeditions, buried in the corpses of creatures across every corner of Norrath. The Brotherhood needs $UNLOCK_COUNT of them to shatter the final seal.");
            plugin::Whisper("So far, $count of $UNLOCK_COUNT relics have been recovered. Bring any you find to me.");
        }
    }
}

sub EVENT_ITEM {
    my $relic_id;
    foreach my $id (keys %itemcount) {
        next unless $id && $id > 0;
        if (grep { $_ == $id } @RELIC_IDS) { $relic_id = $id; last; }
    }

    if ($relic_id && plugin::check_handin(\%itemcount, $relic_id => 1)) {
        if (quest::is_content_flag_enabled("ldon")) {
            plugin::Whisper("The seals are already broken. This relic holds no more power. Take it back, friend.");
            plugin::return_items(\%itemcount);
            return;
        }

        my $count = int(quest::get_data($DATA_KEY) || 0);
        $count++;
        quest::set_data($DATA_KEY, $count);

        if ($count >= $UNLOCK_COUNT) {
            quest::set_content_flag("ldon", 1);
            plugin::Whisper("This is it... the final relic. The seal shatters!");
            quest::we(15, "The earth trembles as ancient seals shatter across the land. Forgotten passages stir beneath Norrath... something long buried has been laid bare.");
        }
        elsif ($count % 50 == 0) {
            plugin::Whisper("Another relic recovered. $count of $UNLOCK_COUNT now. The seals weaken further...");

            if ($count == 50) {
                quest::we(15, "A faint tremor echoes from beneath the earth... ancient passages shift.");
            }
            elsif ($count == 100) {
                quest::we(15, "The seals weaken further... whispers of forgotten expeditions grow louder across the land.");
            }
            elsif ($count == 150) {
                quest::we(15, "Cracks form in the ancient barriers... something stirs in the deep places of Norrath.");
            }
            elsif ($count == 200) {
                quest::we(15, "The old pathways are becoming clear... the Brotherhood senses the end is near.");
            }
        }
        else {
            plugin::Whisper("Well done. That makes $count of $UNLOCK_COUNT relics recovered. The seals grow weaker with each one.");
        }
    } else {
        plugin::Whisper("I have no use for that. I seek only dungeon relics.");
        plugin::return_items(\%itemcount);
    }
}

return 1;
