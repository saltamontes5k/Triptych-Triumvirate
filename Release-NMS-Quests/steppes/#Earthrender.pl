# Earthrender - The Steppes
# The Serpent's Spine :: Portal of War raid event, phase 4 (with Earthcrusher).

sub EVENT_DEATH {
  quest::set_data('portal_render_down', '1', '7200');
  if (quest::get_data('portal_crusher_down') >= 1) {
    quest::set_data('portal_render_down', '0');
    quest::set_data('portal_crusher_down', '0');
    quest::ze(15, "Both golems are rubble. From the portal steps Demeton, Destroyer of Life!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    quest::unique_spawn(1120002377, 0, 0, $x, $y, $z, 0);
  }
  else {{
    quest::emote("shudders and cracks. Its twin still stands!");
  }}
}
