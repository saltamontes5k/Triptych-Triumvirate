# items: 19315, 19322, 19318, 19319, 19329, 19320, 19324, 19317
sub EVENT_SAY {
  if($text=~/hail/i){
    quest::say(" It is good to see our numbers growing on this land. Welcome! May your travels be as prosperous as mine have. There are many [new powers] to be gained from this land.");
    return;
  }
  if($text=~/new powers/i){
    quest::say(" The new powers are scrolls that give us access to new and powerful spells. My collection is almost complete. I am simply [lacking] four more and then I will return back to the homeland.");
    return;
  }
  if($text=~/lacking/i){
    quest::say(" I am missing the scroll Atol's Spectral Shackles, Tears of Druzzil, Inferno of Al'kabor, and Pillar of Frost. Should you run into one, bring it to me and I'll perform an exchange for another scroll.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19315, 19322, 19318, 19319); #Item(s): Spell: Atol's Spectral Shackles, Spell: Inferno of Al'Kabor, Spell: Pillar of Frost, Spell: Tears of Druzzil
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19329, 19320, 19324, 19317); # Item(s): Spell: Tears of Solusek (19329), Spell: Abscond (19320), Spell: Thunderbolt (19324), Spell: Tishan`s Discord (19317)
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
#END of FILE Zone:overthere  ID:84166 -- Utandar Rizndown