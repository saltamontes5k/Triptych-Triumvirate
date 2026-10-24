# Wraithguard Lodigar - Valdeholm
# The Serpent's Spine :: Wraithguard Vengeance (600730), Lodigar the Recruiter (600731)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600730) && !quest::istaskactive(600730)) {
      quest::say("You seek work? I seek [" . quest::saylink("vengeance") . "].");
    }
    elsif (!quest::istaskcompleted(600731) && !quest::istaskactive(600731)) {
      quest::say("You have spilled enough blood to hear the rest. Three [" . quest::saylink("traitors") . "] still walk Valdeholm.");
    }
    else {
      quest::say("The Wraithguard count you among its own, $name.");
    }
  }
  if ($text=~/vengeance/i && !quest::istaskactive(600730) && !quest::istaskcompleted(600730)) {
    quest::say("Thirty sergeants of the Zek loyalists. Cut them down and report back to me.");
    quest::assigntask(600730);
  }
  if ($text=~/traitors/i && !quest::istaskactive(600731) && !quest::istaskcompleted(600731)) {
    quest::say("Seathir, Gothar, Derein - each sold this city to the Shade King. Kill all three and return.");
    quest::assigntask(600731);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
