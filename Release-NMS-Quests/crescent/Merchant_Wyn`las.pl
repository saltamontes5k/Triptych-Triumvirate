# Merchant Wyn`las - Crescent Reach (first level, by the inn)
# The Serpent's Spine :: Reakash's Serenity (task 600246)
# Gives the Wind Chime (84202) and Jar of the Windspirit (84204) at no charge
# while Reakash's errand is active.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600246, 1) && !$client->CountItem(84202)) {
      quest::say("A wind chime? For Reakash's little errand? Hah - no charge for you. Just tell her Wyn'las still makes the finest chimes in the Reach.");
      quest::summonitem(84202); # Wind Chime
      quest::updatetaskactivity(600246, 1, 1);
    }
    elsif (quest::istaskactivityactive(600246, 2) && !$client->CountItem(84204)) {
      quest::say("A jar of the windspirit? Swam through the falls, did you? Take it - a good jar for a good cause. Catch the mist where the water strikes the pools.");
      quest::summonitem(84204); # Jar of the Windspirit
    }
    else {
      quest::say("Vasha, friend. Chimes, jars and small comforts of home - browse, browse!");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
