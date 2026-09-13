# a_dusty_bone_pile - Crescent Reach (top level of the city, two spawn points)
# The Serpent's Spine :: Vakk'dra's Shadow (task 600247)
# The Dusty Skeleton Bone (84216).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600247, 1) && !$client->CountItem(84216)) {
      quest::say("Sifting through the dusty bones, you find one still dense with old magic: a Dusty Skeleton Bone.");
      quest::summonitem(84216); # Dusty Skeleton Bone
      quest::updatetaskactivity(600247, 1, 1);
      quest::depop();
    }
    else {
      quest::say("A pile of yellowed bones, most of them crumbling to powder.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
