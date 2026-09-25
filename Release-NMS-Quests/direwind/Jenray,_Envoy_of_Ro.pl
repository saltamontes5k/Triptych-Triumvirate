# Jenray, Envoy of Ro - Direwind Cliffs
# The Serpent's Spine :: Ashengate access (Severing the Strings, task 600023)
# The Serpent's Spine :: Scholars of Solusek faction arc (600350-352: Children of Flame,
#    A Daring Rescue, Under Pressure -- repeatable faction grind, inside Ashengate)
# The Serpent's Spine :: Ashengate West raid (600362), Ghosts from the Past (600365)
#   and the teleport that opens the way to Master Drizzlorn Un (600360).
# Located in the tent just outside the lava moat to the right of the Ashengate zone.

my @chain = (600350, 600351, 600352);

sub next_task {
  my @c = @chain;
  foreach my $t (@c) {
    return $t if !quest::istaskcompleted($t);
  }
  return $c[0];
}

sub arc_done {
  return (quest::istaskcompleted(600350) && quest::istaskcompleted(600351) && quest::istaskcompleted(600352));
}

sub offer_task {
  my $t = shift;
  if (!quest::istaskactive($t)) {
    quest::assigntask($t);
  }
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600020)) {
      quest::say("You are not ready, $name. Prove yourself in the Leviathan's Lair first.");
    }
    elsif (!quest::istaskcompleted(600023)) {
      quest::say("The Reincarnate walks again, his strings pulled by unseen hands. Do you wish to help me sever the [" . quest::saylink("strings") . "]?");
    }
    elsif (!quest::istaskcompleted(600013)) {
      quest::say("The strings are cut, but the door to Ashengate is not yet open for you, $name. Finish Captain Zheren's work in Sunderock Springs.");
    }
    elsif (!arc_done()) {
      my $t = next_task();
      if ($t == 600350) {
        quest::say("The eggs burning in Ashengate must never hatch, $name. Say the [" . quest::saylink("word") . "] to take on this task.");
      }
      elsif ($t == 600351) {
        quest::say("The Arbiter of Ash guards the reliquary's secrets. Say the [" . quest::saylink("word") . "] for a daring task.");
      }
      else {
        quest::say("The depths teem with slime and ash. Say the [" . quest::saylink("word") . "] and I will show you what must be done.");
      }
    }
    else {
      quest::say("You have given much to the Scholars, $name. Give me a [" . quest::saylink("greater challenge", 1, "Give me a greater challenge") . "] and the western wing shall be yours to break.");
    }
  }

  if ($text=~/strings/i) {
    if (quest::istaskcompleted(600020)) {
      if (!quest::istaskactive(600023) && !quest::istaskcompleted(600023)) {
        quest::say("Enter the Vergalid Mines. Kill the six Stone Protectors in the shrine room and destroy Goru Uldrock, the Reincarnate. This must be done alongside the assault on Vergalid himself.");
        quest::assigntask(600023);
      }
    }
    else {
      quest::say("Not yet, $name.");
    }
  }

  if ($text=~/word/i) {
    if (quest::istaskcompleted(600020) && quest::istaskcompleted(600023) && quest::istaskcompleted(600013)) {
      offer_task(next_task());
    }
    else {
      quest::say("Not yet, $name.");
    }
  }

  # request the Ashengate West raid
  if ($text=~/give me a greater challenge/i) {
    if (quest::istaskcompleted(600023) && quest::istaskcompleted(600020)) {
      quest::say("Then face the Twiceborn. Say 'enter Ashengate' at the portal when your force is gathered.");
      if (!quest::istaskactive(600362) && !quest::istaskcompleted(600362)) {
        quest::assigntask(600362);
      }
    }
    else {
      quest::say("Prove yourself first, $name. Cut the strings and clear the Leviathan's Lair.");
    }
  }

  # Ghosts from the Past (West single, North gate)
  if ($text=~/ghosts/i) {
    if (quest::istaskcompleted(600023) && quest::istaskcompleted(600013)) {
      quest::say("The dead of the western wing will not rest while the Twiceborn draws breath. Say the [" . quest::saylink("word") . "] to take on [" . quest::saylink("ghosts") . "].");
      if (!quest::istaskactive(600365) && !quest::istaskcompleted(600365)) {
        quest::assigntask(600365);
      }
    }
    else {
      quest::say("Not yet, $name.");
    }
  }

  # the path to Drizzlorn (Locate Drizzlorn, 600360)
  if ($text=~/who is drizzlorn/i) {
    quest::say("From where do you know that name, $name? Speak!");
  }

  if ($text=~/zhubis the griffon tamer/i) {
    quest::say("I... I did not think you were ready. But Selay has sent you here, and I trust no one more than Selay. If you truly believe you are [" . quest::saylink("ready", 1, "we are ready") . "], I will show you who it is you seek.");
  }

  if ($text=~/we are ready/i) {
    if (quest::istaskactive(600360) || quest::istaskcompleted(600360)) {
      quest::say("Come with me, $name.");
      quest::emote("conjures elements from all around him; a stone rune rises from the lava, and you feel a force rush through you.");
      quest::movepc(405, 922, -565, 240, 0);
    }
    else {
      quest::say("Ready for what, $name? Speak plainly.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
