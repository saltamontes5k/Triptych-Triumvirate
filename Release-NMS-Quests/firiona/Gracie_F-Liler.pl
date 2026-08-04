# items: 19378, 19269, 19384, 19374, 19386, 19379, 19381, 19215
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("It's so good to see new faces, not to mention more adventurers in this area. On some nights, the sounds that come from the nearby hills will scare even the hardiest of travelers. I volunteered in the name of the Keepers of the Art to help locate any [new spell scrolls] that might surface. Maybe you will have a successful journey and find some of these scrolls yourself.");
    return;
  }
  if ($text=~/new spell scrolls/i) {
    quest::say("I have recently come into possession of some of these scrolls. They seem to be very promising in adding to the strengths of our occupation. Some more good news is that I have a few extra of these scrolls. Perhaps you might have or find an extra of your own and be willing to trade? In case you are interested, I am looking for the scrolls Theft of Thought, Color Slant, Cripple, and lastly Dementia. Bring me one of these and I'll make an even trade.");
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
#END of FILE Zone:firiona  ID:84169 -- Gracie_F`Liler