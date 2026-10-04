sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600527,600528,600529,600530,600531);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600527 && quest::istaskactive(600527)) { quest::say("A Simple Arrow. The quivers are light."); $talked = 1; last; }
      if ($tsk == 600528 && quest::istaskactive(600528)) { quest::say("A Simple Arrow Shaft. Straight and true."); $talked = 1; last; }
      if ($tsk == 600529 && quest::istaskactive(600529)) { quest::say("A Simple Arrowhead. Sharp as you can make it."); $talked = 1; last; }
      if ($tsk == 600530 && quest::istaskactive(600530)) { quest::say("A Simple Bow. The watch wants more."); $talked = 1; last; }
      if ($tsk == 600531 && quest::istaskactive(600531)) { quest::say("A Simple Bow Staff. The stave rack is bare."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600527 && !quest::istaskcompleted(600527) && !quest::istaskactive(600527)) { quest::say("An [arrow] - a Simple Arrow, fletched clean."); $talked = 1; last; }
        if ($tsk == 600528 && !quest::istaskcompleted(600528) && !quest::istaskactive(600528)) { quest::say("A [shaft] first, if you like - a Simple Arrow Shaft."); $talked = 1; last; }
        if ($tsk == 600529 && !quest::istaskcompleted(600529) && !quest::istaskactive(600529)) { quest::say("And an [arrowhead] - a Simple Arrowhead, knapped sharp."); $talked = 1; last; }
        if ($tsk == 600530 && !quest::istaskcompleted(600530) && !quest::istaskactive(600530)) { quest::say("A [bow] itself - a Simple Bow, strung well."); $talked = 1; last; }
        if ($tsk == 600531 && !quest::istaskcompleted(600531) && !quest::istaskactive(600531)) { quest::say("And a [stave] - a Simple Bow Staff to back them all."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
  if ($text=~/arrow/i) {
    if (!quest::istaskactive(600527) && !quest::istaskcompleted(600527)) {
      quest::say("Fletch a Simple Arrow. The watch waits.");
      quest::assigntask(600527);
    }
    elsif (quest::istaskactive(600527)) { quest::say("A Simple Arrow. The quivers are light."); }
    else { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
  if ($text=~/shaft/i) {
    if (!quest::istaskactive(600528) && !quest::istaskcompleted(600528)) {
      quest::say("Carve a Simple Arrow Shaft.");
      quest::assigntask(600528);
    }
    elsif (quest::istaskactive(600528)) { quest::say("A Simple Arrow Shaft. Straight and true."); }
    else { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
  if ($text=~/arrowhead/i) {
    if (!quest::istaskactive(600529) && !quest::istaskcompleted(600529)) {
      quest::say("Knap a Simple Arrowhead.");
      quest::assigntask(600529);
    }
    elsif (quest::istaskactive(600529)) { quest::say("A Simple Arrowhead. Sharp as you can make it."); }
    else { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
  if ($text=~/bow/i) {
    if (!quest::istaskactive(600530) && !quest::istaskcompleted(600530)) {
      quest::say("String a Simple Bow.");
      quest::assigntask(600530);
    }
    elsif (quest::istaskactive(600530)) { quest::say("A Simple Bow. The watch wants more."); }
    else { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
  if ($text=~/stave/i) {
    if (!quest::istaskactive(600531) && !quest::istaskcompleted(600531)) {
      quest::say("Whittle a Simple Bow Staff.");
      quest::assigntask(600531);
    }
    elsif (quest::istaskactive(600531)) { quest::say("A Simple Bow Staff. The stave rack is bare."); }
    else { quest::say("The quiver thanks you. The benches rest a moment - a moment only."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600527)) { plugin::check_handin(\%itemcount, 98264 => 1); }
  if (quest::istaskactive(600528)) { plugin::check_handin(\%itemcount, 98265 => 1); }
  if (quest::istaskactive(600529)) { plugin::check_handin(\%itemcount, 98267 => 1); }
  if (quest::istaskactive(600530)) { plugin::check_handin(\%itemcount, 98270 => 1); }
  if (quest::istaskactive(600531)) { plugin::check_handin(\%itemcount, 98271 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
