# Historian Pewdri - Crescent Reach
# The Serpent's Spine :: Pieces of the Past (task 600210)
# Item: Ogre Relic 54638, reward Sphere of the Ancients 53514

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello there, adventurer. Are you by any chance heading out into the [" . quest::saylink("Moors") . "]?");
  }
  if ($text=~/Moors/i) {
    quest::say("I am researching the ogres that once lived here in Nokk. I have had luck finding a relic here and there, but could really use more. There is a ruined [" . quest::saylink("tower") . "] in particular that may hold an item or two.");
  }
  if ($text=~/tower/i) {
    if (!quest::istaskactive(600210) && !quest::istaskcompleted(600210)) {
      quest::say("A watchtower out in the Moors, overrun by its guardian. Bring me whatever relics you recover.");
      quest::assigntask(600210);
    }
  }
  if ($text=~/relic/i && quest::istaskcompleted(600210)) {
    quest::say("Thanks so much for your help, $name. This tells us a great deal about the old ogre kingdom.");
  }
}

sub EVENT_ITEM {
  # Consume the relic only while Pieces of the Past is active (task system
  # grants the reward on completion); anything else is returned by the handin
  # system.
  if (quest::istaskactive(600210)) {
    plugin::check_handin(\%itemcount, 54638 => 1);
  }
}
