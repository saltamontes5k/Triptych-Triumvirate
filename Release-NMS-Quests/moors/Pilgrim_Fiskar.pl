# Pilgrim Fiskar - Blightfire Moors
# The Serpent's Spine :: Wanderlust Guild
# #4 600209 Into the Reeds (locate Fiskar), #5 600212 All Abuzz (Fiskar assigns)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600209)) {
      quest::say("Hail, $name. I am Pilgrim Fiskar. I have been studying these reeds and the strange hum of the hive beyond. Speak with me again - there is much I would ask of you.");
    }
    elsif (!quest::istaskcompleted(600209)) {
      quest::say("I am but a humble pilgrim, $name. If you seek the Wanderlust Guild, speak with Master Vanguard Regan in Crescent Reach.");
    }
    elsif (!quest::istaskcompleted(600212)) {
      quest::say("You have found me. The lands around Stone Hive teem with life - and danger. Will you [" . quest::saylink("scout the moors") . "] for me?");
    }
    else {
      quest::say("The hive hums endlessly, $name. Listen closely and you can almost understand it.");
    }
  }
  if ($text=~/scout the moors/i && quest::istaskcompleted(600209) && !quest::istaskactive(600212) && !quest::istaskcompleted(600212)) {
    quest::say("Visit the JumJum Farm, the entrance to Stone Hive, the Ghostpacks and Denlord, and Selay the Cascade. Then report to Master Vanguard Regan.");
    quest::assigntask(600212);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
