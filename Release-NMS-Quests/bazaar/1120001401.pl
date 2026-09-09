# 1120001401 - Wandering Adventure (DoN LDoN Key) - Bazaar v0
# DoN / LDoN keying status. Reports whether the account has slain the five elemental gods
# (Xegony, Agnarr, Fennin Ro, the Rathe Council, Coirnav) whose fall keys the Dragons of
# Norrath and, with it, the LDoN raids on this server.
#
# Each elemental-god kill spawns a memory NPC (global/26000.pl); hailing it records the
# DoN subflag via plugin::SetSubflag. This NPC reads those same subflags with
# plugin::GetSubflag so players can review their keying progress per god.
#
# Flow mirrors bazaar/A_Lost_Iksar.pl (the Kunark expansion-flag helper): hail ->
# plugin::ConvertFlags -> stage-complete shortcut -> per-item status list.

my $stage_key = 'DoN';

my @gods = (
    ['xegony',                        'Xegony, the Queen of Air'],
    ['agnarr the storm lord',         'Agnarr, the Storm Lord'],
    ['fennin ro the tyrant of fire',  'Fennin Ro, the Tyrant of Fire'],
    ['rathe council',                 'The Rathe Council'],
    ['coirnav the avatar of water',   'Coirnav, the Avatar of Water'],
);

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::ConvertFlags($client);

        plugin::NPCTell("Greetings, $name. I wander the roads of Norrath recording the deeds of heroes. Before the way to the Dragons of Norrath opens, you must prove yourself against all five elemental gods.");

        my $slain = 0;
        foreach my $god (@gods) {
            my ($key, $display) = @$god;
            if (plugin::GetSubflag($client, $stage_key, $key)) {
                plugin::YellowText("You have proven yourself against $display.");
                $slain++;
            } else {
                plugin::YellowText("You have yet to face $display.");
            }
        }

        if (plugin::is_stage_complete($client, $stage_key)) {
            plugin::YellowText("You have access to the Dragons of Norrath. The raids of LDoN are open to you.");
        } elsif ($slain == scalar(@gods)) {
            plugin::NPCTell("Your deeds are recorded, yet the way remains barred for now. Return when the time-lock has lifted.");
        } else {
            plugin::NPCTell("Slay each of the elemental gods in their elemental homes. When one falls, hail the apparition it leaves behind so that I may record the deed.");
        }
        return;
    }
}
