# Butcher Katorr - Crescent Reach (raised platform behind the bank)
# The Serpent's Spine :: Vakk'dra's Shadow (task 600247)
# Gives the Piece of Acrid Meat (84217).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600247, 2)) {
      quest::say("Acrid meat? For Vakk`dra's little ceremonies, is it? Hmph. I cure it just as he asks and I still don't want to know why. Here - and don't come back sniffing around my block.");
      quest::updatetaskactivity(600247, 2, 1);
      quest::summonitem(84217); # Piece of Acrid Meat
    }
    else {
      quest::say("Fresh cuts, smoked haunches and the best sausages in the Reach. Step up!");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
