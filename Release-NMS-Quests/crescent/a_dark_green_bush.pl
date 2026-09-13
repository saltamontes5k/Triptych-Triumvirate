# a_dark_green_bush - Crescent Reach (sporali cave, the Hollow)
# The Serpent's Spine :: Lizzrel's Path (task 600244)
# The Poisonous Nettle (84212).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600244, 0) && !$client->CountItem(84212)) {
      quest::emote("bristles as you reach into its dark leaves.");
      quest::say("Wincing against the sting, you pluck a Poisonous Nettle.");
      quest::summonitem(84212); # Poisonous Nettle
      quest::updatetaskactivity(600244, 0, 1);
      quest::depop();
    }
    else {
      quest::say("A dark green bush. Something about it warns you not to touch it barehanded.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
