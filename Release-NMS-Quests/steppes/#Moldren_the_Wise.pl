# Moldren the Wise - The Steppes
# The Serpent's Spine :: Rebuild the Portal task series (600596-600598).
# The gnoll-shattered portal to Crescent Reach cannot be raised by knowledge
# alone; the old scholar collects what remains of it.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600596)) {
      quest::say("Wilped the Withered stalks the giant crypt to the north. Silence him and return.");
    }
    elsif (quest::istaskactive(600597)) {
      quest::say("The [library] of Valdeholm still stands. Speak with Lorekeeper Fenegar - he alone remembers the portal verses.");
    }
    elsif (quest::istaskactive(600598)) {
      quest::say("The Darkfell squat on the [portal] grounds. Drive them out and the stones may yet sing.");
    }
    elsif (!quest::istaskcompleted(600596)) {
      quest::say("This portal once carried a thousand travelers a day, and now it carries only [echoes]. Will you help me wake it?");
    }
    elsif (!quest::istaskcompleted(600597)) {
      quest::say("Wilped is silence, but his [knowledge] died with him. Except. . . perhaps not entirely.");
    }
    elsif (!quest::istaskcompleted(600598)) {
      quest::say("The verses are found, the charm recovered - but gnolls gnaw at the [stones] themselves.");
    }
    else {
      quest::say("The portal hums faintly now, like a sleeper dreaming of waking. Thank you, $name.");
    }
  }
  if ($text=~/echoes/i && !quest::istaskactive(600596) && !quest::istaskcompleted(600596)) {
    quest::say("First, the crypt. Wilped the Withered, the prophet-spirit who guards the old giant burial grounds, hoards what we need. Slay him and return to me.");
    quest::assigntask(600596);
  }
  if ($text=~/knowledge/i && quest::istaskcompleted(600596) && !quest::istaskactive(600597) && !quest::istaskcompleted(600597)) {
    quest::say("The portal verses survive in the libraries of Valdeholm. Cross the great bridge, find Wraithguard Lorekeeper Fenegar, and commit what he shares to memory. Then return to me.");
    quest::assigntask(600597);
  }
  if ($text=~/library/i && quest::istaskactive(600597)) {
    quest::say("Valdeholm lies beyond the steppes, seat of the Wraithguard. Fenegar keeps the Lorekeeper's pulpit.");
  }
  if ($text=~/stones/i && quest::istaskcompleted(600597) && !quest::istaskactive(600598) && !quest::istaskcompleted(600598)) {
    quest::say("The Darkfell gnolls have made a kennel of the ruined portal. Slay ten of their gnolls and four of their shamans, and speak with me. The stones will remember who cleared them.");
    quest::assigntask(600598);
  }
  if ($text=~/portal/i && quest::istaskactive(600598)) {
    quest::say("The gnolls, friend. The portal grounds, west of here. Clear them.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
