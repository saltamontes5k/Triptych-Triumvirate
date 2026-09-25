# Nhemen - Sunderock Springs
# The Serpent's Spine :: Nhemen's Secret (600434)
# Destroy Vu`Ryn the Stone Guardian in the eastern Vergalid Mines.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("We are not acquainted, $name. Nor will we be.");
      return;
    }
    if (quest::istaskactive(600434)) {
      quest::say("Vu`Ryn still stands, $name. See that it does not.");
    }
    else {
      quest::say("There is a guardian in the eastern mines, $name. " . quest::saylink("Vu`Ryn") .
                 " they call it. Destroy it, and speak of it to no one.");
    }
  }

  if ($text=~/vu/i && $client->GetLevel() >= 65 && !quest::istaskactive(600434)) {
    quest::assigntask(600434);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
