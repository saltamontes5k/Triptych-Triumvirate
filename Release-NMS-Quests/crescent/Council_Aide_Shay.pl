# Council Aide Shay - Crescent Reach (council chamber, upper floor)
# The Serpent's Spine :: Web of Fears (task 600251, level 10+)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600251) && !quest::istaskactive(600251)) {
      quest::say("I am an aide to the Council of Six and have many responsibilities. I monitor the daily business of the city and ensure it runs smoothly for drakkin and our progenitors. While you're here, would you mind taking [care] of an issue that promises to be a nuisance to our city?");
    }
    elsif (quest::istaskactive(600251)) {
      quest::say("Destroy the spiderlings and their eggs, then find the queen! Return to me when you have completed this duty for the council.");
    }
    else {
      quest::say("The city thanks you for your service, friend.");
    }
  }
  if ($text=~/care/i) {
    quest::say("You may have seen a number of spiders running about. Those spiders are the spawn of a great and magical spider queen. Destroy the spiderlings and their eggs, then find the queen! Return to me when you have completed this duty for the council.");
    quest::assigntask(600251); # Web of Fears
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
