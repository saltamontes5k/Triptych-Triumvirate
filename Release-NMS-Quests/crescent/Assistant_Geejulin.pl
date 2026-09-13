# Assistant Geejulin - Crescent Reach (above the library)
# The Serpent's Spine :: Myjinn's Enlightenment (task 600245)
# Gives the book "Drakkin and Crescent Reach" (84218).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600245, 0)) {
      quest::say("You're one of Myjinn's students? Then you'll be wanting this. 'Drakkin and Crescent Reach' - everything a newcomer needs to know about who we are and what we rose from. Read it well.");
      quest::updatetaskactivity(600245, 0, 1);
      quest::summonitem(84218); # Drakkin and Crescent Reach
    }
    elsif (quest::istaskactive(600245)) {
      quest::say("The Touch of the Six is shelved in the library on the second level, next to Tenish's work. Knowledge waits for those who climb.");
    }
    else {
      quest::say("The library of the Wanderlust Guild grows every day. Veeshan willing, it will outlive us all.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
