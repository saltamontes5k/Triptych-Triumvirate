# Spirit of Wisdom - Crescent Reach (rune stones near the tunnel to the city)
# The Serpent's Spine :: Heshyrr's Wisdom (task 600242)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600242, 1)) {
      quest::say("So. A warm-blooded thing with cold hands and Heshyrr's staff. I am Wisdom, and I was old when Truth was a sparkle in its mother's eye. Hear me: the ogres built great Nokk, and great Nokk fell - not to enemies, but to the curse their god dragged back from the Plane of Earth. Wisdom is knowing the price before you pay it. Now go; the spirithunter waits above.");
      quest::updatetaskactivity(600242, 1, 1);
    }
    else {
      quest::say("Wisdom cannot be rushed, little seeker. Walk with Heshyrr's staff and return.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
