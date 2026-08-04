# Coldain Ring: Quest 2
# items: 30265, 30266, 30267

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello stranger, I am Boridain, master hunter of the Coldain. Glad to meet you.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 30265 => 1)) {
    quest::say("Say! This looks just like the axe my uncle uses. With this I can kill the beast for sure!... Ah, who am I kidding, I'm no hunter. I'll never be a hunter. I may as well give up and become a miner like dad... AH WATCH OUT!");
    quest::spawn2(116545, 231, 0, 1559, -2304, 313, 251); #Kodiak

  }
  elsif (plugin::check_handin(\%itemcount, 30266 => 1)) {
    quest::say("Yes! I've done it! The vile beast is finally dead. I will at last be revered as the mighty hunter I am. Here is your axe back, I broke it on the killing blow. Take it as proof that you are a friend of the greatest hunter in the history of the Coldain!");
    quest::summonitem(30267); # Item: Broken Axe
    quest::exp(5000);
  }
}


# OHNOBEAR
