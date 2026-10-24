# Kregnad - Icefall Glacier
# The Serpent's Spine :: Kregnad's Supplies (600717 bear, 600718 leopard, 600719 mammoth)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600717) && !quest::istaskactive(600717)) {
      quest::say("Kregnad [" . quest::saylink("get some") . "], yes. Meat for the Coldeye.");
    }
    elsif (!quest::istaskcompleted(600718) && !quest::istaskactive(600718)) {
      quest::say("The [" . quest::saylink("cats") . "] of the ice taste better than they look.");
    }
    elsif (!quest::istaskcompleted(600719) && !quest::istaskactive(600719)) {
      quest::say("[" . quest::saylink("Mammoth") . "] meat. Kregnad is hungry just thinking of it.");
    }
    else {
      quest::say("Kregnad is fat and happy. You did that.");
    }
  }
  if ($text=~/get some/i && !quest::istaskactive(600717) && !quest::istaskcompleted(600717)) {
    quest::say("Four cuts of bear meat. Kregnad will owe you.");
    quest::assigntask(600717);
  }
  if ($text=~/cats/i && !quest::istaskactive(600718) && !quest::istaskcompleted(600718)) {
    quest::say("Four cuts of leopard meat. The snow leopards, not the tame ones.");
    quest::assigntask(600718);
  }
  if ($text=~/mammoth/i && !quest::istaskactive(600719) && !quest::istaskcompleted(600719)) {
    quest::say("Four cuts of mammoth meat. Kregnad shares the brew when it is done.");
    quest::assigntask(600719);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
