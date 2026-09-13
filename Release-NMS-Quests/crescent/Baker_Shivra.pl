# Baker Shivra - Crescent Reach (inn, second level)
# The Serpent's Spine :: Slightly Less Than One-Half of a Baker's Dozen
# (task 600249) and Party Preparation (task 600250), both level 5+.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600249) && !quest::istaskactive(600249)
      && !quest::istaskcompleted(600250) && !quest::istaskactive(600250)) {
      quest::say("Oh, vasha, $name. I'm sorry if I seem distracted, but I'm busy, busy, busy! Between my [work] for the Scions of the Six and my own special [experiments], I never seem to have a break! A new city has so many needs. A new people even more as we try to define and learn who we are.");
    }
    elsif (quest::istaskactive(600249)) {
      quest::say("Six truffles from the sporelings of the first cave - then my flan at last!");
    }
    elsif (quest::istaskactive(600250)) {
      quest::say("The crate is in the puma cave, midway in. Please hurry back, the meal is almost ready!");
    }
    else {
      quest::say("Vasha, friend. Try the flan - I have it on very good authority that it is excellent.");
    }
  }
  if ($text=~/experiments/i) {
    quest::say("Yes, well, it just gets so boring making the same old recipes over and over again! So I like to add a little extra sometimes to bring out the true flavors of the dish. Right now I'm working on my [flan] recipe. You can try it when it's done, if you want!");
  }
  if ($text=~/flan/i) {
    quest::say("Well truth be told I still need a few ingredients to make it perfect. I don't suppose you'd like to [gather] them for me would you? I'll give you the first taste if you do.");
  }
  if ($text=~/gather/i) {
    quest::say("Excellent! It should be really easy to get the ingredients. I'd go myself but I'm, ah, allergic to mushrooms. Have to be really careful when baking, but it's worth it, you know! Anyway if you can get me six truffles from the Mushroom Grove I can finally complete my special flan!");
    quest::assigntask(600249); # Slightly Less Than One-Half of a Baker's Dozen
  }
  if ($text=~/work/i) {
    quest::say("Oh, yes, the Council relies on me to cater all of their most important meetings. Why right now I'm putting together a fabulous meal for the next Council meeting. Truth be told I'm a little behind and could use some [help] if you're not busy. Figuring out what a drakkin's tastes are is exhausting work.");
  }
  if ($text=~/help/i) {
    quest::say("The Councilors just love my fizzy lemonade and they always request it when I prepare a meal for them. The problem is I don't have enough, thanks to my former assistant Uliean. Uliean decided he'd had too much of this city and decided to try his hand living in the wild for a bit. When he [left] he took a crate of my fizzy lemonade with him!");
  }
  if ($text=~/left/i) {
    quest::say("He said he was heading for the caves outside the lower level of the city, in the Stone Hollow. He had some crazy idea about living in the wild and getting back to nature. Could you go [look] for him and bring back a full bottle of my fizzy lemonade? It would really save me if you could!");
  }
  if ($text=~/look/i) {
    quest::say("Oh, you will? Great, that's really great, $name! Please hurry back, the meal is almost ready!");
    quest::assigntask(600250); # Party Preparation
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 52637 => 6)) { # 6 Tasty Truffles
    quest::say("Six truffles, and not one squashed! You have my thanks - and the first taste of the flan, as promised. Bite-size nutty flan. How she'll manage that is a mystery, but it IS good.");
    if (quest::istaskactivityactive(600249, 1)) {
      quest::updatetaskactivity(600249, 1, 1);
    }
    quest::summonitem(53487, 5); # Pocket Flan Dessert x5
    return;
  }
  plugin::return_items(\%itemcount);
}
