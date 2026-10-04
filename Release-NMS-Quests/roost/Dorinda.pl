# Dorinda - Blackfeather Roost
# The Serpent's Spine :: A Small Wager (task 600594). Perched on the first
# rise of the second isle, insulting travelers into proving her wrong.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600594)) {
      quest::say("Still breathing? The [trinket] will not steal itself, weakling.");
    }
    elsif (!quest::istaskcompleted(600594)) {
      quest::say("Hello weakling. You don't mind if I call you a weakling, do you? I just happen to be the type of person who believes in speaking the truth, and the truth is, $name, you are [weak].");
    }
    else {
      quest::say("I did not think you would survive, and here you stand. I apologize, $name - you are not so weak after all.");
    }
  }
  if ($text=~/weak/i && !quest::istaskactive(600594) && !quest::istaskcompleted(600594)) {
    quest::say("Well of course you're weak - you're not a harpy! Haha! But I can see I've offended you so I'll give you a chance to prove me [wrong].");
  }
  if ($text=~/wrong/i && !quest::istaskactive(600594) && !quest::istaskcompleted(600594)) {
    quest::say("If you really want to prove me wrong then here's a challenge for you. Sneak into the royal throne room of our beloved queen and steal a royal [trinket]. If you survive the encounter, return it to me and I will apologize.");
    quest::assigntask(600594);
  }
  if ($text=~/trinket/i && quest::istaskactive(600594)) {
    quest::say("The Queen keeps her little treasures in a cage at the back of her throne room, on the last isle. Every soul in there sees through invisibility. Mind your step, weakling.");
  }
}

sub EVENT_ITEM {
  # Consume the trinket only while A Small Wager is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600594)) {
    plugin::check_handin(\%itemcount, 28678 => 1);
  }
  plugin::return_items(\%itemcount);
}
