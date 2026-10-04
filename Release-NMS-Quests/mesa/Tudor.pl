# Tudor - Goru`kar Mesa
# The Serpent's Spine :: Tudor's brew reagent series (tasks 600651-600654).
# The satyr camp's brewmaster; reagents are handed in and the drink appears
# as if by magic (or fermentation).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600651)) {
      quest::say("The [spirits] need their bones - a tanglewood pod and a dryad skull.");
    }
    elsif (quest::istaskactive(600652)) {
      quest::say("[Wine] wants grapes and a bottle. The dromrek grow the best, whether they know it or not.");
    }
    elsif (quest::istaskactive(600653)) {
      quest::say("[Beer] is honest work: malt and hops, two measures of each.");
    }
    elsif (quest::istaskactive(600654)) {
      quest::say("For the [ale], young griffon feathers carry the finest spores. Six will do.");
    }
    elsif (!quest::istaskcompleted(600651)) {
      quest::say("Ahh, a customer with [thirst]! Or at least with arms. I have work for those.");
    }
    elsif (!quest::istaskcompleted(600652)) {
      quest::say("The whiskey mashes well. Now for something [finer].");
    }
    elsif (!quest::istaskcompleted(600653)) {
      quest::say("Wine for poets, [beer] for workers. Which are you?");
    }
    elsif (!quest::istaskcompleted(600654)) {
      quest::say("One [ale] left on my list, and its secret is in the feathers.");
    }
    else {
      quest::say("Drink deep, $name. The mesa pours generously to those who gather generously.");
    }
  }
  if ($text=~/thirst/i && !quest::istaskactive(600651) && !quest::istaskcompleted(600651)) {
    quest::say("Stormwater whiskey! Gather a tanglewood seed pod and a lingering dryad skull, deliver them here, and I will do the rest.");
    quest::assigntask(600651);
  }
  if ($text=~/finer/i && quest::istaskcompleted(600651) && !quest::istaskactive(600652) && !quest::istaskcompleted(600652)) {
    quest::say("Aged merlot. Three handfuls of dromrek barbera grapes - steal them from the giants' vines - and one good bottle.");
    quest::assigntask(600652);
  }
  if ($text=~/beer/i && quest::istaskcompleted(600652) && !quest::istaskactive(600653) && !quest::istaskcompleted(600653)) {
    quest::say("Two measures of malt, two of hops, into my hands, and the stout will be dark as a moonless night.");
    quest::assigntask(600653);
  }
  if ($text=~/ale/i && quest::istaskcompleted(600653) && !quest::istaskactive(600654) && !quest::istaskcompleted(600654)) {
    quest::say("Six young griffons, plucked for their feather-spores. Liviu swears by them, and Liviu has never steered my barrels wrong.");
    quest::assigntask(600654);
  }
  if ($text=~/spirits/i && quest::istaskactive(600651)) {
    quest::say("Tanglewood pods grow on the windwillow treants; the lingering dryads in the western mesa carry the skulls.");
  }
}

sub EVENT_ITEM {
  # Consume reagent handins only while the matching task is active (task
  # system handles completion); anything else is returned.
  if (quest::istaskactive(600651)) {
    plugin::check_handin(\%itemcount, 87163 => 1, 87164 => 1);
  }
  elsif (quest::istaskactive(600652)) {
    plugin::check_handin(\%itemcount, 87162 => 3, 51130 => 1);
  }
  elsif (quest::istaskactive(600653)) {
    plugin::check_handin(\%itemcount, 16595 => 2, 16591 => 2);
  }
  plugin::return_items(\%itemcount);
}
