# Captain Orenu Urulump - Direwind Cliffs
# The Serpent's Spine :: Gygun's Last Request I & II (600430 / 600431)
# Receives Gygun's note (delivery auto-credits), then sends you after the
# family treasure chest hidden in the Vergalid Mines.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(600431)) {
      quest::say("The chest is safe. My son can rest now. You have my thanks, $name.");
    }
    elsif (quest::istaskactive(600431)) {
      quest::say("The chest lies somewhere in the Vergalid Mines, west over the water. Find it, $name.");
    }
    elsif (quest::istaskcompleted(600430)) {
      quest::say("So the boy is gone. And he sent you to me. There is one thing left of our line, $name: a [" .
                 quest::saylink("chest") . "] of heirlooms lost in the Vergalid Mines. Bring back what you can.");
    }
    else {
      quest::say("I have no time for strangers at this gate, $name.");
    }
  }

  if ($text=~/chest/i && quest::istaskcompleted(600430) && !quest::istaskcompleted(600431) && !quest::istaskactive(600431)) {
    quest::assigntask(600431);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
