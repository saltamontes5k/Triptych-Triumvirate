# Farmer Lize - Crescent Reach (Jade Dragon's Den, ground floor room)
# The Serpent's Spine :: Food for Thought (task 600253) and
# Soul Patrol (task 600254), both level 15+.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600253) && !quest::istaskactive(600253)
      && !quest::istaskcompleted(600254) && !quest::istaskactive(600254)) {
      quest::say("Goodness. Have you seen our farm? It's terrible, [skeletons] are clickity clacking their bones all over my home. All of our farm help abandoned us as well. We really are in dire straights. All the trinkets I made are locked away in there, and I can't get to them. If someone could [retrieve] them for me, I might be able to sell some to recoup our losses before those creatures get their grimy bones all over them.");
    }
    elsif (quest::istaskactive(600253)) {
      quest::say("The chests are scattered about the farm - some in the house, some in the carts. Open them and bring me five of my trinkets.");
    }
    elsif (quest::istaskactive(600254)) {
      quest::say("They mostly haunt the rooms inside the farm in the Hollow. For now I say, udra . . . until we meet again.");
    }
    else {
      quest::say("The farm breathes easier with you about, friend.");
    }
  }
  if ($text=~/skeletons/i) {
    quest::say("Yes, terrible skeletons. I'm not sure what Joen told you, but I believe them to be the spirits of the ogres that passed in the area. Not sure why they chose the farm to live, but they certainly did. I heard many haunting wails in there. I get the feeling some of those spirits are waiting to be set [free]. Why don't you, uhm, help them a bit? I figure we will both win -- I will get my farm back and they will get to pass on into the realm of death.");
  }
  if ($text=~/free/i) {
    quest::say("Be careful, $name. Hopefully we will see you before too long. They mostly haunt the rooms inside the farm in the Hollow. For now I say, udra . . . until we meet again.");
    quest::assigntask(600254); # Soul Patrol
  }
  if ($text=~/retrieve/i) {
    quest::say("Would you? I would be very grateful. I would even reward you! In our haste to leave the farm, my belongings fell out of our cart and got scattered about. Surely though a stalwart adventurer such as yourself can find a few chests in the farm. Surely there are some of my goods left in them.");
    quest::assigntask(600253); # Food for Thought
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 36196 => 5)) { # 5 of Lize's Trinkets
    quest::say("Oh! Oh, look at them. A little worse for wear, but these will sell. Here - a bottle of my country fizz for your troubles. I make it myself; Joen can't stand it, which means more for me.");
    if (quest::istaskactivityactive(600253, 1)) {
      quest::updatetaskactivity(600253, 1, 1);
    }
    quest::summonitem(53499, 5); # Farmer Lize's Country Fizz x5
    return;
  }
  plugin::return_items(\%itemcount);
}
