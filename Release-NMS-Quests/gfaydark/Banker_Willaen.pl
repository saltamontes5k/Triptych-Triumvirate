sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello $name. How may I help you?");
   }
  if($text=~/Gobbles/i){
    quest::say("That bastard guard? Haha! The rumor is that a dark elf ripped his heart out and [cursed] him to live forever as a beast. But what would I know? That is just a rumor.");
    }
     if($text=~/curse/i){
    quest::say("Technically, a curse could be broken if order was restored. But, like I said, what do I know?");
    }
}