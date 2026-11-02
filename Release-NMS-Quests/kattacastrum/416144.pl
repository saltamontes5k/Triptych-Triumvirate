#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - #Arcanist_Variszh (416144)
# Task: Library Heist (620132) -> Cracked Urn Handle. He cannot enter the
# Castrum library himself; the four volumes sit on the shelves as ground
# spawns near the shissar wardens.
#--------------------------------------------------------------------------
my %tasks = (
  620132 => ['library', 'A [library] heist, then. Four volumes sit on the shelves past the wardens: the Tome of Tsaph\'s Line, the Ledger, the Warden Records, and the Foundry Notes. Bring them out and I will finally see the old doctrine.'],
);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(620132)) {
      quest::say("The doctrine is mine to read now, $name. The wardens still do not know whose fingers were in their stacks.");
    } elsif (quest::istaskactive(620132)) {
      if (plugin::check_hasitem($client, 9910023) && plugin::check_hasitem($client, 9910024)
          && plugin::check_hasitem($client, 9910025) && plugin::check_hasitem($client, 9910026)) {
        quest::say("You have all four! The wardens will notice soon -- bring them here.");
      } else {
        quest::say("Four volumes, $name. Past the wardens, on the shelves. Do not let them port you out mid-heist.");
      }
    } else {
      quest::say($tasks{620132}[1]);
    }
    return;
  }
  if ($text=~/library/i) {
    if (quest::istaskcompleted(620132)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive(620132)) {
      quest::say("The volumes, $name. The wardens rotate on the quarter hour.");
    } else {
      quest::assigntask(620132);
      quest::say("Light fingers, quick feet. Go.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
