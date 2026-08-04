# items: 59644, 59806, 28451, 29112, 26944, 28413, 28643, 28644, 28452, 28453, 26947, 21665, 21667, 28455, 28457, 28469, 21639, 29131, 21666, 28458, 28460, 28461, 28464, 28415, 28459, 28465, 28468, 29132, 21648, 21664, 28470

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings traveler and welcome to the Plane of Knowledge! I am so pleased to see so many eager minds among us -- for it has been so long since I have had the meaningful presence of a pupil. If by chance you practice the art of Enchantments. then I might be of service to you. I have penned many spells from memory as a wandering enchanter and scholar of Norrath's history and though these spells are nothing unique or rare unto your world. they may provide some aid to you while you are here. Also. if you happen upon a seemingly meaningless item of arcane nature -- you will recognize these specific items I speak of by their corporeal state of existence -- then do not hesitate to take them up and return them to me. I know a thing or two regarding planar magic and can turn these seemingly mundane items into enchantments of great power.");
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins for Ethereal Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29112);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28451, 26944, 28413, 28643, 28644, 28452, 28453, 26947, 21665, 21667, 28455, 28457, 28469, 21639); #Level 61 or 62 Enchanter spell, PoP (Greater Fetter, Shield of the Arcane, Arcane Rune, Boggle, Howl of Tashan, Rune of Zebuxoruk, Pacification, Speed of Vallon, Guard of Druzzil, Strangle, Beckon, Word of Morell, Aeldorb's Animation)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item quite eagerly. With wide-eyes, the enchanter carefully examines every aspect of the fledgling arcane item. Eventually, she begins to weave a soft chant of arcane words -- their nature familiar to you of the art of enchantment, though they remain foreign in dialect and meaning. Eventually, the enchanter grows silent and the object cradled in her hands is whole and born anew. Golden runes line the tangible parchment -- runes of arcane enchantment. The enchantress then extends the item to you in gracious and unconditional offering.", "say", "You have done well in recovering this, $name. I am quite surprised that you were able to find one, for they are rare indeed. In any case, I have turned it into something that may prove useful to you as your journeys upon the planes continue.");
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
    my @valid_rewards = (59644, 59806, 21666, 28458, 28460, 28461, 28464, 28415, 28459, 28465, 28468); #Level 63 or 64 Enchanter spell, PoP (Night's Dark Terror, Torment of Scio, Tranquility, Uproar, Sleep, Shield of Maelin, Insanity, Command of Druzzil, Bliss)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item quite eagerly. With wide-eyes, the enchanter carefully examines every aspect of the fledgling arcane item. Eventually, she begins to weave a soft chant of arcane words -- their nature familiar to you of the art of enchantment, though they remain foreign in dialect and meaning. Eventually, the enchanter grows silent and the object cradled in her hands is whole and born anew. Golden runes line the tangible parchment -- runes of arcane enchantment. The enchantress then extends the item to you in gracious and unconditional offering.", "say", "You have done well in recovering this, $name. I am quite surprised that you were able to find one, for they are rare indeed. In any case, I have turned it into something that may prove useful to you as your journeys upon the planes continue.");
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
    my @valid_rewards = (21648, 21664, 28470); #Level 65 Enchanter spell, PoP (Illusion Froglok, Vallon's Quickening, Voice of Quellious)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item quite eagerly. With wide-eyes, the enchanter carefully examines every aspect of the fledgling arcane item. Eventually, she begins to weave a soft chant of arcane words -- their nature familiar to you of the art of enchantment, though they remain foreign in dialect and meaning. Eventually, the enchanter grows silent and the object cradled in her hands is whole and born anew. Golden runes line the tangible parchment -- runes of arcane enchantment. The enchantress then extends the item to you in gracious and unconditional offering.", "say", "You have done well in recovering this, $name. I am quite surprised that you were able to find one, for they are rare indeed. In any case, I have turned it into something that may prove useful to you as your journeys upon the planes continue.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
#Done, quest by Kilelen