#Bor_Wharhammer.pl
#PoP quest armors
# items: 32409, 15791, 16577, 16267, 17184, 16271, 16269, 16272, 16270, 16276, 17185, 16275, 16268, 16273, 16274, 16278, 16279, 16280, 16281, 16277, 32000

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Greetin's t'ye $name! Isn't the area 'round 'ere so nice an' quiet? Such a departure from me old days; slaving o'er the forge t'create masterpieces! T'be 'onest. at times I do miss the old forge. but after I created me finest breastplate, it seemed as if nothing else I made could ever live up t'it. So I left me home to'wander the land an' see what I could learn o'the world. I 'ave learned quite a bit from the elders 'ere an' the skilled craftspeople in New Tanaan. I 'ave even devised a type o'[" . quest::saylink("emblem") . "] that will impart the magic o'tranquility into the user t'create planar armors from pieces o'energy found in the planes.");
  }
  if ($text=~/emblem/i) {
    if ($ulevel <= 54) {
      quest::say("Ye look mighty inexperienced t'be in this area, $name. Come an' seek me out when ye 'ave more knowledge o'the planes!");
    }
    else {
      quest::say("Well, the emblems dinnae be easy t'craft but I will gladly give ye one fer the price of 500 platinum pieces. They allow a planes traveler with no craftin' skills t'create many fine pieces o'planar armor in a special, magical kit I also 'ave an' will throw in with the price. The kit acts as a focal point fer the wild magic energy o'the Planes. Ye will only be able t'use each emblem an' kit once when ye create the piece, 'owever I dinnae be goin' anywhere soon! Just venture back when ye need another an' dinnae ferget the coin! Tell me yer " . quest::silent_saylink("class") . ", and I'll hand ye that emblem fer the coin.");
    }
  }
  if ($text=~/class/i) {
    quest::say("If ye be needin' an emblem fer a particular class, just say the name of the class and I'll see if ye got the 500 platinum pieces required. It be as simple as that, $name.");
  }
  if ($text=~/chain/i) {
    quest::say("Ahhhhh $name! Chain armors, while not as sturdy as plate, provide so much more mobility if constructed properly. T'construct a piece o'chain armor, ye need t'combine a chain pattern, an emblem, various amounts of ethereal metal rings an' use one o'those crafty Tanaan smithin' 'ammers all within a furnace touched by Ro. Ethereal metal ring construction is another matter. Ye will need to combine a brick o'ethereal energy, an ethereal temper an' a file within a Tanaan forge. I would seek a skilled craftsperson t'make the rings fer ye; the emblem will enable ye t'craft the final armor piece no matter what yer skill be.");
  }
  if ($text=~/silk/i) {
    quest::say("Har! It be quite funny that we be referin' t'silk as armor, fer the amount o'protection it provides be miniscule at best. The planar armor made from strands o'ether can still be quite useful fer its magical properties, 'owever. Ye will need t'take up a Tanaan embroidery needle, a pattern, an emblem an' various amounts o'ether silk swatches t'create a piece. Craft it all within a sewing kit boilin' with magical energy.");
  }
  if ($text=~/leather/i) {
    quest::say("Leather armor provides little protection due t'the make-up o'the materials. We shall do our best, 'owever, t'see ye make a quality piece. T'do so, ye must combine a pattern, an emblem, various pieces o'cured ethereal energy an' a Tanaan embroidery needle all within a sewing kit boilin' with magical energy. The cured energy may be problematic fer an unskilled craftsman, 'owever. Just sew two silk ethereal swatches together using a Tanaan embroidery needle within a Tanaan loom. I can just imagine yer next question t'be about swatches, aye?");
  }
  if ($text=~/plate/i) {
    quest::say("Ahhhhh $name! The fine rigid armor that can stop a shaft from piercing yer heart! Too bad it be so cumbersome an' difficult t'move about in. To construct a piece o'plate armor, ye need t'combine a plate mold, an emblem, various amounts o'sheet metal an' use one o'those crafty Tanaan smithin' 'ammers all within a furnace touched by Ro. Ethereal metal sheet construction is another matter. Ye will need t'combine two bricks o'ethereal energy, an ethereal temper an' a Tanaan smithin' 'ammer within a Tanaan forge. I would seek a skilled craftsperson t'make the metal sheets fer ye; the emblem will enable ye t'craft the final armor piece no matter what yer skill be.");
  }
  if ($text=~/swatch/i) {
    quest::say("T'make a swatch, ye need t'combine two strands o'ether along with a curing agent in a Tanaan loom. Ye will need t'seek a skilled brew master t'make the curing agent fer ye. Just 'ave them create it by using two celestial essences, soda an' paeala sap");
  }

  # This adds a way of requesting the emblem for a given class for situations where you're not actually the class
  # that you want to make the armor for.
  if ($ulevel > 54) {
    if ($text=~/Warrior/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16267);#Warrior Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Cleric/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16271);#Cleric Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Paladin/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16269);#Paladin Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Ranger/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16272);#Ranger Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Shadowknight/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16270);#Shadowknight Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Druid/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16276);#Druid Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Monk/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16275);#Monk Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Bard/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16268);#Bard Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Rogue/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16273);#Rogue Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Shaman/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16274);#Shaman Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Necromancer/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16278);#Necromancer Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Wizard/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16279);#Wizard Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Magician/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16280);#Magician Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Enchanter/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16281);#Enchanter Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Beastlord/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(16277);#Beastlord Emblem
        quest::summonitem(17185);#Druzzil's Mystical Sewing Kit
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
    elsif ($text=~/Berserker/i) {
      if ($client->TakeMoneyFromPP(500000, 1)) {
        quest::summonitem(32000);#Berserker Emblem
        quest::summonitem(17184);#Mystical Furnace of Ro
      } else {
        quest::say("You don't have enough coin for that, come back when you do.");
      }
    }
  }
}

sub EVENT_ITEM {
  if ($client->GetGlobal("mage_epic_fire1") == 1 && plugin::check_handin(\%itemcount, 32409 => 1, 15791 => 1)) {
    quest::say("Eh? I see ol' Gnaap 'as gotten' 'imself in'o a pickle again. Well le's see. I figu'e tha'ye need a good solven'. Ye'll need t'fin yer'self some metallic liquid, 'at'll make a fine suspension. Then fin' yerself some'un good wit' a brew barrel. Have'em mix tha' wit' sum 'ydro-lize'd ether, an' sum 'evy water.");
    quest::summonitem(16577); #reinforced flask
  } else {
    quest::say("I cannae take yer coin unless ye' tell me yer class, hero.");
  }
  plugin::return_items(\%itemcount);
}
#END of FILE Zone:potranquility  ID:203064 -- Bor_Wharhammer