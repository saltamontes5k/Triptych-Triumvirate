# items: 19374, 19378, 19269, 19384, 19386, 19379, 19381, 19215
sub EVENT_SAY { 
  if($text=~/hail/i){
    quest::say("Hello, $name. This place is quite a formidable outpost, but it lacks the comforts of home. Once I have finished collecting some of my [missing scrolls], I'll be able to leave this place and all its hidden dangers.");
    return;
  }
  if($text=~/missing scrolls/i){
    quest::say("Travelers have been bringing back numerous scrolls from the depths of darkness in the Outlands. They contain arcane knowledge specific to our classes. Only four are left that I seek. Keep a wary out for Theft of Thought, Color Slant, Cripple, and Dementia. Return any one of these to me and your reward shall be a scroll that can be found nowhere else.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19378, 19269, 19384, 19374); #Item(s): Spell: Color Slant, Spell: Cripple, Spell: Dementia, Spell: Theft of Thought
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19386, 19379, 19381, 19215); # Item(s): Spell: Boon of the Clear Mind (19386), Spell: Clarity II (19379), Spell: Recant Magic (19381), Spell: Wake of Tranquility (19215)
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
#END of FILE Zone:overthere  ID:93098 -- Siladdarae_N`Riese 