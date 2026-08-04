# items: 10059, 17045, 12829, 12940
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Well hello there. I am new to the bank. I am helping the Fargins out since it is so busy lately. Mr. Fargin doesn't even have time for his [hobby] these days.");
    return;
  } 
  if ($text=~/hobby/i) {
    quest::say("'Mr. Fargin used to collect rare coins and gems. He came to Firiona Vie to do just that, but now he never has the time to [collect rare coins] since he is always working here. That is why I came to help him out.");
    return;
  } 
  if ($text=~/collect rare coins/i) {
    quest::say("If you want to help, you can begin by replacing Mr. Fargin's prized Star of Odus which was taken from his vault when he stepped out to dine one night. Do so, and I may trust you to collect coins. I will also reward you with an item a composer left here. With Mr. Fargin's approval of course.");
    return;
  } 
}

sub EVENT_ITEM {
  # You can purchase a Star of Odus for about 115pp in the jewel shop under the Erudin palace. 
  # Giving it to Buford results in a "Tin Box" with 6 slots. 
  if (quest::handin({ 10059 => 1 })) {
    quest::say("Thank you!! I never could have gone to Odus to replace this. Perhaps now you can collect some rare coins.");
    quest::summonitem(17045); # Item: Tin Box
    return;
  }
  # put the 6 coins into the tin box, combine, and return it to Bufford, get Nostrolo Tambourine
  if (quest::handin({ 12829 => 1 })) {
    quest::emote("Assistant Buford takes the box, reaches into a crate and grabs a tambourine to give you. 'Great!! Now, my collection is almost complete. Here is a gift. A composer accidently left behind a crate of these, perhaps it can be of some use to you.'");
    quest::exp(10000);
    quest::summonitem(12940); # Item: Nostrolo Tambourine
    quest::faction(248,10); #inhabitants of firiona
    quest::faction(326,10); #emerald warriors
    quest::faction(312,10); #storm guard
    quest::faction(441,-30); #legion of cabilis
    quest::faction(313,-30); #pirates of gunthak
    return;
  }
}

# Nostrolo Tambourine, Firiona Vie, Assistant Bufford (id 84201) 