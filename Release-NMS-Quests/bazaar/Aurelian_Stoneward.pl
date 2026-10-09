# Aurelian Stoneward - Era Completion & Charm Upgrade (Guild Lobby)
# Adapted for Triptych/EQS from Ascendant-Server
#   (server/quests/guildlobby/Aurelian_Stoneward.pl)
#
# Charm progression: First -> Second -> Third -> Fourth -> Fifth
#   121850 -> 121851 -> 121852 -> 121853 -> 121854
#
# Era completion is sourced from NMS_progression_utils.pl. That plugin's stage
# names are offset from the era they actually unlock, so the mapping is:
#   'RoK' complete = Classic bosses  (Lord Nagafen, Lady Vox)
#   'SoV' complete = Kunark bosses
#   'SoL' complete = Velious bosses
#   'PoP' complete = Luclin bosses
#   'DoN' complete = Planes of Power elemental gods
#
# Titles granted (Ascendant IDs): 398/399/400 Classic, 401/402 Kunark,
# 411 Velious, 419 Luclin, 421 Planes of Power.

use strict;
use warnings;

our ($client, $npc, $text, %itemcount, $popupid);

my $FIRST_AGE  = 121850;
my $SECOND_AGE = 121851;
my $THIRD_AGE  = 121852;
my $FOURTH_AGE = 121853;
my $FIFTH_AGE  = 121854;
my @CHARM_IDS  = ($FIRST_AGE, $SECOND_AGE, $THIRD_AGE, $FOURTH_AGE, $FIFTH_AGE);

sub era_complete {
    my ($stage) = @_;
    return plugin::is_stage_complete($client, $stage) ? 1 : 0;
}
sub classic_complete { return era_complete('RoK'); }    # Classic kills unlock Kunark
sub kunark_complete  { return era_complete('SoV'); }    # Kunark kills unlock Velious
sub velious_complete { return era_complete('SoL'); }    # Velious kills unlock Luclin
sub luclin_complete  { return era_complete('PoP'); }    # Luclin kills unlock PoP
sub pop_complete     { return era_complete('DoN'); }    # PoP elementals unlock DoN/LDoN

sub awarded { my ($key) = @_; return quest::get_data($key . '_' . $client->CharacterID()); }

sub EVENT_SAY {
    my $name = $client->GetCleanName();

    if ($text =~ /hail/i) {
        my $classic_link = quest::saylink("classic", 1, "Classic");
        my $kunark_link  = quest::saylink("kunark",  1, "Kunark");
        my $velious_link = quest::saylink("velious", 1, "Velious");
        my $luclin_link  = quest::saylink("luclin",  1, "Luclin");
        my $pop_link     = quest::saylink("pop",     1, "Planes of Power");

        plugin::Whisper("Greetings, $name. I am Aurelian Stoneward, keeper of legendary achievements. I can help you claim rewards for completing $classic_link, $kunark_link, $velious_link, $luclin_link, or $pop_link content.");

        if (classic_complete() && !awarded('classic_awarded')) {
            plugin::Whisper("I see you have completed the Classic era! You have rewards waiting.");
        }
        if (kunark_complete() && !awarded('kunark_awarded')) {
            plugin::Whisper("I see you have completed the Kunark era! You have rewards waiting.");
        }
        if (velious_complete() && !awarded('velious_awarded')) {
            plugin::Whisper("I see you have completed the Velious era! You have rewards waiting.");
        }
        if (luclin_complete() && !awarded('luclin_awarded')) {
            plugin::Whisper("I see you have completed the Luclin era! You have rewards waiting.");
        }
        if (pop_complete() && !awarded('pop_awarded')) {
            plugin::Whisper("I see you have completed the Planes of Power era! You have rewards waiting.");
        }
    }
    elsif ($text =~ /classic/i) { handle_classic(); }
    elsif ($text =~ /kunark/i)  { handle_kunark(); }
    elsif ($text =~ /velious/i) { handle_velious(); }
    elsif ($text =~ /luclin/i)  { handle_luclin(); }
    elsif ($text =~ /pop/i)     { handle_pop(); }
}

sub era_status_line {
    my ($done) = @_;
    return $done ? "<c \"#00FF00\">DEFEATED</c>" : "<c \"#FF0000\">Not Defeated</c>";
}

sub handle_classic {
    my $id       = $client->CharacterID();
    my $complete = classic_complete();
    my $already  = awarded('classic_awarded');

    my $text = "<c \"#FFD700\"><b>Classic Era Completion Status</b></c><br><br>"
             . "<c \"#FFFFFF\">To complete the Classic era, you must defeat both ancient dragons:</c><br><br>"
             . "<c \"#00FFFF\">Lord Nagafen</c> (Solusek's Eye)<br>"
             . "<c \"#00FFFF\">Lady Vox</c> (Permafrost)<br><br>"
             . "<c \"#FFFFFF\">Era status:</c> " . era_status_line($complete) . "<br><br>";

    if ($already) {
        $client->Popup2("Classic Era Status", $text . "<c \"#FFFFFF\">You have already claimed your Classic rewards on this character!</c>", 0, 0, 0, 0);
    }
    elsif ($complete) {
        $text .= "<c \"#00FF00\"><b>Congratulations!</b></c><br>You have defeated both ancient dragons!<br><br>"
               . "<c \"#FFD700\">Rewards:</c><br>&bull; Charm of the First Age<br>&bull; Three new titles<br><br>"
               . "<c \"#FFFFFF\">Click OK to claim your rewards!</c>";
        $client->Popup2("Classic Era Completion", $text, 5001, 5002, 2, 0, "Claim Rewards", "Cancel");
    }
    else {
        $client->Popup2("Classic Era Completion", $text . "<c \"#FF9900\">You must defeat both dragons to complete the Classic era.</c><br>Return to me when you have accomplished this feat!", 0, 0, 0, 0);
    }
}

sub handle_kunark {
    my $complete = kunark_complete();
    my $already  = awarded('kunark_awarded');

    my $text = "<c \"#FFD700\"><b>Kunark Era Completion Status</b></c><br><br>"
             . "<c \"#FFFFFF\">To complete the Kunark era, you must defeat the ancient dragons of Kunark:</c><br><br>"
             . "<c \"#00FFFF\">Talendor</c>, <c \"#00FFFF\">Severilous</c>, <c \"#00FFFF\">Trakanon</c> and <c \"#00FFFF\">Gorenaire</c><br><br>"
             . "<c \"#FFFFFF\">Era status:</c> " . era_status_line($complete) . "<br><br>";

    if ($already) {
        $client->Popup2("Kunark Era Status", $text . "<c \"#FFFFFF\">You have already claimed your Kunark rewards on this character!</c>", 0, 0, 0, 0);
    }
    elsif ($complete) {
        $text .= "<c \"#00FF00\"><b>Congratulations!</b></c><br>You have defeated the dragons of Kunark!<br><br>"
               . "<c \"#FFD700\">Rewards:</c><br>&bull; Two new titles<br><br>"
               . "<c \"#FFAA00\">After claiming, hand me your Charm of the First Age to upgrade it to the Charm of the Second Age!</c><br><br>"
               . "<c \"#FFFFFF\">Click OK to claim your rewards!</c>";
        $client->Popup2("Kunark Era Completion", $text, 5003, 5004, 2, 0, "Claim Rewards", "Cancel");
    }
    else {
        $client->Popup2("Kunark Era Completion", $text . "<c \"#FF9900\">You must defeat the dragons of Kunark to complete this era.</c><br>Return to me when you have accomplished this feat!", 0, 0, 0, 0);
    }
}

sub handle_velious {
    my $complete = velious_complete();
    my $already  = awarded('velious_awarded');

    my $text = "<c \"#FFD700\"><b>Velious Era Completion Status</b></c><br><br>"
             . "<c \"#FFFFFF\">To complete the Velious era, you must defeat its great wardens:</c><br><br>"
             . "<c \"#00FFFF\">Wuoshi</c>, <c \"#00FFFF\">Kelorek`Dar</c>, <c \"#00FFFF\">Klandicar</c>, <c \"#00FFFF\">Zlandicar</c> and <c \"#00FFFF\">Dozekar the Cursed</c><br><br>"
             . "<c \"#FFFFFF\">Era status:</c> " . era_status_line($complete) . "<br><br>";

    if ($already) {
        $client->Popup2("Velious Era Status", $text . "<c \"#FFFFFF\">You have already claimed your Velious rewards on this character!</c>", 0, 0, 0, 0);
    }
    elsif ($complete) {
        $text .= "<c \"#00FF00\"><b>Congratulations!</b></c><br>You have conquered the frozen continent!<br><br>"
               . "<c \"#FFD700\">Rewards:</c><br>&bull; A new title<br><br>"
               . "<c \"#FFAA00\">After claiming, hand me your Charm of the Second Age to upgrade it to the Charm of the Third Age!</c><br><br>"
               . "<c \"#FFFFFF\">Click OK to claim your rewards!</c>";
        $client->Popup2("Velious Era Completion", $text, 5005, 5006, 2, 0, "Claim Rewards", "Cancel");
    }
    else {
        $client->Popup2("Velious Era Completion", $text . "<c \"#FF9900\">You must defeat all of the Velious bosses to complete this era.</c><br>Return to me when you have accomplished this feat!", 0, 0, 0, 0);
    }
}

sub handle_luclin {
    my $complete = luclin_complete();
    my $already  = awarded('luclin_awarded');

    my $text = "<c \"#FFD700\"><b>Luclin Era Completion Status</b></c><br><br>"
             . "<c \"#FFFFFF\">To complete the Luclin era, you must defeat the powers of the moon:</c><br><br>"
             . "<c \"#00FFFF\">Grieg Veneficus</c>, <c \"#00FFFF\">Thought Horror Overfiend</c>, <c \"#00FFFF\">The Insanity Crawler</c>, <c \"#00FFFF\">Xerkizh the Creator</c> and <c \"#00FFFF\">Emperor Ssraeshza</c><br><br>"
             . "<c \"#FFFFFF\">Era status:</c> " . era_status_line($complete) . "<br><br>";

    if ($already) {
        $client->Popup2("Luclin Era Status", $text . "<c \"#FFFFFF\">You have already claimed your Luclin rewards on this character!</c>", 0, 0, 0, 0);
    }
    elsif ($complete) {
        $text .= "<c \"#00FF00\"><b>Congratulations!</b></c><br>You have mastered the shadows of Luclin!<br><br>"
               . "<c \"#FFD700\">Rewards:</c><br>&bull; A new title<br><br>"
               . "<c \"#FFAA00\">After claiming, hand me your Charm of the Third Age to upgrade it to the Charm of the Fourth Age!</c><br><br>"
               . "<c \"#FFFFFF\">Click OK to claim your rewards!</c>";
        $client->Popup2("Luclin Era Completion", $text, 5007, 5008, 2, 0, "Claim Rewards", "Cancel");
    }
    else {
        $client->Popup2("Luclin Era Completion", $text . "<c \"#FF9900\">You must defeat all of the Luclin bosses to complete this era.</c><br>Return to me when you have accomplished this feat!", 0, 0, 0, 0);
    }
}

sub handle_pop {
    my $complete = pop_complete();
    my $already  = awarded('pop_awarded');

    my $text = "<c \"#FFD700\"><b>Planes of Power Era Completion Status</b></c><br><br>"
             . "<c \"#FFFFFF\">To complete the Planes of Power era, you must cast down the elemental gods:</c><br><br>"
             . "<c \"#00FFFF\">Xegony</c>, <c \"#00FFFF\">Fennin Ro</c>, <c \"#00FFFF\">Coirnav</c>, <c \"#00FFFF\">Rathe Council</c> and <c \"#00FFFF\">Agnarr the Storm Lord</c><br><br>"
             . "<c \"#FFFFFF\">Era status:</c> " . era_status_line($complete) . "<br><br>";

    if ($already) {
        $client->Popup2("Planes of Power Era Status", $text . "<c \"#FFFFFF\">You have already claimed your Planes of Power rewards on this character!</c>", 0, 0, 0, 0);
    }
    elsif ($complete) {
        $text .= "<c \"#00FF00\"><b>Congratulations!</b></c><br>You have cast down the gods of the Planes of Power!<br><br>"
               . "<c \"#FFD700\">Rewards:</c><br>&bull; The title <c \"#FFD700\">the Godbreaker</c><br><br>"
               . "<c \"#FFAA00\">After claiming, hand me your Charm of the Fourth Age to upgrade it to the Charm of the Fifth Age!</c><br><br>"
               . "<c \"#FFFFFF\">Click OK to claim your rewards!</c>";
        $client->Popup2("Planes of Power Era Completion", $text, 5009, 5010, 2, 0, "Claim Rewards", "Cancel");
    }
    else {
        $client->Popup2("Planes of Power Era Completion", $text . "<c \"#FF9900\">You must defeat the elemental gods to complete this era.</c><br>Return to me when you have accomplished this feat!", 0, 0, 0, 0);
    }
}

sub EVENT_ITEM {
    my $name = $client->GetCleanName();

    # Reject charm turn-ins that still have augments installed.
    for my $slot (1 .. 4) {
        my $inst      = plugin::val("item${slot}_inst");
        next unless $inst;
        my $traded_id = plugin::val("item${slot}");
        next unless $traded_id && grep { $_ == $traded_id } @CHARM_IDS;
        for my $aug (0 .. 5) {
            if ($inst->GetAugmentItemID($aug) && $inst->GetAugmentItemID($aug) > 0) {
                plugin::Whisper("I cannot accept a charm that has augments in it! Please remove all augments before handing me the charm.");
                $client->SummonItem($traded_id);
                return;
            }
        }
    }

    my %next = (
        $FIRST_AGE  => $SECOND_AGE,
        $SECOND_AGE => $THIRD_AGE,
        $THIRD_AGE  => $FOURTH_AGE,
        $FOURTH_AGE => $FIFTH_AGE,
    );
    my %need = (
        $FOURTH_AGE => 'pop_awarded',
        $THIRD_AGE  => 'luclin_awarded',
        $SECOND_AGE => 'velious_awarded',
        $FIRST_AGE  => 'kunark_awarded',
    );
    my %msg = (
        $SECOND_AGE => "Your charm has been upgraded! This enhanced Charm of the Second Age reflects your mastery over the Kunark dragons.",
        $THIRD_AGE  => "Your charm has been upgraded! This mighty Charm of the Third Age reflects your mastery over the frozen continent.",
        $FOURTH_AGE => "Your charm has been upgraded! This legendary Charm of the Fourth Age reflects your mastery over the shadows of Luclin.",
        $FIFTH_AGE  => "Your charm has been upgraded! This transcendent Charm of the Fifth Age reflects your conquest of the Planes of Power.",
    );
    my %target_name = (
        $SECOND_AGE => "Charm of the Second Age",
        $THIRD_AGE  => "Charm of the Third Age",
        $FOURTH_AGE => "Charm of the Fourth Age",
        $FIFTH_AGE  => "Charm of the Fifth Age",
    );

    my $source;
    foreach my $c (@CHARM_IDS) {
        if ($itemcount{$c}) { $source = $c; last; }
    }

    unless ($source) {
        plugin::return_items(\%itemcount);
        return;
    }

    my $target = $next{$source};
    unless (quest::getitemstat($target, 'id')) {
        plugin::Whisper("The next charm is not loaded in the world item data. An administrator must rebuild shared memory (#hotfix items). Returning your charm.");
        plugin::return_items(\%itemcount);
        return;
    }

    unless (plugin::check_handin(\%itemcount, $source => 1)) {
        plugin::return_items(\%itemcount);
        return;
    }

    if (awarded($need{$source})) {
        $client->SummonItem($target);
        plugin::Whisper($msg{$target});
        $client->Message(15, "You received: $target_name{$target}");
    } else {
        plugin::Whisper("You have not yet claimed the era required for that upgrade. Please click 'Claim Rewards' in my menu first, then hand me the charm.");
        $client->SummonItem($source);
    }
}

sub EVENT_POPUPRESPONSE {
    my $id   = $client->CharacterID();
    my $name = $client->GetCleanName();

    if ($popupid == 5001) {
        if (awarded('classic_awarded')) {
            plugin::Whisper("You have already claimed your Classic rewards!");
            return;
        }
        if (classic_complete()) {
            unless (quest::getitemstat($FIRST_AGE, 'id')) {
                plugin::Whisper("The Charm of the First Age is not loaded in the world item data. An administrator must rebuild shared memory (#hotfix items). Your claim was NOT recorded.");
                return;
            }
            $client->SummonItem($FIRST_AGE);
            quest::enabletitle(398);
            quest::enabletitle(399);
            quest::enabletitle(400);
            quest::set_data("classic_awarded_" . $id, $client->GetCleanName());
            quest::we(15, $client->GetCleanName() . " has claimed their Classic era rewards for defeating Lord Nagafen and Lady Vox! Congratulations, champion!");
            $client->Message(15, "You received the Charm of the First Age and unlocked three new titles!");
            plugin::Whisper("Congratulations, $name! Your Classic era achievements have been rewarded. Wear them with pride!");
        } else {
            plugin::Whisper("I cannot grant you the rewards. You must defeat both Lord Nagafen and Lady Vox first.");
        }
    }
    elsif ($popupid == 5002) { plugin::Whisper("Very well. Return when you are ready to claim your rewards."); }
    elsif ($popupid == 5003) {
        if (awarded('kunark_awarded')) {
            plugin::Whisper("You have already claimed your Kunark rewards!");
            return;
        }
        if (kunark_complete()) {
            quest::enabletitle(401);
            quest::enabletitle(402);
            quest::set_data("kunark_awarded_" . $id, $client->GetCleanName());
            quest::we(15, $client->GetCleanName() . " has claimed their Kunark era rewards! Congratulations, champion!");
            $client->Message(15, "You unlocked two new titles!");
            plugin::Whisper("Congratulations, $name! Your Kunark era achievements have been rewarded. Now hand me your Charm of the First Age and I will upgrade it to the Charm of the Second Age!");
        } else {
            plugin::Whisper("I cannot grant you the rewards. You must defeat the dragons of Kunark first.");
        }
    }
    elsif ($popupid == 5004) { plugin::Whisper("Very well. Return when you are ready to claim your rewards."); }
    elsif ($popupid == 5005) {
        if (awarded('velious_awarded')) {
            plugin::Whisper("You have already claimed your Velious rewards!");
            return;
        }
        if (velious_complete()) {
            quest::enabletitle(411);
            quest::set_data("velious_awarded_" . $id, $client->GetCleanName());
            quest::we(15, $client->GetCleanName() . " has claimed their Velious era rewards for conquering the frozen continent! Congratulations, champion!");
            $client->Message(15, "You unlocked a new title!");
            plugin::Whisper("Congratulations, $name! Your Velious era achievements have been rewarded. Now hand me your Charm of the Second Age and I will upgrade it to the Charm of the Third Age!");
        } else {
            plugin::Whisper("I cannot grant you the rewards. You must defeat all of the Velious bosses first.");
        }
    }
    elsif ($popupid == 5006) { plugin::Whisper("Very well. Return when you are ready to claim your rewards."); }
    elsif ($popupid == 5007) {
        if (awarded('luclin_awarded')) {
            plugin::Whisper("You have already claimed your Luclin rewards!");
            return;
        }
        if (luclin_complete()) {
            quest::enabletitle(419);
            quest::set_data("luclin_awarded_" . $id, $client->GetCleanName());
            quest::we(15, $client->GetCleanName() . " has claimed their Luclin era rewards for conquering the shadows of Luclin! Congratulations, champion!");
            $client->Message(15, "You unlocked a new title!");
            plugin::Whisper("Congratulations, $name! Your Luclin era achievements have been rewarded. Now hand me your Charm of the Third Age and I will upgrade it to the Charm of the Fourth Age!");
        } else {
            plugin::Whisper("I cannot grant you the rewards. You must defeat all of the Luclin bosses first.");
        }
    }
    elsif ($popupid == 5008) { plugin::Whisper("Very well. Return when you are ready to claim your rewards."); }
    elsif ($popupid == 5009) {
        if (awarded('pop_awarded')) {
            plugin::Whisper("You have already claimed your Planes of Power rewards!");
            return;
        }
        if (pop_complete()) {
            quest::enabletitle(421);
            quest::set_data("pop_awarded_" . $id, $client->GetCleanName());
            quest::we(15, $client->GetCleanName() . " has cast down the gods of the Planes of Power and earned the title of Godbreaker! Congratulations, champion!");
            $client->Message(15, "You unlocked the title 'the Godbreaker'!");
            plugin::Whisper("Congratulations, $name! You have proven yourself a Godbreaker. Now hand me your Charm of the Fourth Age and I will upgrade it to the Charm of the Fifth Age!");
        } else {
            plugin::Whisper("I cannot grant you the rewards. You must defeat the elemental gods of the Planes of Power first.");
        }
    }
    elsif ($popupid == 5010) { plugin::Whisper("Very well. Return when you are ready to claim your rewards."); }
}

1;
