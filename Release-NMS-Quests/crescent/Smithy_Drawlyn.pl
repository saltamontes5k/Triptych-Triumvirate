# Smithy Drawlyn - Crescent Reach (Artisans' Row, second level)
# The Serpent's Spine :: Ithakis' Challenge (task 600243)
# Gives the sword mold materials, and finishes the Flametouched Ceremonial
# Sword from the mold, ore and water (in place of the world forge).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600243, 3)) {
      quest::say("Eh? A customer - or one of Ithakis' hopefuls? Hah, I can see it in your eyes. The Flame-Sealed Box, is it? Very well. Take this mold, this ore and some water. The ore drinks the flame of the box; quench it and forge the blade, then bring it back to me for the fitting.");
      quest::updatetaskactivity(600243, 3, 1);
      quest::summonitem(84209); # Flametouched Ore
      quest::summonitem(13006); # Water Flask
      quest::summonitem(84208); # Ceremonial Sword Mold
    }
    elsif (quest::istaskactive(600243) && quest::istaskactivityactive(600243, 4)) {
      quest::say("Show me the blade, then. I'll not have Ithakis saying my work cracks.");
    }
    else {
      quest::say("Iron, fire and patience - the three virtues of the forge. Move along unless you have one of the three.");
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84208 => 1, 84209 => 1, 13006 => 1)) {
    # Ceremonial Sword Mold + Flametouched Ore + Water Flask
    quest::emote("works the glowing ore into the mold and quenches it with a hiss.");
    quest::say("Hmm. The metal took the flame oddly - as if it remembered being fire. Here: the Flametouched Ceremonial Sword. Let's see it finished.");
    quest::summonitem(84210); # Flametouched Ceremonial Sword
    return;
  }
  if (plugin::check_handin(\%itemcount, 84210 => 1)) { # Flametouched Ceremonial Sword
    quest::say("Sound work, for a first blade. Here - a note for Ithakis, so he knows the sword he gave you wasn't wasted.");
    quest::summonitem(84211); # Note to Ithakis
    if (quest::istaskactivityactive(600243, 4)) {
      quest::updatetaskactivity(600243, 4, 1);
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
