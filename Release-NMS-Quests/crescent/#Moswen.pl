# Moswen - Crescent Reach
# The Serpent's Spine :: Love in the Air #3 (600092) and #4 (600093)
# Items: Amulet of Desire 85090, Kamilah's Amulet of Love 53493, Sweetheart's Cake 85091

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600092)) {
      quest::say("Oh, hello. I am Moswen. Is there something I can help you with?");
    }
    elsif (!quest::istaskcompleted(600093)) {
      quest::say("He is wonderful, isn't he? Minka, I mean. But he is also being courted by that jeweler. Here - I had Kamilah's little amulet remade into something worth giving, and a [" . quest::saylink("cake") . "]. Would you take them to Captain Minka for me?");
    }
    else {
      quest::say("That amulet... I shall treasure my memory of it. Whoever wins Minka's heart is lucky indeed.");
    }
  }
  if ($text=~/cake/i && quest::istaskcompleted(600092) && !quest::istaskactive(600093) && !quest::istaskcompleted(600093)) {
    quest::say("Take these to Minka. Tell him they are from me.");
    quest::summonitem(53493); # Kamilah's Amulet of Love
    quest::summonitem(85091); # Sweetheart's Cake
    quest::assigntask(600093);
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85090 => 1)) { #Amulet of Desire
    quest::say("An amulet? With... my face on it? How did - did Nexeu send this? That ridiculous, wonderful man. Tell him I shall wear it.");
    quest::emote("turns the amulet over in her hands, smiling despite herself.");
  }
  plugin::return_items(\%itemcount);
}
