sub EVENT_SAY
{


  if($text=~/Hail/i)
    {
      quest::say("Hail $name! I am the Keeper of Knowledge. I can teach you [spells] if you are interested?");
    }
    
    elsif($text=~/spells/i)
      {
        quest::say("Which level range of spells would you like to learn? [0-10] [11-20] [21-30] [31-40] [41-50]?");
      }
        elsif($text=~/10/i)
          {
            quest::say("Hand me 10 platinum for your spells");
          }
	elsif($text=~/20/i)
          {
            quest::say("Hand me 50 platinum for your spells");
          }
	elsif($text=~/30/i)
          {
            quest::say("Hand me 100 platinum for your spells");
          }
 	elsif($text=~/40/i)
          {
            quest::say("Hand me 200 platinum for your spells");
          }
	elsif($text=~/50/i)
          {
            quest::say("Hand me 300 platinum for your spells");
          }

}

sub EVENT_ITEM{
  if ($platinum ==10){
  quest::scribespells(10, 1);
}
 if ($platinum ==50){
  quest::scribespells(20, 11);
}
if ($platinum ==100){
  quest::scribespells(30, 21);
}
if ($platinum ==200){
  quest::scribespells(40, 31);
}

if ($platinum ==300){
  quest::scribespells(50, 41);
}
plugin::return_items(\%itemcount);
}