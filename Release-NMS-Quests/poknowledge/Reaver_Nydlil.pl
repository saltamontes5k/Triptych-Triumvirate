#Reaver_Nydlil.pl
#Shadowknight PoP Spells
# items: 59592, 4063, 29112, 26920, 26924, 26921, 26925, 26937, 29131, 21651, 26922, 26923, 21632, 21634, 21633, 29132, 26926, 26927, 26928, 21635

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::emote("'s voice spills forth in a piercing hiss, the pitch high and accented in the tones of the Iksarian Empire of old.");
    quest::say("Welcome to New Tanaan, and stand before us as enemies not, but as equals. Your mind should be open to us, for we wish only to guide you where we have been led in our years beyond Norrath. If you are a knight of the shadows, then perhaps I may be of service in guiding you further to power. The adepts of New Tanaan, the scholars, have come forward and penned spells of our former lives in memory. We wish to share this knowledge with you without bias or judgment. There is more beyond the mortal limits of magic that I can aid you to attain should you wield the blade of the shadow. If you happen across a seemingly mundane arcane item of incorporeal material, do not discard it. Return it to me and I shall carve for you from its essence a most powerful spell conceived in the divine realms of pure magic.");
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
    my @valid_rewards = (26920, 26924, 26921, 26925, 26937); #Level 61 or 62 Class spell, PoP (Festering Darkness, Aura of Darkness, Touch of Volatis, Zevfeer's Bite, Deny Undead)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item carefully, his scaled hand delicate in its grasp. The iksar takes note of every detail upon the untainted planar arcane item before closing his eyes and giving forth a drawled, hissing chant of sounds and foreign words. The object in the shadowknight's hands begins to radiate in a dark aura as it pulses in and out of reality -- every beat of its wavering existence bringing it closer to a tangible state. Eventually, the item becomes whole, and the crimson runes, seemingly forged of blood from an unknown source, are flawless in their construction. The iksar opens his eyes and inspects the completed scroll briefly before handing it to you.", "say", "This will serve you well, $name. Go to the realms of the divine and see exactly what new power has been granted to you.");
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
    my @valid_rewards = (59592, 21651, 26922, 26923, 21632, 21634, 21633, 4063); #Level 63 or 64 Class spell, PoP (Scythe of Innoruuk, Shroud of Chaos, Aura of Pain, Terror of Thule, Blood of Hate, Pact of Hate, Spear of Decay, Invoke Death (SHD))
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item carefully, his scaled hand delicate in its grasp. The iksar takes note of every detail upon the untainted planar arcane item before closing his eyes and giving forth a drawled, hissing chant of sounds and foreign words. The object in the shadowknight's hands begins to radiate in a dark aura as it pulses in and out of reality -- every beat of its wavering existence bringing it closer to a tangible state. Eventually, the item becomes whole, and the crimson runes, seemingly forged of blood from an unknown source, are flawless in their construction. The iksar opens his eyes and inspects the completed scroll briefly before handing it to you.", "say", "This will serve you well, $name. Go to the realms of the divine and see exactly what new power has been granted to you.");
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
    my @valid_rewards = (26926, 26927, 26928, 21635); #Level 65 Class spell, PoP (Voice of Thule, Aura of Hate, Touch of Innoruuk, Cloak of Luclin)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "accepts the item carefully, his scaled hand delicate in its grasp. The iksar takes note of every detail upon the untainted planar arcane item before closing his eyes and giving forth a drawled, hissing chant of sounds and foreign words. The object in the shadowknight's hands begins to radiate in a dark aura as it pulses in and out of reality -- every beat of its wavering existence bringing it closer to a tangible state. Eventually, the item becomes whole, and the crimson runes, seemingly forged of blood from an unknown source, are flawless in their construction. The iksar opens his eyes and inspects the completed scroll briefly before handing it to you.", "say", "This will serve you well, $name. Go to the realms of the divine and see exactly what new power has been granted to you.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}