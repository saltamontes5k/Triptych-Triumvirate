# Champion Utenka - Crescent Reach (near the training dummies)
# The Serpent's Spine :: Utenka's Combat Trial (task 600272)
# Reconstructed from the Crescent Reach newbie guide (no live quest page).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600272) && !quest::istaskactive(600272)) {
      quest::say("Halt! Do you smell that? That is the smell of an untrained fighter. It clings to you, friend. If you would walk out the gates of this city, you will first prove you can swing a sword - or a spell - against the [dummies].");
    }
    elsif (quest::istaskactive(600272)) {
      quest::say("Ten dummies. Break them. The dummies respawn, so you needn't fear running out of practice.");
    }
    else {
      quest::say("You smell of victory. Well done, recruit.");
    }
  }
  if ($text=~/dummies/i) {
    quest::say("The training dummies are in the next room. Destroy ten of them - auto-attack will do, or your spells if you are of that persuasion. They will likely respawn faster than you can break them. Return to me when you have done it.");
    quest::assigntask(600272); # Utenka's Combat Trial
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
