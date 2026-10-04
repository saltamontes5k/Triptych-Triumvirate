# Ciodaru - Goru`kar Mesa
# The Serpent's Spine :: Ciodaru and Kathryn romance series (600665-600676).
# Live's tradeskill crafting steps (jewelry, brewing, tailoring, smithing,
# pottery, fletching) are condensed into kill/loot/hail beats; the narrative
# milestones - the Tuffein attacks and Razvan - are kept intact.

sub EVENT_SAY {
  my $n = 600665;
  my @done = map { quest::istaskcompleted($_) } (600665..600676);
  if ($text=~/hail/i) {
    my @active = grep { quest::istaskactive($_) } (600665..600676);
    if (@active) {
      my %status = (
        600665 => "Ask [Kathryn] how she fares, atop the mesa. Then come straight back.",
        600666 => "Nailah in Crescent Reach knows [gems]. And the snakes owe me a fang or six.",
        600667 => "Pure spring [water] from the murkwater oozes. Eight should fill the flask.",
        600668 => "To Kathryn! The Tuffein [guards] shadow her. Cut them down.",
        600669 => "Napaea [perfume] - six protectors will yield the essence.",
        600670 => "A [dress] of recluses and snakes. Six and four, when you can.",
        600671 => "The [medics] again. Two of them, before she even notices the danger.",
        600672 => "A [venom sac] for the pendant's charm, and four highland snakes.",
        600673 => "The [widows] spin the finest thread. Eight, please.",
        600674 => "They grow [bolder]. Two guards, two medics.",
        600675 => "[Razvan] hides in the Tuffein camp. This ends where it began.",
        600676 => "One [feather] pair for the gift box, then to Kathryn, then to me.",
      );
      quest::say($status{$active[0]});
    }
    elsif (!$done[0]) {
      quest::say("You there. You have the look of someone who [walks] far. I have someone I cannot reach.");
    }
    elsif (!$done[11]) {
      my @ids = (600665..600676);
      for my $i (0..11) {
        if (!$done[$i]) { quest::say($status{$ids[$i]}); last; }
      }
    }
    else {
      quest::say("She said yes, $name. She said yes! You will drink at the wedding, or I will know why not.");
    }
  }
  if ($text=~/walk/i && !quest::istaskactive(600665) && !quest::istaskcompleted(600665)) {
    quest::say("Kathryn - a dryad of the high mesa. I am. . . taken with her, and too proud to say it badly. Ask her how she does, and return to me.");
    quest::assigntask(600665);
  }
  if ($text=~/gems/i && quest::istaskcompleted(600665) && !quest::istaskactive(600666) && !quest::istaskcompleted(600666)) {
    quest::say("A gift, then. Jeweler Nailah in Crescent Reach can teach me what suits her - and six mesa snakes will pay for the silver.");
    quest::assigntask(600666);
  }
  if ($text=~/water/i && quest::istaskcompleted(600666) && !quest::istaskactive(600667) && !quest::istaskcompleted(600667)) {
    quest::say("She drinks only the coldest, purest water. The murkwater oozes foul the springs - eight of them, cleared, and I will draw from the source.");
    quest::assigntask(600667);
  }
  if ($text=~/guards/i && quest::istaskcompleted(600667) && !quest::istaskactive(600668) && !quest::istaskcompleted(600668)) {
    quest::say("Tuffein guards were seen shadowing her path. You must hurry. Go to Kathryn, cut down any who threaten her, and tell me she is safe.");
    quest::assigntask(600668);
  }
  if ($text=~/perfume/i && quest::istaskcompleted(600668) && !quest::istaskactive(600669) && !quest::istaskcompleted(600669)) {
    quest::say("Her scent is the forest after rain. Six napaea protectors hold what I need to bottle it.");
    quest::assigntask(600669);
  }
  if ($text=~/dress/i && quest::istaskcompleted(600669) && !quest::istaskactive(600670) && !quest::istaskcompleted(600670)) {
    quest::say("A dress of shimmering silk! Six mesa recluses and four mesa snakes, and my needle will do the rest.");
    quest::assigntask(600670);
  }
  if ($text=~/medics/i && quest::istaskcompleted(600670) && !quest::istaskactive(600671) && !quest::istaskcompleted(600671)) {
    quest::say("Tuffein medics prowl her glade again. Two of them. This courtship is turning into a war.");
    quest::assigntask(600671);
  }
  if ($text=~/venom/i && quest::istaskcompleted(600671) && !quest::istaskactive(600672) && !quest::istaskcompleted(600672)) {
    quest::say("A pendant that guards her as I cannot: a mountain recluse venom sac from the Roost, and four highland snakes for the chain.");
    quest::assigntask(600672);
  }
  if ($text=~/widows/i && quest::istaskcompleted(600672) && !quest::istaskactive(600673) && !quest::istaskcompleted(600673)) {
    quest::say("For the shawl - eight mesa widows' worth of thread. She will wrap it around her shoulders and think of me.");
    quest::assigntask(600673);
  }
  if ($text=~/bolder/i && quest::istaskcompleted(600673) && !quest::istaskactive(600674) && !quest::istaskcompleted(600674)) {
    quest::say("Two guards and two medics this time. Someone pays them to keep me from her. I intend to learn who.");
    quest::assigntask(600674);
  }
  if ($text=~/Razvan/i && quest::istaskcompleted(600674) && !quest::istaskactive(600675) && !quest::istaskcompleted(600675)) {
    quest::say("The name is Razvan. He squats in the Tuffein camp and sells my love letters for spite. Scout their camp, end him, and return to me.");
    quest::assigntask(600675);
  }
  if ($text=~/feather/i && quest::istaskcompleted(600675) && !quest::istaskactive(600676) && !quest::istaskcompleted(600676)) {
    quest::say("Two sleek griffon feathers for the gift box - bring them to Kathryn with my whole heart, then come tell me what she says.");
    quest::assigntask(600676);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
