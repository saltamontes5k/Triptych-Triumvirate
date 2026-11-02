#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - Vizier Zio (416140)
# Tasks: Seeking Revenge (620127), Death Sentence (620130) -> the Smudged
# Pottery Shard and Smudged Pottery Piece. Death Sentence uses the vial of
# thick green fluid: summoned fresh on every active-task hail, consumed by
# each delivery to the loyalist agents in Silyssar.
#--------------------------------------------------------------------------
my @order = (620127, 620130);
my %tasks = (
  620127 => ['revenge', 'The traitors who kept the old emperor\'s leash: Morduz, Ail`zhin, Tizlrim. My [revenge] walks on your legs.'],
  620130 => ['sentence', 'The [sentence] is carried in a vial. Take it to the loyalist agents Lirzzha, Mordezh, and Hi`szhia -- each must taste it before the traitors return.'],
);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(620130)) {
      quest::say("The vial, courier. Fresh from the deep stills -- one swallow is a verdict.");
      quest::summonitem(33897);
      return;
    }
    my $next = -1;
    for my $t (@order) {
      if (!quest::istaskcompleted($t)) { $next = $t; last; }
    }
    if ($next >= 0) {
      quest::say($tasks{$next}[1]);
    } else {
      quest::say("The traitors are ash and the loyalists remember your name, $name.");
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("The vial is yours already. Deliver it.");
    } else {
      quest::assigntask($tid);
      if ($tid == 620130) {
        quest::say("Here is the vial. The agents hide in the side chambers -- clear the rooms before you knock.");
        quest::summonitem(33897);
      } else {
        quest::say("Go. Make it slow.");
      }
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
