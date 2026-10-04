# Captain Gul - The Steppes
# The Serpent's Spine :: Lost Souls tasks (600600-600601).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600600)) {
      quest::say("The [mines], soldier. Ten zealots. Report when the tunnels are quieter.");
    }
    elsif (quest::istaskactive(600601)) {
      quest::say("The [symbol], soldier. The void marks its property. Find the mark.");
    }
    elsif (!quest::istaskcompleted(600600)) {
      quest::say("You have the look of a [soldier]. Good. The Vergalid Mines swallow my patrols whole.");
    }
    elsif (!quest::istaskcompleted(600601)) {
      quest::say("The zealots were only the [surface]. The void itself is in those tunnels.");
    }
    else {
      quest::say("The mines are quieter for your work, $name. The lost will rest easier.");
    }
  }
  if ($text=~/soldier/i && !quest::istaskactive(600600) && !quest::istaskcompleted(600600)) {
    quest::say("Enter the Vergalid Mines and slay ten of the Vergalid zealots - their assassins and their elite. Then report back to me.");
    quest::assigntask(600600);
  }
  if ($text=~/surface/i && quest::istaskcompleted(600600) && !quest::istaskactive(600601) && !quest::istaskcompleted(600601)) {
    quest::say("Return to the mines and recover a Void Etched Symbol - proof of what squats in the dark down there. Deliver it to me and the watch will believe what I tell them.");
    quest::assigntask(600601);
  }
  if ($text=~/mines/i && quest::istaskactive(600600)) {
    quest::say("West and below, between the Sunderock springs and the deep roots. Keep your blade loose.");
  }
  if ($text=~/symbol/i && quest::istaskactive(600601)) {
    quest::say("Void etched. It burns a little to carry. That is how you know it is the right one.");
  }
}

sub EVENT_ITEM {
  # Consume the symbol only while Lost Souls II is active (task system
  # handles completion); anything else is returned.
  if (quest::istaskactive(600601)) {
    plugin::check_handin(\%itemcount, 36158 => 1);
  }
  plugin::return_items(\%itemcount);
}
