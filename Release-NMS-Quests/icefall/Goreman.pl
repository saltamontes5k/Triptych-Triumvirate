# Goreman - Icefall Glacier
# The Serpent's Spine :: Goreman's Supplies (600704 bear, 600705 leopard, 600706 mammoth)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600704) && !quest::istaskactive(600704)) {
      quest::say("I [" . quest::saylink("get some") . "] for the pot, if you are hunting.");
    }
    elsif (!quest::istaskcompleted(600705) && !quest::istaskactive(600705)) {
      quest::say("The [" . quest::saylink("leopards") . "] run lean but their meat is sweet.");
    }
    elsif (!quest::istaskcompleted(600706) && !quest::istaskactive(600706)) {
      quest::say("Nothing feeds the camp like [" . quest::saylink("mammoth") . "] meat.");
    }
    else {
      quest::say("The pot is full and the camp thanks you.");
    }
  }
  if ($text=~/get some/i && !quest::istaskactive(600704) && !quest::istaskcompleted(600704)) {
    quest::say("Bring me four cuts of bear meat. The caves east of the port are full of them.");
    quest::assigntask(600704);
  }
  if ($text=~/leopards/i && !quest::istaskactive(600705) && !quest::istaskcompleted(600705)) {
    quest::say("Four cuts of leopard meat. Mind your step on the ice.");
    quest::assigntask(600705);
  }
  if ($text=~/mammoth/i && !quest::istaskactive(600706) && !quest::istaskcompleted(600706)) {
    quest::say("Four cuts of mammoth meat. Bring them before the frost takes them.");
    quest::assigntask(600706);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
