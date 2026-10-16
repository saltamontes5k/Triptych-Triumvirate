# Selana - Crescent Reach (the potters' wheel)
# The Serpent's Spine :: clay supply (task 600573)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Clay, clay, and more [clay] - the wheel eats it faster than the miners dig it. Bring me blocks and I will keep the wheel turning.");
    my @chain = (600573);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600573 && quest::istaskactive(600573)) { quest::say("Four blocks of clay. The wheel turns slow."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600573 && !quest::istaskcompleted(600573) && !quest::istaskactive(600573)) { quest::say("Four [blocks] - Small Blocks of Clay, from the merchants or the mud of the moors."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Good clay, well kept. The wheel thanks you."); }
  }
  if ($text=~/clay/i) {
    if (!quest::istaskactive(600573) && !quest::istaskcompleted(600573)) {
      quest::say("Four Small Blocks of Clay. The wheel waits.");
      quest::assigntask(600573);
    }
    elsif (quest::istaskactive(600573)) { quest::say("Four blocks of clay. The wheel turns slow."); }
    else { quest::say("Good clay, well kept. The wheel thanks you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600573)) { plugin::check_handin(\%itemcount, 16900 => 4); }
  plugin::return_items(\%itemcount);
}
