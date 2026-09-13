# Farmer Joen - Crescent Reach (Jade Dragon's Den, ground floor room)
# The Serpent's Spine :: Reclaim the Farm (task 600255) and
# Locked Up Locket (task 600256), both level 15+.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600255) && !quest::istaskactive(600255)
      && !quest::istaskcompleted(600256) && !quest::istaskactive(600256)) {
      quest::say("These are hard times for us, $name. Me and my companion here, Lize, are doing our best to find a way out of a [dilemma].");
    }
    elsif (quest::istaskactive(600255)) {
      quest::say("The fields are the flat ground around the farmhouse - use the bag of seeds I gave you on the soil there, ten rows or so, and come tell me.");
    }
    elsif (quest::istaskactive(600256)) {
      quest::say("Please. The locket. The undead of the farm carry it - one of the restless ones took a shining to it.");
    }
    else {
      quest::say("The soil remembers, friend. One day the farm will feed the Reach again.");
    }
  }
  if ($text=~/dilemma/i) {
    quest::say("Our farm has been taken over by the undead! I'm not sure where they all came from, but one thing is certain, they wanted my farm! If you could [help] us, I would sure appreciate it. So would Lize! There is also a matter of a [keepsake] I left behind...");
  }
  if ($text=~/help/i) {
    quest::say("This is encouraging news! Because I haven't been able to get to the farm, I haven't been able to plant more seeds so that we may supply citizens with food. I need you to go to the farm and plant some seeds on the steppes. They are well irrigated so the growth should take care of itself.");
    quest::summonitem(84231); # Bag of Seeds
    quest::assigntask(600255); # Reclaim the Farm
  }
  if ($text=~/keepsake/i) {
    quest::say("Yes, I gave Lize a locket soon after I met her. I made it myself and Lize cherishes it. She says she's not bothered that it's still in the farm, but I know that's not true. She keeps reaching to her neck to feel it and I see the sadness in her eyes when she remembers it's not there. Would you [get] it back for us?");
  }
  if ($text=~/get/i) {
    quest::say("Kura dra, very much. I will always be grateful.");
    quest::assigntask(600256); # Locked Up Locket
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84232 => 1)) { # Lize's Locket
    quest::say("Farmer Joen gently dusts off the locket before handing it to Farmer Lize.");
    quest::say("Karui, very much. This locket is worth much more to me than its apparent value. You have our gratitude.");
    if (quest::istaskactivityactive(600256, 1)) {
      quest::updatetaskactivity(600256, 1, 1);
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
