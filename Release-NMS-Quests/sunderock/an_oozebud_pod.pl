# an oozebud pod - Sunderock Springs
# Part of Anaglass' "The Sulfur Springs" (600421). Destroying a pod bursts it
# open and 2-4 oozebuds spill out.

sub EVENT_DEATH {
  my $x = $npc->GetX();
  my $y = $npc->GetY();
  my $z = $npc->GetZ();
  my $n = 2 + int(rand(3));   # 2..4
  for (my $i = 0; $i < $n; $i++) {
    quest::spawn2(600265, 0, 0, $x + int(rand(21)) - 10, $y + int(rand(21)) - 10, $z, 0);
  }
  quest::emote("bursts, spilling oozebuds across the bog.");
}
