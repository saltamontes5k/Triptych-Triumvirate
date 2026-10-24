# a wounded kobold - Icefall Glacier
# The Serpent's Spine :: Chief Urgak raid event
# Hail and say "help" to trigger the kobold assault. Clear both waves and
# Chief Urgak joins the fight. 1120002370 = #Chief_Urgak

sub EVENT_SAY {
  if ($text=~/help/i) {
    my $done = quest::get_data('icefall_urgak_event');
    if ($done >= 1) {
      quest::say("The chief already fights. Finish it!");
      return 1;
    }
    quest::say("You would help a kobold of the Nightmoon? Then help! The Coldeye come - STAND READY!");
    quest::set_data('icefall_urgak_event', '1', '3600');
    quest::emote("howls a war cry across the glacier. From the ridgeline, kobolds answer!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    foreach my $id (400197, 400218, 400217, 400197, 400218, 400217, 400197) {
      quest::spawn2($id, 0, 0, $x + int(rand(60)) - 30, $y + int(rand(60)) - 30, $z, 0);
    }
    quest::settimer('urgak_wave2', 20);
  }
}

sub EVENT_TIMER {
  if ($timer eq 'urgak_wave2') {
    quest::stoptimer('urgak_wave2');
    quest::emote("shrieks a warning as the second wave crests the ridge!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    foreach my $id (400218, 400217, 400197, 400218, 400217, 400197, 400218) {
      quest::spawn2($id, 0, 0, $x + int(rand(70)) - 35, $y + int(rand(70)) - 35, $z, 0);
    }
    quest::settimer('urgak_boss', 25);
  }
  if ($timer eq 'urgak_boss') {
    quest::stoptimer('urgak_boss');
    quest::set_data('icefall_urgak_event', '2', '14400');
    quest::emote("bellows with rage as Chief Urgak himself stomps onto the ice!");
    quest::ze(15, "Chief Urgak has come to crush the intruders!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    quest::unique_spawn(1120002370, 0, 0, $x + 40, $y + 20, $z, 0);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
