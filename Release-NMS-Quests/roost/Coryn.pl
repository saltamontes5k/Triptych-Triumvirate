# Coryn - Blackfeather Roost
# The Serpent's Spine :: griffon taming (task 600042 Blackfeather Roost, The Cliffs)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600042)) {
      quest::say("Coryn will help you, yes! Strong strangers want to explore, yes? Coryn can help you explore if strong strangers help Coryn too! [" . quest::saylink("Rescue") . "] Coryn and Coryn will help!");
    }
    else {
      quest::say("Coryn is happy! Strong strangers fed the griffon and Coryn is safe.");
    }
  }
  if ($text=~/rescue/i) {
    quest::say("Coryn is weak and the Nobles think it's fun to hurt Coryn. Coryn wants [" . quest::saylink("revenge") . "] but not strong enough. Will you take revenge for Coryn?");
  }
  if ($text=~/revenge/i) {
    if (!quest::istaskactive(600042) && !quest::istaskcompleted(600042)) {
      quest::say("Kill two Nobles for Coryn and Coryn will help. Return when they are dead and Coryn will help you explore more.");
      quest::assigntask(600042);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
