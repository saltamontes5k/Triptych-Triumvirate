# Master Drizzlorn Un - Direwind Cliffs (NPC 600200)
# Ashengate raid access: completes "Locate Drizzlorn" (600360) on hail, then
# offers the Ashengate North raid (600363) with the request phrase "chance".
# Jenray teleports you here ("we are ready").

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600360)) {
      quest::say("So Zhubis sent you at last. I am Drizzlorn. For years I have waited for one bold enough to strike at Dyn`Leth's heart. You are [" . quest::saylink("ready") . "], I think.");
      quest::updatetaskactivity(600360, 0, 1);
    }
    elsif (quest::istaskcompleted(600360)) {
      quest::say("The way into Dyn`Leth's sanctum is open to you, $name. Say the [" . quest::saylink("chance") . "] when you mean to march on him.");
    }
    else {
      quest::say("You should not be here, stranger. Few find this place, and fewer leave it.");
    }
  }

  if ($text=~/^chance$/i) {
    if (quest::istaskcompleted(600360) && quest::istaskcompleted(600361) && quest::istaskcompleted(600362)) {
      quest::say("Then go. Ashengate North awaits, and Dyn`Leth with it.");
      if (!quest::istaskactive(600363) && !quest::istaskcompleted(600363)) {
        quest::assigntask(600363);
      }
    }
    else {
      quest::say("Not yet. Both wings of the Reliquary must fall before Dyn`Leth will show himself to you.");
    }
  }

  if ($text=~/^ready$/i) {
    quest::say("Spirit and steel both, I hope. Walk into the north and do not stop until He is dead.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
