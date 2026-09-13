# Wraithguard Thentil Strongarm - Valdeholm
# The Serpent's Spine :: Armor Supplies (task 600111)
# Item: Icefall Grizzly Pelt 85789
# Reward choice: Wraithguard Bracer 53698, Runelinked Bracer 53699,
#                Fieldwarden's Bracer 53700, Lorekeeper's Bracelet 53701

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("What brings you to these forsaken peaks? My people are fighting a losing battle against the shades of our own fallen kin. We lack even the [supplies] and weapons to stage a proper defense.");
  }
  if ($text=~/supplies/i) {
    if (!quest::istaskactive(600111) && !quest::istaskcompleted(600111)) {
      quest::say("We draw most of our resources from the surrounding glaciers. Bring me pelts from the Icefall grizzly bears and I will see you fitted with a bracer.");
      quest::assigntask(600111);
    }
    else {
      quest::say("The grizzlies of Icefall Glacier still roam. Bring me their pelts.");
    }
  }
  if ($text=~/bracer/i && quest::istaskcompleted(600111) && !defined($qglobals{thentil_reward})) {
    quest::say("Which bracer can I fit you with: the [" . quest::saylink("Wraithguard") . "], the [" . quest::saylink("runelinked") . "], the [" . quest::saylink("fieldwarden") . "], or the [" . quest::saylink("lorekeeper") . "]?");
  }
  if ($text=~/Wraithguard/i && quest::istaskcompleted(600111) && !defined($qglobals{thentil_reward})) {
    quest::summonitem(53698); quest::setglobal("thentil_reward", 1, 5, "F");
  }
  if ($text=~/runelinked/i && quest::istaskcompleted(600111) && !defined($qglobals{thentil_reward})) {
    quest::summonitem(53699); quest::setglobal("thentil_reward", 1, 5, "F");
  }
  if ($text=~/fieldwarden/i && quest::istaskcompleted(600111) && !defined($qglobals{thentil_reward})) {
    quest::summonitem(53700); quest::setglobal("thentil_reward", 1, 5, "F");
  }
  if ($text=~/lorekeeper/i && quest::istaskcompleted(600111) && !defined($qglobals{thentil_reward})) {
    quest::summonitem(53701); quest::setglobal("thentil_reward", 1, 5, "F");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 28690 => 1, 53724 => 1)) { #Firgant's Copper Ring + Vial of Gooey Black Gel
    quest::say("These are Thurgant's own - the shades stole them from his tomb. He is free now, thanks to you. I will see that they are delivered to his kin.");
    quest::emote("bows his head and carefully wraps the artifacts in a Wraithguard shroud.");
  }
  elsif (plugin::check_handin(\%itemcount, 28690 => 1)) { #Firgant's Copper Ring
    quest::say("Firgant's copper ring! A relic of a tomb robbed by the shades. I will see it returned to the Krithgor.");
  }
  elsif (plugin::check_handin(\%itemcount, 53724 => 1)) { #Vial of Gooey Black Gel
    quest::say("A vial of black gel - stolen grave-goods. You have done a kindness for the restless dead, $name.");
  }
  plugin::return_items(\%itemcount);
}
