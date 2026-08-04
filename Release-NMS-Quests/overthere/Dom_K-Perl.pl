# items: 10029, 18068
sub EVENT_SAY {
  if($text=~/hail/i){
    quest::say("Welcome to my little refuge of the mind. Here you may find passage to the grand worlds within a fine book. I have few books for sale, but any good book is rare in the realm of Norrath. On occasion, I even have [rare finds]. Be sure to use good lighting when reading. Strain the brain, not the eye, I always say.");
    return;
  }
  if($text=~/rare finds/i){
    quest::emote("starts rummaging through a pile of books and scrolls.");
    quest::say("Oh yes, yes, yes. Rare books occasionally make their way to me. Ahhh!! I have one title, Before Green. Sounds like a bit of fiction. What would you like to [purchase]?");
    return;
  }
  if($text=~/purchase/i){
    quest::emote("puts on a monocle and begins to look over the book.");
    quest::say("Hmmmm, Looks fairly valuable. In honor of the book's title, I shall allow you to trade for it with a fine emerald. What a bargain!");
    return;
  }
  if($text=~/scribed tome pages/i){
    return;
    quest::say("I can create a special magic scribed tome page. It has no words, but is not meant to be read. To create one, I will need some illweed parchment and my fee of 2 gold pieces. Once I have these, you may have one scribed tome page.");
  }
  if($text=~/tome binder/i){
    quest::say("I have a tome binder with the title 'The Origins of Pain'. Sounds like good reading, but it appears to be missing the pages it once held. If you want it, I shall give it to you for a bottle of blood ink from Cabilis and my spare reading spectacles.");
    return;
  }
  if($text=~/spectacles/i){
    quest::say("My spare reading spectacles were stolen by froglok raiders in the swamps. I gave chase but the little buggers hop faster than I run. They were hopping with such fury that they dropped a [tome binder].");
    return;
  }
  if($text=~/secret of the binder/i){
    quest::say("The secret of the magic binder is simple. I know the original tome pages, when reinserted, will magically lock the tome. I also know the original tome pages, when reinserted, will magically lock the tome. I also know another way to magically lock the book without using the pages at all. All you need is a [scribed tome page] and use it in place of the original page. Once combined in the binder with the same amount of original pages... Bam! One magically locked tome. Who would know the difference?");
    return;
  }
}
sub EVENT_ITEM {
  if(quest::handin({ 10029 => 1 })){ # Item(s): 10029 - Emerald
    quest::exp(500);
    quest::summonitem(18068); # Item: Before Green
    return;
  }

  if(quest::handin({ "gold" => 2, 12389 => 1 })){ # Item(s): 12389 - Illweed
    quest::exp(500);
    quest::summonitem(12390); # Item: Scribed Tome Page
    quest::say("Here is your magically scribed tome page.");
    return;
  }

# TODO - this turnin is missing the blood ink item/quest - https://everquest.allakhazam.com/db/quest.html?quest=197
# TODO - this turnin is missing item 12387 Blood Ink in the database
  if(quest::handin({ 12387 => 1, 12383 => 1 })){ # Item(s): 12387 - Blood Ink, 12383 - Lens of Sorts
    quest::exp(500);
    quest::summonitem(17018); # Item: Tome Binder
    quest::say("As I stated, here is your tome binder. You know, I know the [secret of the binder]. I am no fool.");
    return;
  }
}

#END of FILE Zone:Overthere ID:93148 Dom_K`Perl (Dom_K-Perl.pl)