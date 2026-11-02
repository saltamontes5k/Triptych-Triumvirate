# Malgen - Icefall Glacier
# The Serpent's Spine :: Thinning the Pack (task 600711)
# Reward: Direwolf Totem of Spirit 53688

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600711)) {
      quest::say("The pack still [" . quest::saylink("hunts") . "] the southern flats. Thin it and return to me.");
    }
    elsif (quest::istaskcompleted(600711)) {
      quest::say("The spirits of the ice run with the wolves still, but they fear you now.");
    }
    else {
      quest::say("The wolves grow bold. I mark their trails at the flats - will you [" . quest::saylink("do that") . "] which must be done?");
    }
  }
  if ($text=~/do that/i && !quest::istaskactive(600711) && !quest::istaskcompleted(600711)) {
    quest::say("Walk the southern flats, then cull the pack - elders, hunters, and the orc tenders who leash them. Return when the ice runs quiet.");
    quest::assigntask(600711);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
