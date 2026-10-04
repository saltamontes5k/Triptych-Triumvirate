# Ekaterina - Goru`kar Mesa
# The Serpent's Spine :: Save the Queen task series (tasks 600622-600626).
# A satyr matriarch whose queen has gone strange and cruel; the series ends
# at Queen Nhyalea's front door.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600622)) {
      quest::say("The falls still run filthy. Six oozes, six ring snakes - then we will talk.");
    }
    elsif (quest::istaskactive(600623)) {
      quest::say("Scout the [camps] and the sanctuary, then bring me everything you saw.");
    }
    elsif (quest::istaskactive(600624)) {
      quest::say("Prove your worth - the widows, the oozes, the snakes - and I will believe you.");
    }
    elsif (quest::istaskactive(600625)) {
      quest::say("Ramona waits with her alchemy. Bring her the [parts].");
    }
    elsif (quest::istaskactive(600626)) {
      quest::say("The [cure] is ready. Queen Nhyalea waits at her court. One way or another, this ends today.");
    }
    elsif (!quest::istaskcompleted(600622)) {
      quest::say("Traveler, you look strong of arm and soft of heart. Will you [listen] to an old satyr's trouble?");
    }
    elsif (!quest::istaskcompleted(600623)) {
      quest::say("Something has [changed] in our queen. Scout for me, and we will know the truth.");
    }
    elsif (!quest::istaskcompleted(600624)) {
      quest::say("If you would face a queen, first face the mesa's [vermin] and win.");
    }
    elsif (!quest::istaskcompleted(600625)) {
      quest::say("Ramona can brew a [cure] - if you fetch what she needs.");
    }
    else {
      quest::say("The roost is quiet now. Whatever the queen became, she is at peace. Thank you, $name.");
    }
  }
  if ($text=~/listen/i && !quest::istaskactive(600622) && !quest::istaskcompleted(600622)) {
    quest::say("Our queen wanders the Serpent's Falls, snarling at the water. The falls are fouled - slay six murkwater oozes and six ring snakes, then return. If the water is the sickness, we will know it soon enough.");
    quest::assigntask(600622);
  }
  if ($text=~/changed/i && quest::istaskcompleted(600622) && !quest::istaskactive(600623) && !quest::istaskcompleted(600623)) {
    quest::say("She is not herself. Scout the Tuffein camp, the dryad sanctuary atop the mesa, and the northern route to the giants. Come back with your findings.");
    quest::assigntask(600623);
  }
  if ($text=~/camps/i && quest::istaskactive(600623)) {
    quest::say("The Tuffein camp lies to the southwest. The oreads keep their sanctuary on the high mesa. The minohten graze along the northern route. Walk all three, carefully.");
  }
  if ($text=~/vermin/i && quest::istaskcompleted(600623) && !quest::istaskactive(600624) && !quest::istaskcompleted(600624)) {
    quest::say("Two dark widows, four murkwater oozes, four ring snakes. If the mesa's venom cannot touch you, perhaps the queen's cannot either.");
    quest::assigntask(600624);
  }
  if ($text=~/cure/i && quest::istaskcompleted(600624) && !quest::istaskactive(600625) && !quest::istaskcompleted(600625)) {
    quest::say("Ramona the alchemist can brew something to calm a maddened beast. Her parts are scattered - a puma's paw from Blackfeather Roost, a recluse venom sac, a snake's fang. Bring them to her.");
    quest::assigntask(600625);
  }
  if ($text=~/parts/i && quest::istaskactive(600625)) {
    quest::say("A puma paw, a recluse venom sac, a snake fang. Ramona waits in the camp.");
  }
  if ($text=~/queen/i && quest::istaskcompleted(600625) && !quest::istaskactive(600626) && !quest::istaskcompleted(600626)) {
    quest::say("Then there is nothing left but the queen herself. Slay Queen Nhyalea and return to me. Tunare keep you - I fear it must be done.");
    quest::assigntask(600626);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
