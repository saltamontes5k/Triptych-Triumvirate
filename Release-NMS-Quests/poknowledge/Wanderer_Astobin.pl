#Wanderer_Astobin.pl
#Druid PoP Spells
# items: 59602, 29112, 26943, 28524, 28525, 28526, 28564, 21656, 28527, 28528, 28529, 28530, 29131, 21658, 21659, 28531, 28532, 28533, 28535, 28536, 28538, 21657, 28534, 28537, 28539, 28540, 29132, 28645, 28541, 28542, 28543

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings traveler. I am Wanderer Astobin, warden of nature and guardian of Tunare's most blessed and sacred of treasures -- life and balance. I have pledged my existence to upholding this vow and even here, that vow remains. Though I no longer carry my scimitar or scout the wilds of the world as one of its many guardians, my pledge shall remain whole through my guidance of others whose pledge is akin to mine. If you are a druid -- your deity matters not -- then allow me to guide you if I may. What spells I have scribed are for you to search through and purchase should you find them worthy of your abilities. If through your travels in the outer planes you discover incorporeal items seemingly of an arcane nature, do not disregard them. I am well-trained in the ways and manner of planar magic and will be more than willing to turn these fledgling arcane items into tangible spells suited for those of druidic vows.");
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins for Ethereal Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29112);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (26943, 28524, 28525, 28526, 28564, 21656, 28527, 28528, 28529, 28530, 28523); #Level 61 or 62 Druid spell, PoP (Earthen Roots, Storm's Fury, Hand of Ro, Winter's Storm, Catastrophe, Flight of Eagles, Immolation of Ro, Karana's Rage, Nature's Might, Ro's Illumination, Replenishment)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "respectfully accepts the item, holding it in his hands like one would a delicate and priceless relic. His eyes scan its every surface in a detailed study before he closes his eyes and begins to weave a chant of unknown dialect and origin. As the druid's voice filters softly through the area, the object in his hand begins to fade into this existence, its intangible state destroyed beneath the druid's magic. Runes begin to appear upon the fully manifested scroll -- runes of a druidic decent. The druid ceases his chanting and then slowly hands the item to you.", "say", "This is a spell of great power. Use it wisely and with caution, for to abuse the gifts of nature is to corrupt our sole purpose.");
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
    my @valid_rewards = (59602, 21658, 21659, 28531, 28532, 28533, 28535, 28536, 28538, 21657, 28534, 28537, 28539, 28540); #Level 63 or 64 Druid spell, PoP (Protection of the Nine, Destroy Summoned, Blessing of Replenishment, E'ci's Frosty Breath, Nature's Infusion, Command of Tunare, Swarming Death, Shield of Bracken, Karana's Renewal, Protection of Seasons, Savage Roots, Summer's Flame, Brackencoat)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "respectfully accepts the item, holding it in his hands like one would a delicate and priceless relic. His eyes scan its every surface in a detailed study before he closes his eyes and begins to weave a chant of unknown dialect and origin. As the druid's voice filters softly through the area, the object in his hand begins to fade into this existence, its intangible state destroyed beneath the druid's magic. Runes begin to appear upon the fully manifested scroll -- runes of a druidic decent. The druid ceases his chanting and then slowly hands the item to you.", "say", "This is a spell of great power. Use it wisely and with caution, for to abuse the gifts of nature is to corrupt our sole purpose.");
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
    my @valid_rewards = (28645, 28541, 28542, 28543); #Level 65 Druid spell, PoP (Legacy of Bracken, Blessing of the Nine, Winter's Frost, Mask of the Forest)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "respectfully accepts the item, holding it in his hands like one would a delicate and priceless relic. His eyes scan its every surface in a detailed study before he closes his eyes and begins to weave a chant of unknown dialect and origin. As the druid's voice filters softly through the area, the object in his hand begins to fade into this existence, its intangible state destroyed beneath the druid's magic. Runes begin to appear upon the fully manifested scroll -- runes of a druidic decent. The druid ceases his chanting and then slowly hands the item to you.", "say", "This is a spell of great power. Use it wisely and with caution, for to abuse the gifts of nature is to corrupt our sole purpose.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
