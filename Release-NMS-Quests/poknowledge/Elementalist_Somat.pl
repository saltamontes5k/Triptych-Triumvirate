#Elementalist Somat.pl
#Magician PoP Spells/Songs
# items: 59639, 59635, 29112, 21641, 21642, 32411, 29357, 29358, 29359, 29360, 29361, 28413, 28428, 28429, 28440, 21637, 21643, 21646, 21669, 28430, 28431, 29131, 21644, 29362, 28432, 28433, 28497, 16341, 29363, 21645, 21659, 21668, 28415, 28434, 29132, 28435, 28436, 16342

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings, traveler! I am Somat, Elementalist extraordinaire and one of several of my trade here in New Tanaan. We have all spent much time preparing for your arrival and hope that our time is not in vain. If you are a wielder of the elemental forces, then come and browse my inventory, friend! I may hold a spell or two that might pique your interest. Also, if you perhaps hold a seemingly mundane item of arcane relation that you found in your travels upon the planes, then do not hesitate to let me have a look at it. Don't worry -- we are not thieves here! Rather, we wish to aid you and I so love dabbling in the chaos of planar magic!");
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
    my @valid_rewards = (59639, 21641, 21642, 32411, 29357, 29358, 29359, 29360, 29361, 28413, 28428, 28429, 28440, 21637, 21643, 21646, 21669, 28430, 28431); #Level 61 or 62 Magician spell, PoP (Belt of Magi'Kot, Blade of Walnan, Flameshield of Ro, Summon Platinum Choker, Summon Runed Mantle, Summon Sapphire Bracelet, Summon Spiked Ring, Summon Glowing Bauble, Shield of the Arcane, Ward of Xegony, Firebolt of Tallon, Elemental Barrier, Xegony's Phantasmal Guard, Fist of Ixiblat, Talisman of Return, Burnout V, Sun Storm, Servant of Marr)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "There you go, friend! This should do quite nicely, indeed!");
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
    my @valid_rewards = (21644, 29362, 28432, 28433, 28497, 16341, 29363, 21645, 21659, 21668, 28415, 28434, 59635); #Level 63 or 64 Magician spell, PoP (Blade of The Kedge, Summon Jewelry Bag, Black Steel, Child of Ro, Malosinia, Elemental Silence, Maelstrom of Ro, Girdle of Magi'Kot, Destroy Summoned, Planar Renewal, Shield of Maelin, Maelstrom of Thunder)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "There you go, friend! This should do quite nicely, indeed!");
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
    my @valid_rewards = (28435, 28436, 16342); #Level 65 Magician spell, PoP (Rathe's Son, Sun Vortex, Call of the Arch Mage)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "carefully takes the planar arcane item from you. With a careful eye, he inspects every portion of the incorporeal item before nodding to himself in satisfaction. The shaman then closes his eyes and chants lowly in an unfamiliar language. You feel the coalescing of spirits around you in the area as the shaman calls them forth to bless the arcane item in his grip. Dark runes of a rusted color begin to carve themselves onto a parchment that grows more real and tangible with each syllable uttered by the shaman. Eventually, his chant comes to a close and the completed item is handed to you without expectation of further aid on your behalf.", "say", "There you go, friend! This should do quite nicely, indeed!");
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
