# Warwing Wendlez - Stone Hive
# The Serpent's Spine :: Warwing task series (tasks 600584-600587).
# Live-accurate chain: Who's Who? -> Infiltrate the Hive -> Honey, I'm Home!
# -> The Queen Bixie. Neezzee and Queen Pelzia spawn in the upper hive; the
# Bixie War Plans are a ground spawn in the war council chamber.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600584)) {
      quest::say("Find [Neezzee] in the war council chamber, two elevators up. Do not trust her - she will know why you have come.");
    }
    elsif (quest::istaskactive(600585)) {
      quest::say("The [war plans] lie in the council chamber, not far from where Neezzee held court. Grab them and bring them to me.");
    }
    elsif (quest::istaskactive(600586)) {
      quest::say("Wings, flesh, a scent gland, antennae, and an [insignia]. Bring me all of it and I will disguise you.");
    }
    elsif (quest::istaskactive(600587)) {
      quest::say("Suit up and slay [Queen Pelzia]. Off with her head!");
    }
    elsif (!quest::istaskcompleted(600584)) {
      quest::say("Who sent you? Was it [Vreshnar]? I suppose it must have been.. my whereabouts are secret, and a scout of Crescent Reach would not have given up my position willingly. Listen here, I've discovered the key to unhinging Stone Hive. Their military genius lies in the mind of one particular strategist by the name of [Neezzee], but her room is well guarded.");
    }
    elsif (!quest::istaskcompleted(600585)) {
      quest::say("I. . . don't know what happened, it must have been a powerful enchantment. How mortifying! Neezzee is gone, you say? Now our only hope is to find her [plans].");
    }
    elsif (!quest::istaskcompleted(600586)) {
      quest::say("Most interesting. They are nearly.. gibberish. It seems our Bixies are more caught up in the idea of war than any idea of whom they want to war upon! I fear this may be some form of misdirection. We must get you [disguised] as well. It requires many components to escape notice around here!");
    }
    elsif (!quest::istaskcompleted(600587)) {
      quest::say("That should do nicely! When you are ready, [suit up] so you will be able to approach the queen's chambers without arousing suspicion. We can make no mistakes, the safety of Crescent Reach lays on our very shoulders!");
    }
    else {
      quest::say("You have destroyed the queen! The bixie threat has been contained, for now. . . but there may be a future queen being raised among the grubs. How long will it be until a new threat emerges?");
    }
  }
  if ($text=~/neezzee/i && !quest::istaskactive(600584) && !quest::istaskcompleted(600584)) {
    quest::say("Find her in the war council chamber, two elevators up. It's best to kill all the mobs in the room first. She will not assist until you greet her - and then she will show her true face. Slay her and return to me.");
    quest::assigntask(600584);
  }
  if ($text=~/plans/i && quest::istaskcompleted(600584) && !quest::istaskactive(600585) && !quest::istaskcompleted(600585)) {
    quest::say("She obsessively documented every military plan or theory she had. They must be inside the council chamber! It is heavily guarded, but if you dispatched Neezzee so easily I am sure it should pose little challenge. Bring me those plans!");
    quest::assigntask(600585);
  }
  if ($text=~/disguise/i && quest::istaskcompleted(600585) && !quest::istaskactive(600586) && !quest::istaskcompleted(600586)) {
    quest::say("Yes, we must get you disguised. A rather arduous task I'm afraid. Bring me two intact bixie wings, two bits of intact bixie flesh, one intact scent gland, two intact antennae, and one intact Stone Hive insignia. All of it can be gathered before you return.");
    quest::assigntask(600586);
  }
  if ($text=~/queen/i && quest::istaskcompleted(600586) && !quest::istaskactive(600587) && !quest::istaskcompleted(600587)) {
    quest::say("It's the only way to be sure. Once you suit up, dispatch Queen Pelzia in her chamber beyond the council room. Off with her head!");
    quest::assigntask(600587);
  }
}

sub EVENT_ITEM {
  # Consume task items only while their task is active (task system handles
  # completion); anything else is returned by the handin system.
  if (quest::istaskactive(600585)) {
    plugin::check_handin(\%itemcount, 21793 => 1);
  }
  if (quest::istaskactive(600586)) {
    plugin::check_handin(\%itemcount, 54616 => 2, 54617 => 2, 54618 => 1, 54619 => 2, 54620 => 1);
  }
  plugin::return_items(\%itemcount);
}
