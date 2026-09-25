# Anderak - Direwind Cliffs
# The Serpent's Spine :: Anderak arc (600400-600403: Scouting Direwind,
#    The Blighted Animals, The Darkroot Gardens, The Darkroot Caves)
# Reward: Spore of the Freemind Sporali (53673) on the final task.

my @chain = (600400, 600401, 600402, 600403);

sub next_task {
  foreach my $t (@chain) {
    return $t if !quest::istaskcompleted($t);
  }
  return 0;
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    my $t = next_task();
    if (!$t) {
      quest::say("The gardens breathe easier now, $name. The sporali will not forget what you have done for the cliffs.");
    }
    elsif ($t == 600400) {
      quest::say("A softfoot, are you? Good. The sporali need the cliffs walked and mapped. Say [" . quest::saylink("scout") . "] and I will mark your map.");
    }
    elsif ($t == 600401) {
      quest::say("The beasts writhe with the blight. Their [" . quest::saylink("hearts") . "] may tell me how far the rot has spread.");
    }
    elsif ($t == 600402) {
      quest::say("The [gardens] to the west have gone to rot and mold. There is work there for a careful hand.");
    }
    else {
      quest::say("Beneath the gardens the [caves] fester. End what grows there, $name.");
    }
  }

  if ($text=~/scout/i) {
    if (!quest::istaskactive(600400) && !quest::istaskcompleted(600400)) {
      quest::say("Walk the Gray Legion camp, the Valley of the Black Oak, the Clan Direwind boneyard, the Darkroot Gardens, Dead Hill, and Lake Darkenmere. Then return to me.");
      quest::assigntask(600400);
    }
  }

  if ($text=~/hearts/i) {
    if (quest::istaskcompleted(600400) && !quest::istaskactive(600401) && !quest::istaskcompleted(600401)) {
      quest::say("Bring me four hearts each from the diseased bears, griffons, and wolves. Cull what suffers, $name.");
      quest::assigntask(600401);
    }
  }

  if ($text=~/gardens/i) {
    if (quest::istaskcompleted(600401) && !quest::istaskactive(600402) && !quest::istaskcompleted(600402)) {
      quest::say("Thin the gatherers and gardeners, pry the [plaguespores] from the groves, and destroy Arakeen, Eater of the Dead.");
      quest::assigntask(600402);
    }
  }

  if ($text=~/caves/i) {
    if (quest::istaskcompleted(600402) && !quest::istaskactive(600403) && !quest::istaskcompleted(600403)) {
      quest::say("Break the warriors, shamans, tenders, and vineherds of the deep gardens. And Mold Master Gangii -- his roots are [poisoned] with the blight.");
      quest::assigntask(600403);
    }
  }

  if ($text=~/poisoned/i) {
    quest::say("Bring me his poisoned roots when he falls. The sporali will remember you as a friend of the deep places.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
