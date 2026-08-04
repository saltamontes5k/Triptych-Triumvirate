#Mystic_Abomin.pl
#Shaman PoP Spells
#The level 64 spell scroll Talisman of Celerity isn't in my copy of the db, so it's not in this quest. Added by renoofturks spell talisman of alacrity
# items: 59615, 29112, 28487, 28488, 28489, 28490, 26945, 26946, 21660, 21661, 28491, 28492, 28493, 28494, 28523, 29131, 28495, 28496, 28497, 28498, 28499, 28531, 26910, 26912, 26913, 26914, 26911, 29132, 26915, 26916, 26917, 26918, 26919

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("The mystics of New Tanaan embrace your presence among us most kindly - regard us as a friend and mentor, should you need our guidance we have offered our services to the shamans of Norrath that venture in our city. Though our guidance is that of spells native to your world, the mystic scribes in this city may hold some convenience for we do not hold the prejudice of the material world's citizens. Beyond these familiar scrolls, I may be able to aid you further should you bring me a fledgling arcane item from the planes. You will know of that which I speak if and when you stumble upon such a rare and seemingly mundane item. Do not be fooled by its plain appearance - the primordial essence of pure magic resides in these arcane relics and I can be the key to unlock them to the shamanistic powers.");
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
    my @valid_rewards = (28487, 28488, 28489, 28490, 26945, 26946,21660, 21661, 28491, 28492, 28493, 28494, 28523); #Level 61 or 62 Shaman spell, PoP (True Spirit, Agility of the Wrulan, Spear of Torment, Cloud of Grummus, Greater Immobilize, Tnarg's Mending, Focus of Soul, Ancestral Guard, Endurance of the Boar, Talisman of the Wrulan, Talisman of the Tribunal, Replenishment,Petrifying Earth)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "Do not use this power without caution, $name. It is quite powerful indeed for it is power forged upon the planar worlds but may affect both astral and prime alike.");
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
    my @valid_rewards = (59615, 28495, 28496, 28497, 28498, 28499, 28531, 26910, 26912, 26913, 26914, 26911); #Level 63 or 64 Shaman spell, PoP (Tears of Saryrn, Malicious Decay, Malosinia, Strength of the Diaku, Talisman of the Boar, Blessing of Replenishment, Velium Strike, Talisman of the Diaku, Tiny Terror, Breath of Ultor, Talisman of Alacrity)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "Do not use this power without caution, $name. It is quite powerful indeed for it is power forged upon the planar worlds but may affect both astral and prime alike.");
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
    my @valid_rewards = (26915, 26916, 26917, 26918, 26919); #Level 65 Shaman spell, PoP (Malos, Blood of Saryrn, Focus of the Seventh, Quiescence, Ferine Avatar)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "Do not use this power without caution, $name. It is quite powerful indeed for it is power forged upon the planar worlds but may affect both astral and prime alike.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}