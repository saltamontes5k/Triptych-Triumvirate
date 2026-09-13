# Councilmember Myjinn - Crescent Reach
# The Serpent's Spine :: Myjinn's Enlightenment (task 600245)
# Gate: Prove Your Worth (600241). Three sources of knowledge, then a quiz.
# Answers: Nokk / the Plane of Earth / the human race.
# Completing this quest unlocks Keikolin the Enlightened for drakkin of the
# Keikolin bloodline (heritage 5).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("Hm? Speak with Council Aide Mystrana first, little one. The Council does not dally with strangers.");
    }
    elsif (!quest::istaskcompleted(600245) && !quest::istaskactive(600245)) {
      quest::say("Vasha! That is how we drakkin greet one another. It is a word taken from the dragon language. Are you here to improve your [intellect]?");
    }
    elsif (quest::istaskactive(600245)) {
      quest::say("Have you gathered the three sources of knowledge? When you are [ready], I will test what you have learned.");
    }
    else {
      quest::say("Knowledge is a lantern, friend. Keep yours lit.");
    }
  }
  if ($text=~/intellect/i) {
    quest::say("Then you should meet my mother, Lady Keikolin the Enlightened, the most knowledgeable dragon of the Six. But first, [wisdom] must be earned.");
  }
  if ($text=~/wisdom/i) {
    quest::say("Wisdom is not given, it is gathered. I will send you to gather it. Will you [do] this for me?");
  }
  if ($text=~/do/i) {
    quest::say("Good. Speak with Assistant Geejulin above the library. Find the Touch of the Six hidden in the library on the second level. And find the book 'Veeshan's Children' by the water of the Dragon's Grove. Return to me when you are [ready] to be tested.");
    quest::assigntask(600245); # Myjinn's Enlightenment
  }
  if ($text=~/ready/i) {
    if (quest::istaskactivityactive(600245, 3)) {
      quest::say("Very well. What was the name of the great ogre city we now inhabit? [Nokk], [Katta] or [Takk]?");
    }
    else {
      quest::say("You are not yet ready. Gather the three sources of knowledge first.");
    }
  }
  if ($text=~/Nokk/i) {
    quest::say("Correct! The ogre city of Nokk. And which plane did Rallos Zek and his minions invade, cursing all of the war god's creations? The [Plane of Earth], the Plane of Fire, or the Plane of Water?");
  }
  if ($text=~/Plane of Earth/i) {
    quest::say("Yes! The Plane of Earth. Last of all: the drakkin are created by the touch of a dragon upon which mortal race? The [human race], the elven race, or the ogre race?");
  }
  if ($text=~/human race/i) {
    quest::say("The human race indeed! Your mind and knowledge are great, little one. Go in peace, seeker.");
    if (quest::istaskactivityactive(600245, 3)) {
      quest::updatetaskactivity(600245, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  if ($text=~/Katta/i || $text=~/Takk/i || $text=~/Plane of Fire/i || $text=~/Plane of Water/i || $text=~/elven race/i || $text=~/ogre race/i) {
    quest::say("No, no, no. Go back to your books, little one, and return when you are [ready] to answer truly.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("A banner, and well sewn. The city thanks you. Now - would you exercise your [intellect] for me?");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  plugin::return_items(\%itemcount);
}
