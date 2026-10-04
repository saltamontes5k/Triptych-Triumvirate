# Kilven the Quartermaster - General Supplies (Guild Lobby)
# Ported from Ascendant-Server (server/quests/guildlobby/Kilven_the_Quartermaster.pl).
# Merchant inventory comes from npc_types.merchant_id = 442009 (general supplies).

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::Whisper("Greetings, $name. I am Kilven, quartermaster of this hall. I maintain supplies for adventurers. Browse my wares if you need provisions.");
    }
}

1;
