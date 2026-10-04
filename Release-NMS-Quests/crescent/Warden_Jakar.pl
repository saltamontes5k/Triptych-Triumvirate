# Warden Jakar - Crescent Reach
# The Serpent's Spine :: watch warden; offers out-of-zone cull tasks for the
# steppes goblin campaign (600605 Sweeping the Steppes: Goblins, 600606 Cull
# the Goblins, 600609 The Tribal Chieftains).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600605)) {
      quest::say("Provoke them and their [bear] both. Jakar will want the whole story.");
    }
    elsif (quest::istaskactive(600606)) {
      quest::say("[Ears], citizen. Ten of them. The warden's ledger does not lie.");
    }
    elsif (quest::istaskactive(600609)) {
      quest::say("The [chieftains], $name. Three of them, and the goblin clans will scatter.");
    }
    elsif (!quest::istaskcompleted(600605)) {
      quest::say("You strike me as someone with [anger] to spare and a good sword to spare it with.");
    }
    elsif (!quest::istaskcompleted(600606)) {
      quest::say("You stirred the nest. Now [cull] it properly.");
    }
    elsif (!quest::istaskcompleted(600609)) {
      quest::say("Clans without chieftains are merely [mobs]. Take the heads that matter.");
    }
    else {
      quest::say("The steppes roads are safer for your work, $name. The warden's ledger marks it plainly.");
    }
  }
  if ($text=~/anger/i && !quest::istaskactive(600605) && !quest::istaskcompleted(600605)) {
    quest::say("The Stonemight goblins mass in The Steppes with a great pet bear they provoke travelers with. Slay twelve goblins, kill the bear, and report back to me.");
    quest::assigntask(600605);
  }
  if ($text=~/cull/i && quest::istaskcompleted(600605) && !quest::istaskactive(600606) && !quest::istaskcompleted(600606)) {
    quest::say("Bring me ten Stonemight ears. The watch pays by the ear, and I do not ask how they were collected.");
    quest::assigntask(600606);
  }
  if ($text=~/mobs/i && quest::istaskcompleted(600606) && !quest::istaskactive(600609) && !quest::istaskcompleted(600609)) {
    quest::say("Slay Stonemight Chieftain Swiftear on the steppes, and Nightmoon Chieftains Blacktooth and Snowmane in Icefall Glacier. Report to me when the clans are headless.");
    quest::assigntask(600609);
  }
  if ($text=~/bear/i && quest::istaskactive(600605)) {
    quest::say("A brown bear, big as a barn door, goaded into fighting by its masters. Give it a soldier's end.");
  }
  if ($text=~/ears/i && quest::istaskactive(600606)) {
    quest::say("Stonemight goblins carry them under their war-caps. Handle the collections yourself.");
  }
  if ($text=~/chieftains/i && quest::istaskactive(600609)) {
    quest::say("Swiftear rules the steppes camps. Blacktooth and Snowmane den in Icefall Glacier, past the bridge.");
  }
}

sub EVENT_ITEM {
  # Consume the ears only while Cull the Goblins is active (task system
  # handles completion); anything else is returned.
  if (quest::istaskactive(600606)) {
    plugin::check_handin(\%itemcount, 84241 => 10);
  }
  plugin::return_items(\%itemcount);
}
