#--------------------------------------------------------------------------
# TBS: Noble Sivrn - Jewel of Atiiki (#Noble_Sivrn 418049)
# Offers the sphinx arc (620070-620074) in order; after #5, grants the
# Platinum Efreeti Mask (79507) and the Efreeti Death Visage task (620075).
#--------------------------------------------------------------------------
my @arc = (620070, 620071, 620072, 620073, 620074);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(620074)) {
      if (!quest::istaskcompleted(620075)) {
        if (!quest::istaskactive(620075) && !plugin::check_hasitem($client, 79507)) {
          quest::say("You have solved every riddle but the last. Take this mask - it marks you as one of the efreeti. Assemble the Platinum Efreeti armor and the Token of Order, then speak with Noble Phren.");
          quest::summonitem(79507);
          quest::assigntask(620075);
        } else {
          quest::say("Speak with Noble Phren beside me. The board of order waits at Mahatototarit.");
        }
      } else {
        quest::say("The death visage is yours, $name. Walk carefully among the efreeti.");
      }
      return;
    }
    quest::say("I am Noble Sivrn. The sphinx set us puzzles that confound even the wise. Will you help us [study] them?");
    return;
  }

  if ($text=~/study|task|work|puzzle/i) {
    if (quest::istaskcompleted(620074)) {
      quest::say("You have done all I asked. Hail me again if you would face the final riddle.");
      return;
    }
    my $next = -1;
    for my $i (0 .. $#arc) {
      if (!quest::istaskcompleted($arc[$i])) { $next = $i; last; }
    }
    if ($next >= 0) {
      my $tid = $arc[$next];
      if (quest::istaskactive($tid)) {
        quest::say("You are already about it, $name. Finish what you started and return to me.");
      } else {
        quest::say("Then take this task. Walk among the efreeti and return when it is done.");
        quest::assigntask($tid);
      }
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
