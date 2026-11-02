# Gorbak - Icefall Glacier
# The Serpent's Spine :: Gorbak's Supplies (600713 claws, 600714 hides, 600715 tusks)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600713) && !quest::istaskactive(600713)) {
      quest::say("Gorbak [" . quest::saylink("I get stuff") . "] from hunters. You look like a hunter.");
    }
    elsif (!quest::istaskcompleted(600714) && !quest::istaskactive(600714)) {
      quest::say("The camp needs [" . quest::saylink("hides") . "]. Mammoths wear the best ones.");
    }
    elsif (!quest::istaskcompleted(600715) && !quest::istaskactive(600715)) {
      quest::say("Bring [" . quest::saylink("tusks") . "] and Gorbak will make the pot sing.");
    }
    else {
      quest::say("Coldeye camp eats well tonight. Gorbak remembers you.");
    }
  }
  if ($text=~/I get stuff/i && !quest::istaskactive(600713) && !quest::istaskcompleted(600713)) {
    quest::say("Ten bears, four claws. The caves east of the wizard port.");
    quest::assigntask(600713);
  }
  if ($text=~/hides/i && !quest::istaskactive(600714) && !quest::istaskcompleted(600714)) {
    quest::say("Four mammoth hides. Do not freeze before you return.");
    quest::assigntask(600714);
  }
  if ($text=~/tusks/i && !quest::istaskactive(600715) && !quest::istaskcompleted(600715)) {
    quest::say("Four tusks. The big ones. Gorbak will know if they are small.");
    quest::assigntask(600715);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
