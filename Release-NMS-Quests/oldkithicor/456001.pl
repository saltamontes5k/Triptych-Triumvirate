# Herald Silla (456001) -- the war's herald behind the Bloody Kithicor
# rift. Every quest in the theme raises her faction (raspersrealm
# themeKithicor); she recites the player's Seeds of Destruction standings
# and offers the Kithicor theme tasks (Blood of the Fallen pieces) plus the
# Timeshear missions. The task chooser caps at 40 entries, so the two sets
# are offered under separate keywords.
my @KITHICOR_TASKS = (
    303074, 303075, 303076, 303120, 303121, 303122, 303123, 303124, 303125,
    303126, 303130, 303131, 303132, 303133, 303134, 303135, 303141, 303142,
    303143, 303144, 303145, 303146,
);

my @TIMESHEAR_TASKS = (
    303002, 303003, 303005, 303011, 303012, 303020, 303021, 303022, 303023,
    303024, 303036, 303040, 303041, 303048, 303049, 303050, 303051, 303071,
    303072, 303073, 303077, 303080, 303081, 303160, 303161, 303162,
);

sub EVENT_SAY {
    if ($text =~ /hail|progress/i) {
        quest::say("The woods bleed across times not their own. Every blow struck for either army mends the tear. Your standings:");
        plugin::SodReport($client);
    }
    elsif ($text =~ /kithicor|theme|war/i) {
        quest::say("These are the duties of the war I can entrust to you, " . $client->GetCleanName() . ".");
        quest::taskselector(\@KITHICOR_TASKS);
    }
    elsif ($text =~ /timeshear|shear/i) {
        quest::say("The Timeshear missions span every age of this war, " . $client->GetCleanName() . ".");
        quest::taskselector(\@TIMESHEAR_TASKS);
    }
    elsif ($text =~ /task|work|offer|jobs/i) {
        quest::say("Ask me about the [Kithicor] theme duties, or the [Timeshear] missions.");
    }
}
