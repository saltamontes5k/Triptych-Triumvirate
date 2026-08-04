#Primalist Saosith.pl
#Beastlord PoP Spells
# items: 29112, 28544, 28545, 21629, 28547, 28548, 29131, 28549, 28550, 21630, 28551, 28552, 29132, 28553, 28554, 59652

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Welcome, traveler, to New Tanaan. All citizens of New Tanaan have come together in welcoming Norrath's curious travelers who crave knowledge and a path to better themselves individually. What little help I alone can offer is extended to the Beastlords of Norrath, for as I was once one of them in a time long since past. If you are a Beastlord, then perhaps what spells that I have penned, though neither unique nor rare to your world, would be of use. If through your endeavors upon the planes you happen to come across fledgling manuscripts -- similar to those upon which a spell or song is scribed -- then you may return them to me if you wish. I am quite versed in the ways of planar magics relating to the Beastlord's focus.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins for Ethereal Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29112);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28544, 28545, 21629, 28547, 28548); #Level 61 or 62 Beastlord spell, PoP (Spirit of Arag, Infusion of Spirit, Healing of Sorsha, Scorpion Venom, Spiritual Vigor)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("say", "The magic you have given me is quite potent, it should be a simple task to use primal forces to focus its magic into a spell.", "emote", "closes her eyes and the object glows slightly in her hands.", "say", "Here, I hope this will prove of some use to you.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }

  # Check for our spell turnins for Spectral Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29131);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28549, 28550, 21630, 28551, 28552, 59652); #Level 63 or 64 Beastlord spell, PoP (Arag's Celerity, Spirit of Rellic, Frost Spear, Spiritual Dominion, Spirit of Sorsha)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("say", "The magic you have given me is quite potent, it should be a simple task to use primal forces to focus its magic into a spell.", "emote", "closes her eyes and the object glows slightly in her hands.", "say", "Here, I hope this will prove of some use to you.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }

  # Check for our spell turnins for Glyphed Rune Word
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29132);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28553, 28554); #Level 65 Beastlord spell, PoP (Sha's Revenge, Ferocity)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("say", "The magic you have given me is quite potent, it should be a simple task to use primal forces to focus its magic into a spell.", "emote", "closes her eyes and the object glows slightly in her hands.", "say", "Here, I hope this will prove of some use to you.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
