# Lucian - Blackfeather Roost
# The Serpent's Spine :: satyr troublemaker tasks (600592 Cause some mayhem,
# 600593 Strike a Blow, 600595 Destroy! Knock the nests down!). Camped in the
# graveyard on the zone-in island beside his brother Adrian. On live, the
# Hero's Journey achievements Lucian's Vengeance and While You're Roosting
# are granted for completing his tasks alongside Adrian's and Dorinda's.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600592)) {
      quest::say("Gayatri roosts on the fourth isle, minding the harpies' young. Kill her and bring me the [heart]. I can't wait to hear the screams from here!");
    }
    elsif (quest::istaskactive(600593)) {
      quest::say("Bloody your [sword] a little more, friend. The harpies and their griffons will remember it.");
    }
    elsif (quest::istaskactive(600595)) {
      quest::say("Those [nests] will not hack themselves apart. The ledge, the grove, the cliffs, and the mesa - leave nothing standing.");
    }
    elsif (!quest::istaskcompleted(600592)) {
      quest::say("Bah, what now? Can't you see I'm [busy] here?");
    }
    elsif (!quest::istaskcompleted(600593)) {
      quest::say("Back so soon? Do you seek [vengeance] as I do, or do you just enjoy causing [mayhem]?");
    }
    else {
      quest::say("Listen. . . can you hear the frightened screams in the roost? It will take them some time to recover from us! If you are still hungry for ruin, there are always more [nests] to knock down.");
    }
  }
  if ($text=~/busy/i && !quest::istaskcompleted(600592)) {
    quest::say("Yes! I said I'm busy. Busy trying to [kill] and [destroy]. How does that make you feel?");
  }
  if ($text=~/mayhem/i && !quest::istaskactive(600592) && !quest::istaskcompleted(600592)) {
    quest::say("Mayhem is always fun, isn't it? I just happen to know a way you can cause a great deal of it! The harpies entrust the care of their young to a harpy named Gayatri. If you were to kill her, it would throw the entire roost into a panic. [Do it] and I'll make it worth your while.");
    quest::assigntask(600592);
  }
  if ($text=~/do it/i && quest::istaskactive(600592)) {
    quest::say("Haha! I can't wait to hear about it!");
  }
  if ($text=~/vengeance/i && quest::istaskcompleted(600592) && !quest::istaskactive(600593) && !quest::istaskcompleted(600593)) {
    quest::say("If it's vengeance you seek then perhaps we can help each other. Kill a good number of these pesky harpies and griffons, and I think I can find a reward to make bloodying your sword even more worthwhile. Do you [agree]?");
    quest::assigntask(600593);
  }
  if ($text=~/sword/i && quest::istaskactive(600593)) {
    quest::say("Twenty-four harpies and five blackfeather griffons. Then we will have a good laugh about it together.");
  }
  if ($text=~/destroy/i && !quest::istaskactive(600595) && !quest::istaskcompleted(600595) && quest::istaskcompleted(600593)) {
    quest::say("Destroy? Don't mind if I do! If you want to join in the fun, why don't you go hack apart some harpy [nests]? Let me know when you're done. We'll have a good laugh about it together.");
    quest::assigntask(600595);
  }
  if ($text=~/nests/i) {
    if (quest::istaskactive(600595)) {
      quest::say("Nine small nests, twenty-two large ones, and five of the ornate royal roosts on the mesa. Tear them all down!");
    }
    elsif (quest::istaskcompleted(600595)) {
      quest::say("Already done? Hah! The roost will not soon forget you.");
    }
  }
  if ($text=~/heart/i && quest::istaskactive(600592)) {
    quest::say("The heart of Gayatri. Bring it here and listen to the roost wail!");
  }
}

sub EVENT_ITEM {
  # Consume the heart only while Cause some mayhem is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600592)) {
    plugin::check_handin(\%itemcount, 13617 => 1);
  }
  plugin::return_items(\%itemcount);
}
