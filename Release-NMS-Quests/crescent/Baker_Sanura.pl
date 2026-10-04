sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600532,600533,600534,600535);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600532 && quest::istaskactive(600532)) { quest::say("A Simple Muffin. The rush is coming."); $talked = 1; last; }
      if ($tsk == 600533 && quest::istaskactive(600533)) { quest::say("A Simple Oatmeal. The pot is thin."); $talked = 1; last; }
      if ($tsk == 600534 && quest::istaskactive(600534)) { quest::say("A Simple Pie. The board is bare."); $talked = 1; last; }
      if ($tsk == 600535 && quest::istaskactive(600535)) { quest::say("A Simple Pastry. Roll it thin."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600532 && !quest::istaskcompleted(600532) && !quest::istaskactive(600532)) { quest::say("A [muffin] - a Simple Muffin, baked light."); $talked = 1; last; }
        if ($tsk == 600533 && !quest::istaskcompleted(600533) && !quest::istaskactive(600533)) { quest::say("A pot of [oatmeal] - a Simple Oatmeal for the watch breakfast."); $talked = 1; last; }
        if ($tsk == 600534 && !quest::istaskcompleted(600534) && !quest::istaskactive(600534)) { quest::say("A [pie] - a Simple Pie for the festival board."); $talked = 1; last; }
        if ($tsk == 600535 && !quest::istaskcompleted(600535) && !quest::istaskactive(600535)) { quest::say("And a [pastry] - a Simple Pastry, rolled fine."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The ovens thank you. Sanura will set aside something sweet."); }
  }
  if ($text=~/muffin/i) {
    if (!quest::istaskactive(600532) && !quest::istaskcompleted(600532)) {
      quest::say("Bake a Simple Muffin. The morning rush waits.");
      quest::assigntask(600532);
    }
    elsif (quest::istaskactive(600532)) { quest::say("A Simple Muffin. The rush is coming."); }
    else { quest::say("The ovens thank you. Sanura will set aside something sweet."); }
  }
  if ($text=~/oatmeal/i) {
    if (!quest::istaskactive(600533) && !quest::istaskcompleted(600533)) {
      quest::say("Cook a Simple Oatmeal.");
      quest::assigntask(600533);
    }
    elsif (quest::istaskactive(600533)) { quest::say("A Simple Oatmeal. The pot is thin."); }
    else { quest::say("The ovens thank you. Sanura will set aside something sweet."); }
  }
  if ($text=~/pie/i) {
    if (!quest::istaskactive(600534) && !quest::istaskcompleted(600534)) {
      quest::say("Bake a Simple Pie.");
      quest::assigntask(600534);
    }
    elsif (quest::istaskactive(600534)) { quest::say("A Simple Pie. The board is bare."); }
    else { quest::say("The ovens thank you. Sanura will set aside something sweet."); }
  }
  if ($text=~/pastry/i) {
    if (!quest::istaskactive(600535) && !quest::istaskcompleted(600535)) {
      quest::say("Roll a Simple Pastry.");
      quest::assigntask(600535);
    }
    elsif (quest::istaskactive(600535)) { quest::say("A Simple Pastry. Roll it thin."); }
    else { quest::say("The ovens thank you. Sanura will set aside something sweet."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600532)) { plugin::check_handin(\%itemcount, 98277 => 1); }
  if (quest::istaskactive(600533)) { plugin::check_handin(\%itemcount, 98260 => 1); }
  if (quest::istaskactive(600534)) { plugin::check_handin(\%itemcount, 98281 => 1); }
  if (quest::istaskactive(600535)) { plugin::check_handin(\%itemcount, 98280 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
