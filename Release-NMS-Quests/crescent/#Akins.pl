# Akins - Crescent Reach
# The Serpent's Spine :: "Things Go Bump in the Night" chain (tasks 600100-600104)
# Items: Thought Elixir of the Council 53495, Shambling Mound Branch 84233,
#         Treant Wood Heart 84234, Glowing Glass Shard 84237

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600100)) {
      quest::say("Say, do you frighten easily, my friend? As much as I hate to admit it, there are undead in Crescent Reach - close to the catacombs in the Hollow. Will you help me study them?");
    }
    elsif (!quest::istaskcompleted(600101)) {
      quest::say("The Nokk dead guard an old ogre chief's rest. His name is Gekkdar. Find his spirit in the catacombs and learn what binds him.");
    }
    elsif (!quest::istaskcompleted(600102)) {
      quest::say("I have a new area that might interest you! In Blightfire Moors is a marsh crawling with walking shrubs. Bring me samples! I can hardly contain my excitement.");
    }
    elsif (!quest::istaskcompleted(600103)) {
      quest::say("Those shambling mounds are no restless dead - they are rotwood treants! Bring me their wood hearts and we'll get to the bottom of this.");
    }
    elsif (!quest::istaskcompleted(600104)) {
      quest::say("Something near the center of the blast changed the trees. Bring me glowing glass shards from the blightfire dead and we may solve this mystery!");
    }
    else {
      quest::say("What a mystery we have unraveled, $name! Truly, the dead do not rest easy here.");
    }
  }

  if (($text=~/undead/i || $text=~/help/i) && !quest::istaskactive(600100) && !quest::istaskcompleted(600100)) {
    quest::say("Wonderful! The catacombs are in the Hollow just past the farm. Kill the Nokk dead and bring me a Thought Elixir of the Council to study.");
    quest::assigntask(600100);
  }
  if ($text=~/spirit/i && quest::istaskcompleted(600100) && !quest::istaskactive(600101) && !quest::istaskcompleted(600101)) {
    quest::say("His name is Gekkdar, the old ogre chief. Find him and hear his tale.");
    quest::assigntask(600101);
  }
  if (($text=~/shivers/i || $text=~/theory/i) && quest::istaskcompleted(600101) && !quest::istaskactive(600102) && !quest::istaskcompleted(600102)) {
    quest::say("The marsh in the Moors is draped in fog and crawling with walking shrubs. Bring me branches and I will deduce what is responsible!");
    quest::assigntask(600102);
  }
  if ($text=~/initially thought/i && quest::istaskcompleted(600102) && !quest::istaskactive(600103) && !quest::istaskcompleted(600103)) {
    quest::say("Bring me Treant Wood Hearts and we shall see what truly animates the dead wood.");
    quest::assigntask(600103);
  }
  if ($text=~/solving/i && quest::istaskcompleted(600103) && !quest::istaskactive(600104) && !quest::istaskcompleted(600104)) {
    quest::say("Glowing Glass Shards - bring them, and we may at last understand the blightfire!");
    quest::assigntask(600104);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
