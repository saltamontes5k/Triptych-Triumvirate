# Herald Silla (456001) -- the war's herald behind the Bloody Kithicor
# rift. Every quest in the theme raises her faction (raspersrealm
# themeKithicor); she recites the player's Seeds of Destruction standings.
sub EVENT_SAY {
    if ($text =~ /hail|progress/i) {
        quest::say("The woods bleed across times not their own. Every blow struck for either army mends the tear. Your standings:");
        plugin::SodReport($client);
    }
}
