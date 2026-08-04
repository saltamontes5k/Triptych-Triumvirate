# items: 19238, 19244, 19232, 19234, 19235, 19233, 19236, 19240
sub EVENT_SAY {
  if($text=~/hail/i){
    quest::say("And a good day to you, too! I have traveled here in the name of the Jaggedpine Treefolk to search out any new and [wonderful powers] that would aid us in preserving the wildlife back home. I have not been able to venture far from this outpost as the inhabitants of the nearby woods pose a great danger. I have decided to wait for more of my Treefolk to arrive before adventuring further.  There's safety in numbers, they always say.");
    return;
  }
  if($text=~/wonderful powers/i){
    quest::say("From what I have gathered from the residents of this outpost and from others like myself, there are a fair number of scrolls to be found in the outlying areas.  These scrolls are said to contain new and powerful magic. I myself have found a few of these scrolls. But the problem is, I don't believe I have a complete collection. If you would care to [help] me, I'd be willing to trade some of the extra ones I have for some of the extras you may run across.");
    return;
  }
  if($text=~/help/i){
    quest::say("I am still looking for four scrolls that I have not been able to locate. They are the scrolls of Circle of Winter, Circle of Summer, Spirit of Scale, and Form of the Howler. If you bring any of these back, I'll give you one of four very rare scrolls in my possession."); }
    return;
  }

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19238, 19244, 19232, 19234); #Item(s): Spell: Spirit of Scale, Spell: Form of the Howler, Spell: Circle of Winter, Spell: Circle of Summer
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19235, 19233, 19236, 19240); # Item(s): Spell: Call of Karana (19235), Spell: Upheaval (19233), Spell: Egress (19236), Spell: Glamour of Tunare (19240)
    # Exp for each turned in item
    my $handin_exp = 1000;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("say", "Here is the scroll that I promised. We have both gained much knowledge today. I hope to do business with you again soon. Farewell!");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }
}
#END of FILE Zone:firiona  ID:84176 -- Samitha_Lightheart