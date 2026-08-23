#Channeler Olaemos.pl
#Wizard PoP Spells
# items: 59627, 59629, 59528, 59624, 28439, 29112, 26944, 28413, 28438, 28437, 21662, 28440, 28441, 28442, 29131, 28414, 28445, 28446, 28448, 26940, 28415, 28444, 28447, 29132, 26942, 21663, 28443, 28450

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings, $name. I am channeler Olaemos, one of five scholars in the art of evocation to reside here in Myrist. We have volunteered to temporarily halt our personal quests for knowledge and power beyond the material world so that we may aid the travelers in our midst. The spells we have scribed are native to your world, though in our hands they are available to all practitioners of the evocational arts despite race or religious differences. There is one other thing that I can aid you with should you truly be a wizard and that is the scribing of a most foreign and potent spell. I require you to find a piece of the untainted, fledgling magical manifestations upon the plane. These items appear as scrolls or runes that seem mundane to the eyes of mortals, though they are far more powerful than you realize. If you are fortunate enough to stumble across such a treasure, do not discard it but return it to me and I shall turn it into a power most befitting of the plane's travelers.");
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
    my @valid_rewards = (28439, 26944, 28413, 28438, 28437, 21662, 28440, 28441, 28442); #Level 61 or 62 Wizard spell, PoP (Greater Fetter, Shield of the Arcane, Tears of Ro, Resistant Armor, Teleport, Elemental Barrier, Draught of Ro, or Lure of Ro)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "almost brashly snatches the item out of your grip with his small, cold froglok hands. The wizard eyes the item quickly, nodding and mumbling to himself at an inaudible tone. Eventually, the wizard begins to weave a spell around the item, which seems to become saturated with the conjured magic. Runes of a brilliant, shimmering azure appear upon the parchment, which is now wholly tangible in its form. As the spell ends, the forglok inspects his work one last time before offering the spell to you.", "say", "Take this, $name. Do not use it without caution or discipline, for the power is unlike anything you have wielded in the past. It will affect both the divine and primal realms, despite its astral birth.");
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
    my @valid_rewards = (59627, 59629, 59528, 59624, 28414, 28445, 28446, 28448, 26940, 28415, 28444, 28447); #Level 63 or 64 Wizard spell, PoP (Force Shield, Draught of Thunder, Agnarr's Thunder, Iceflame of E'ci, Tears of Arlyxir, Shield of Maelin, Telekin, or Draught of E'ci)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "almost brashly snatches the item out of your grip with his small, cold froglok hands. The wizard eyes the item quickly, nodding and mumbling to himself at an inaudible tone. Eventually, the wizard begins to weave a spell around the item, which seems to become saturated with the conjured magic. Runes of a brilliant, shimmering azure appear upon the parchment, which is now wholly tangible in its form. As the spell ends, the forglok inspects his work one last time before offering the spell to you.", "say", "Take this, $name. Do not use it without caution or discipline, for the power is unlike anything you have wielded in the past. It will affect both the divine and primal realms, despite its astral birth.");
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
    my @valid_rewards = (26942, 21663, 28443, 28450); #Level 65 Wizard spell, PoP (Shock of Magic, Greater Decession, Tears of Marr, or Strike of Solusek)
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "almost brashly snatches the item out of your grip with his small, cold froglok hands. The wizard eyes the item quickly, nodding and mumbling to himself at an inaudible tone. Eventually, the wizard begins to weave a spell around the item, which seems to become saturated with the conjured magic. Runes of a brilliant, shimmering azure appear upon the parchment, which is now wholly tangible in its form. As the spell ends, the forglok inspects his work one last time before offering the spell to you.", "say", "Take this, $name. Do not use it without caution or discipline, for the power is unlike anything you have wielded in the past. It will affect both the divine and primal realms, despite its astral birth.");
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