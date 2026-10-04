# Nedelcu - Goru`kar Mesa
# The Serpent's Spine :: Nedelcu task pair (tasks 600643-600644).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600643)) {
      quest::say("[Gravel] does not make itself. The stonehide oreads are practically made of it.");
    }
    elsif (quest::istaskactive(600644)) {
      quest::say("Their [hair] still eludes you? Pull harder.");
    }
    elsif (!quest::istaskcompleted(600643)) {
      quest::say("I need [gravel] for my mixer, and the oreads are walking quarries. Six stonehides, ground fine.");
    }
    elsif (!quest::istaskcompleted(600644)) {
      quest::say("And a softer matter: [hair]. Oread hair, four locks, for my finest rope.");
    }
    else {
      quest::say("Gravel and rope, rope and gravel. A mason wants for nothing else, $name.");
    }
  }
  if ($text=~/gravel/i && !quest::istaskactive(600643) && !quest::istaskcompleted(600643)) {
    quest::say("Slay six oread stonehides and the mesa will do the grinding for you. Report back when the dust settles.");
    quest::assigntask(600643);
  }
  if ($text=~/hair/i && quest::istaskcompleted(600643) && !quest::istaskactive(600644) && !quest::istaskcompleted(600644)) {
    quest::say("Loot four locks of oread hair and deliver them to me. Gently, if you can manage it.");
    quest::assigntask(600644);
  }
}

sub EVENT_ITEM {
  # Consume the hair only while Nedelcu #2 is active (task system handles
  # completion); anything else is returned by the handin system.
  if (quest::istaskactive(600644)) {
    plugin::check_handin(\%itemcount, 88134 => 4);
  }
  plugin::return_items(\%itemcount);
}
