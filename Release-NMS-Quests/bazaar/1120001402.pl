# 1120001402 - Kashekim (Discord Key) - Bazaar v0
# Reports GoD / OoW unlock status using the canonical plugin::list_stage_prereq.
# GoD (Gates of Discord) and OoW (Omens of War) stages; each objective is checked
# via plugin::GetSubflag so the player sees per-gate completion.

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::ConvertFlags($client);

        plugin::NPCTell("I am Kashekim, keeper of the Discord records. Your progress against the gates of Discord and the Omens of War is as follows:");

        plugin::list_stage_prereq($client, 'GoD');
        plugin::list_stage_prereq($client, 'OoW');
        return;
    }
}
