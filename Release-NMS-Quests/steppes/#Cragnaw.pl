# Cragnaw - The Steppes
# The Serpent's Spine :: My Pretty (task 600604).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600604)) {
      quest::say("My [pretty] is lost in Darkfell claws. Twenty gnolls, then the blade and the silk. Then we talk.");
    }
    elsif (!quest::istaskcompleted(600604)) {
      quest::say("The gnolls took something of [mine]. Something shiny. Something. . . pretty.");
    }
    else {
      quest::say("It gleams on my wall now, where it belongs. The Darkfell remember you, $name. I can tell by the way they flee.");
    }
  }
  if ($text=~/mine/i && !quest::istaskactive(600604) && !quest::istaskcompleted(600604)) {
    quest::say("A razor-sharp obsidian blade, and the yellow silk I wrapped it in. Slay twenty Darkfell gnolls until both turn up, then deliver them to me. All of it. My pretty is particular.");
    quest::assigntask(600604);
  }
  if ($text=~/pretty/i && quest::istaskactive(600604)) {
    quest::say("The blade is black as midnight and the silk is gold. You will know them when you see them.");
  }
}

sub EVENT_ITEM {
  # Consume blade and silk only while My Pretty is active (task system
  # handles completion); anything else is returned.
  if (quest::istaskactive(600604)) {
    plugin::check_handin(\%itemcount, 88143 => 1, 88144 => 5);
  }
  plugin::return_items(\%itemcount);
}
