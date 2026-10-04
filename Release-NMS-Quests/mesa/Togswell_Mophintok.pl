# Togswell Mophintok - Goru`kar Mesa
# The Serpent's Spine :: gnome tinkerer tasks (600659-600660).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600659)) {
      quest::say("The [drudgeweed], the drudgeweed! Handle it gently - it wilts if you sneeze on it.");
    }
    elsif (quest::istaskactive(600660)) {
      quest::say("The [bile] experiment needs fresher. . . subjects. The bears. Go on.");
    }
    elsif (!quest::istaskcompleted(600659)) {
      quest::say("Aha! Hands! Do you have any idea how hard it is to find [hands] out here?");
    }
    elsif (!quest::istaskcompleted(600660)) {
      quest::say("The weed worked, but the mixture needs [bile]. Carnivore bile, ideally. Bear-sized.");
    }
    else {
      quest::say("My contraption hums like a happy beehive, $name. Science marches on!");
    }
  }
  if ($text=~/hands/i && !quest::istaskactive(600659) && !quest::istaskcompleted(600659)) {
    quest::say("Loot one sprig of drudgeweed, deliver it here unbruised, and I will show you what a gnome can do with a weed and a dream.");
    quest::assigntask(600659);
  }
  if ($text=~/bile/i && quest::istaskcompleted(600659) && !quest::istaskactive(600660) && !quest::istaskcompleted(600660)) {
    quest::say("Eight mesa bears should yield enough. Come back when your boots are heavier.");
    quest::assigntask(600660);
  }
}

sub EVENT_ITEM {
  # Consume the drudgeweed only while Handle With Care is active (task
  # system handles completion); anything else is returned.
  if (quest::istaskactive(600659)) {
    plugin::check_handin(\%itemcount, 21486 => 1);
  }
  plugin::return_items(\%itemcount);
}
