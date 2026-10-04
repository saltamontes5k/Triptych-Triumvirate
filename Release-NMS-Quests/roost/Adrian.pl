# Adrian - Blackfeather Roost
# The Serpent's Spine :: satyr scholar tasks (600590 Explore the Roost!,
# 600591 Harass the Harpies!). Camped in the graveyard on the zone-in island
# beside his estranged brother Lucian.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600590)) {
      quest::say("The roost spreads up and out from here - the [ledge], the grove, the cliffs, and the great mesa. Find what you can and tell me of it.");
    }
    elsif (quest::istaskactive(600591)) {
      quest::say("The griffons still circle. Ten of them, and then we will speak further.");
    }
    elsif (!quest::istaskcompleted(600590)) {
      quest::say("Greetings to you, $name. Are you certain that you wish to be here amongst so much [evil]?");
    }
    elsif (!quest::istaskcompleted(600591)) {
      quest::say("You have seen more of the roost than I ever dared. The harpies and their foul [griffons] still hunt my people for food. If you are stout enough of heart, perhaps you would like to [do something] about it?");
    }
    else {
      quest::say("You have done my people a great service, $name. Perhaps there can be [peace] after all.");
    }
  }
  if ($text=~/evil/i && !quest::istaskcompleted(600590)) {
    quest::say("Oh, yes, evil! Most foul! In all the tales I heard as a young satyr there were none so horrible as those about harpies and their deeds. That is why I am here. In my heart I crave peace but until my people are safe that is not to be. We will never defeat this menace until we understand it better. If you can [find a way] to explore deeper into the roost, please let me know what you find.");
  }
  if ($text=~/find a way/i && !quest::istaskactive(600590) && !quest::istaskcompleted(600590)) {
    quest::say("There are several areas in these cliffs and crags that the harpies nest in - a great [nest] on the first ledge, the grove on the second isle, the cliffs beyond, and the high mesa. Search them all and report back to me.");
    quest::assigntask(600590);
  }
  if ($text=~/nest/i && quest::istaskactive(600590)) {
    quest::say("The ledge nest lies past the narrow pass on the first isle. The grove is in the middle of the second. The cliffs are far to the right of the third, and the mesa sits atop the fourth.");
  }
  if ($text=~/griffons/i && !quest::istaskactive(600591) && !quest::istaskcompleted(600591) && quest::istaskcompleted(600590)) {
    quest::say("The griffons of this region are beholden to the harpies in a way I don't fully understand. Griffons themselves are fearsome enough but these, under the control of the harpies, are a terror like you've never seen. Slay a good number of them here in Blackfeather Roost then return to me and we will speak further.");
    quest::assigntask(600591);
  }
  if ($text=~/do something/i && !quest::istaskactive(600591) && !quest::istaskcompleted(600591) && quest::istaskcompleted(600590)) {
    quest::say("Slay ten of the blackfeather griffons. It does not frighten you, does it? I thought not. Go, and be careful.");
    quest::assigntask(600591);
  }
  if ($text=~/peace/i && quest::istaskcompleted(600591)) {
    quest::say("There can be no peace with an enemy without conscience. But you have blunted their claws, $name. That is a beginning.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
