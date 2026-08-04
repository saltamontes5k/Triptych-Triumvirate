#Pathfinder_Viliken.pl
#Ranger PoP Spells
# items: 59588, 29112, 26943, 21628, 21627, 29131, 26931, 26929, 26930, 21626, 29132, 21655, 26932

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings, friend, and welcome to New Tanaan. We have worked hard to properly greet you into our midst, and hope that our efforts shall not be in vain. As a ranger of Tunare in my former life upon Norrath, I have joined my fellow Pathfinders in scribing spells from memory of our journeys upon your world. These spells are not unique to the Plane of Knowledge, for they are the same as those Norrath offers to its guardians. However, they may be convenient for you to purchase here while you are browsing our libraries and engaging in the wonders of our beautiful, peaceful city. However, do not forget the scholars whilst you are engaging in the planes. You may stumble across a piece of pure arcane manifestation that may appear mundane at first, but with my help can become a spell of great power to all of nature's wardens.");
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
    my @valid_rewards = (26943, 21628, 21627); #Level 61 or 62 Ranger spell, PoP (Earthen Roots, Call of the Rathe, Strength of Tunare)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. Carefully, he inspects it -- nodding to himself in recognition of the item and planning of his next step. The ranger then begins a soft, melodic chant of priestly origin. You recognize the nature of the words to be a hym of the natural world, though you cannot decipher their meaning. The arcane object fades into existence, the runes etching themselves upon the surface become clear in their mat, neutral hues. Eventually, the ranger's chant ends and the object in his hand is complete. He then extends it to you in unconditional offering.", "say", "Use this wisely and with great respect for the power that has originated it. The primordial arcane powers of the divine worlds are not to be disrespected.");
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
    my @valid_rewards = (59588, 26931, 26929, 26930, 21626); #Level 63 or 64 Ranger spell, PoP (Frozen Wind, Nature's Rebuke, Spirit of the Predator, Brushfire)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. Carefully, he inspects it -- nodding to himself in recognition of the item and planning of his next step. The ranger then begins a soft, melodic chant of priestly origin. You recognize the nature of the words to be a hym of the natural world, though you cannot decipher their meaning. The arcane object fades into existence, the runes etching themselves upon the surface become clear in their mat, neutral hues. Eventually, the ranger's chant ends and the object in his hand is complete. He then extends it to you in unconditional offering.", "say", "Use this wisely and with great respect for the power that has originated it. The primordial arcane powers of the divine worlds are not to be disrespected.");
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
    my @valid_rewards = (21655, 26932); #Level 65 Ranger spell, PoP (Protection of the Wild, Cry of Thunder)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. Carefully, he inspects it -- nodding to himself in recognition of the item and planning of his next step. The ranger then begins a soft, melodic chant of priestly origin. You recognize the nature of the words to be a hym of the natural world, though you cannot decipher their meaning. The arcane object fades into existence, the runes etching themselves upon the surface become clear in their mat, neutral hues. Eventually, the ranger's chant ends and the object in his hand is complete. He then extends it to you in unconditional offering.", "say", "Use this wisely and with great respect for the power that has originated it. The primordial arcane powers of the divine worlds are not to be disrespected.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
