# Toegnasher - The Steppes
# The Serpent's Spine :: Book For Toegnasher (task 600607).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600607)) {
      quest::say("The [pages], the pages! Three of them, scattered in Darkfell claws.");
    }
    elsif (!quest::istaskcompleted(600607)) {
      quest::say("Cracked spine and blank shelf - my [book] is a ruin. The Darkfell gnolls carry its pages like trophies.");
    }
    else {
      quest::say("Bound and complete! You have made an old collector absurdly happy, $name.");
    }
  }
  if ($text=~/book/i && !quest::istaskactive(600607) && !quest::istaskcompleted(600607)) {
    quest::say("Recover the three ancient parchments the Darkfell carry - two of one, one of another - and deliver them to me. Mind the elders; they read everything they loot.");
    quest::assigntask(600607);
  }
  if ($text=~/pages/i && quest::istaskactive(600607)) {
    quest::say("Ancient parchment, gnoll-handled. Shake it loose and bring it here.");
  }
}

sub EVENT_ITEM {
  # Consume the parchments only while Book For Toegnasher is active (task
  # system handles completion); anything else is returned.
  if (quest::istaskactive(600607)) {
    plugin::check_handin(\%itemcount, 88138 => 2, 88139 => 1);
  }
  plugin::return_items(\%itemcount);
}
