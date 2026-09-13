# Selay the Cascade - Blightfire Moors
# The Serpent's Spine :: Locate Zheren (task 600213)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Yes, I know of you, $name. You would be surprised how many rumors of your daring adventures have reached my ears. And last night you were in my [" . quest::saylink("dreams") . "].");
  }
  if ($text=~/dreams/i) {
    quest::say("Yes. As I slept I saw a great many things, obscured by pouring rainfall. Lethar was by my side again. When I woke, I knew there was a [" . quest::saylink("certain path") . "] you must walk.");
  }
  if ($text=~/certain path/i) {
    quest::say("Make your way to Sunderock and seek out Captain Zheren. He will have more information for you.");
    if (!quest::istaskactive(600213) && !quest::istaskcompleted(600213)) {
      quest::assigntask(600213);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
