# a Holmguard elite - Valdeholm (TSS instanced raid encounter, npc 600112)
# Players carrying "Letters of Evidence" (88194) may turn these guards against Udengar.

sub EVENT_SAY {
  if ($text=~/evidence of treason/i) {
    quest::say("What evidence is this, invader? Be quick or die.");
  }
  elsif ($text=~/hail/i) {
    quest::say("Be gone, invader. This is no place for you.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 88194 => 1)) {
    quest::emote("looks at the documents you have given him.");
    quest::say("So be it. Udengar's fate is in the hands of the god now. If you can slay him, then I will believe that you are in the right. If not, you will meet your ancestors and they will be shamed by your life and the manner of your death.");
    quest::depop();
  }
  plugin::return_items(\%itemcount);
}
