# Demeton, Destroyer of Life - The Steppes
# The Serpent's Spine :: Portal of War raid event, final phase.

sub EVENT_SPAWN {
  quest::emote("steps through the portal, and where he walks the grass dies.");
  quest::say("I AM THE END OF GREEN THINGS. I AM DEMETON.");
  quest::setnexthpevent(50);
}

sub EVENT_HP {
  if ($hpevent == 50) {{
    quest::emote("blinds all before him with a plague of darkness!");
    quest::setnexthpevent(25);
  }}
}

sub EVENT_DEATH {
  quest::ze(15, "Demeton, Destroyer of Life, has fallen. The Portal of War falls silent once more.");
  quest::set_data('portal_of_war_active', '0');
  quest::set_data('portal_render_down', '0');
  quest::set_data('portal_crusher_down', '0');
}
