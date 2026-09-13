-- por_helper.lua - shared constants + helpers for Prophecy of Ro content (Triptych/NMS).
--
-- IMPORTANT: all item ids below are the LOCAL PEQ ids, not the Allakhazam ids the
-- walkthroughs use. Keep this table in sync with any DB content added in
-- Release-NMS-Quests/por_*.sql.

local por = {}

por.items = {
  -- Razorthorn access: the nine saga skins (looted in The Devastation / Sverag / Razorthorn)
  scarred_bolvirk_skin        = 88069,
  mummified_pigmented_skin    = 88070,
  patch_of_dyed_kobold_fur    = 88071,
  torn_and_tattooed_orc_flesh = 88072,
  inked_evil_eye_hide         = 88073,
  decorated_wurine_hide       = 88074,
  etched_drachnid_carapace    = 88075,
  tattooed_shiliskin_skin     = 88076,
  scarred_and_tattooed_skin   = 88077,

  -- Maelin's translations of the above (returned alongside the skin)
  bolvirk_lore_skin_translation   = 88078,
  undead_lore_skin_translation    = 88079,
  kobold_lore_skin_translation    = 88080,
  orc_lore_skin_translation       = 88081,
  evil_eye_lore_skin_translation  = 88082,
  wurine_lore_skin_translation    = 88083,
  drachnid_lore_skin_translation  = 88084,
  shiliskin_lore_skin_translation = 88085,
  berserker_lore_skin_translation = 88086,

  -- the bound book (given by Maelin once all nine translations are returned)
  saga_skin_translations_vol1 = 88087,
  saga_skin_translations_vol2 = 88089,
  book_binding               = 45923,

  -- "Preparing Your New Skins" materials
  bone_tattoo_comb = 88090,
  warriors_blood   = 88091,
  battleground_soot = 88092,

  -- Enraged Flesh armor + the charm (Razorthorn key)
  enraged_flesh_tunic    = 88093,
  enraged_flesh_leggings = 88094,
  enraged_flesh_cap      = 88095,
  enraged_flesh_sleeves  = 88096,
  enraged_flesh_gloves   = 88097,
  enraged_flesh_charm    = 88099,

  -- Theater of Blood access: the chime chain
  tarnished_chime                 = 36144,
  harmonic_chime                  = 84159,
  silent_harmonic_chime           = 84160,
  twisted_chime_first             = 84161, -- from Oathmir
  twisted_chime_second            = 84168, -- from Arch Mage Galsin
  twisted_harmonic_chime_blank    = 84162, -- from Queen Tak`Yaliz, no effect
  twisted_harmonic_chime          = 84163, -- final, Alter Plane: Theater of Blood

  -- Skylance arc
  skylance_symbol_first  = 36140,
  skylance_symbol_second = 36141,
  codex_artifice         = 36142,
  prototype_egg          = 36143,
  incubated_egg          = 36145,

  -- Ruins of Takish-Hiz arc
  crown_of_takyaz             = 84155,
  vial_of_corrupted_blood     = 84156,
  runed_silver_box            = 84157,
  sealed_runed_silver_box     = 84158,

  -- Deathknell access: Druzzil's shards and the ToB inspirations
  shard_of_mana        = 84164,
  glowing_shard_of_mana = 84165,
  red_shard_of_mana    = 84166,
  black_shard_of_mana  = 84167,
  divine_fetters_of_ro = 52601, -- final reward from the Shrine of Druzzil Ro
}

-- Inspirations of the six companions, looted from the Theater of Blood encounters.
por.inspirations = { 52595, 52594, 52598, 52596, 52597, 52599 }

-- The five sandstone tablet pieces (The Key to the Past)
por.sandstone_tablets = { 36135, 36136, 36137, 36138, 36139 }

por.tasks = {
  saga_skins               = 3000,
  preparing_your_new_skins = 3001,
  become_the_vessel        = 3002,
  -- Theater of Blood access chain
  skylance_library         = 3010,
  skylance_oubliette       = 3011,
  skylance_laboratory      = 3012,
  samples_of_corruption    = 3013,
  key_to_the_past          = 3014,
  burning_prince           = 3015,
  message_from_the_past    = 3016,
  chalice_of_life          = 3017,
  -- Side quests (Phase 5)
  great_caiman_issue       = 3019,
  challenge_of_the_circle  = 3020,
  the_needy                = 3021,
  a_shopkeepers_delight    = 3022,
  tree_heaven              = 3023,
  black_orb_of_the_scrykin = 3024,
  investigating_the_elddar = 3025,
  questioning_the_priest   = 3026,
  key_to_corruption        = 3027,
  exploring_arcstone       = 3028,
  heroes_challenge         = 3029,
  arena_champions_badge    = 3030,
}

por.aa = {
  -- GrantAlternateAdvancementAbility expects the aa_ability id, not the rank id.
  -- Ability 574 "Harmonic Dissonance" has first_rank_id 1647, which grants
  -- spell 8771 (Alter Plane: Theater of Blood).
  harmonic_dissonance = 574,
}

-- Ordered lists (used by scripts; order is not significant beyond readability)
por.skins = {
  88069, 88070, 88071, 88072, 88073, 88074, 88075, 88076, 88077,
}

por.translations = {
  88078, 88079, 88080, 88081, 88082, 88083, 88084, 88085, 88086,
}

por.armor = {
  88093, 88094, 88095, 88096, 88097,
}

-- Skin -> Maelin's translation (Saga Skins exchange)
por.skin_to_translation = {
  [88069] = 88078, -- Scarred Bolvirk Skin        -> Bolvirk Lore Skin Translation
  [88070] = 88079, -- Mummified Pigmented Skin    -> Undead Lore Skin Translation
  [88071] = 88080, -- Patch of Dyed Kobold Fur    -> Kobold Lore Skin Translation
  [88072] = 88081, -- Torn and Tattooed Orc Flesh -> Orc Lore Skin Translation
  [88073] = 88082, -- Inked Evil Eye Hide         -> Evil Eye Lore Skin Translation
  [88074] = 88083, -- Decorated Wurine Hide       -> Wurine Lore Skin Translation
  [88075] = 88084, -- Etched Drachnid Carapace    -> Drachnid Lore Skin Translation
  [88076] = 88085, -- Tattooed Shiliskin Skin     -> Shiliskin Lore Skin Translation
  [88077] = 88086, -- Scarred and Tattooed Skin   -> Berserker Lore Skin Translation
}

-- The five skins traded to Maelin during "Preparing Your New Skins" and the
-- armor piece each becomes.
por.skin_to_armor = {
  [88069] = 88093, -- Scarred Bolvirk Skin -> Enraged Flesh Tunic
  [88072] = 88094, -- Torn and Tattooed Orc Flesh -> Enraged Flesh Leggings
  [88076] = 88095, -- Tattooed Shiliskin Skin -> Enraged Flesh Cap
  [88077] = 88096, -- Scarred and Tattooed Skin -> Enraged Flesh Sleeves
  [88074] = 88097, -- Decorated Wurine Hide -> Enraged Flesh Gloves
}

-- Spirit Mark Armor (Lady Usher): class -> slot -> reward item id
por.spirit_mark_armor = {
  [Class.BARD]         = { helm=39810, arms=39811, chest=39815, legs=39816, gloves=39813, feet=39814, wrist=39812 },
  [Class.BEASTLORD]    = { helm=39859, arms=39860, chest=39864, legs=39865, gloves=39862, feet=39863, wrist=39861 },
  [Class.BERSERKER]    = { helm=39866, arms=39867, chest=39871, legs=39872, gloves=39869, feet=39870, wrist=39868 },
  [Class.CLERIC]       = { helm=39768, arms=39769, chest=39773, legs=39774, gloves=39771, feet=39772, wrist=39770 },
  [Class.DRUID]        = { helm=39796, arms=39797, chest=39801, legs=39802, gloves=39799, feet=39800, wrist=39798 },
  [Class.ENCHANTER]    = { helm=39852, arms=39853, chest=39857, legs=39858, gloves=39855, feet=39856, wrist=39854 },
  [Class.MAGICIAN]     = { helm=39845, arms=39846, chest=39850, legs=39851, gloves=39848, feet=39849, wrist=39847 },
  [Class.MONK]         = { helm=39803, arms=39804, chest=39808, legs=39809, gloves=39806, feet=39807, wrist=39805 },
  [Class.NECROMANCER]  = { helm=39831, arms=39832, chest=39836, legs=39837, gloves=39834, feet=39835, wrist=39833 },
  [Class.PALADIN]      = { helm=39775, arms=39776, chest=39780, legs=39781, gloves=39778, feet=39779, wrist=39777 },
  [Class.RANGER]       = { helm=39782, arms=39783, chest=39787, legs=39788, gloves=39785, feet=39786, wrist=39784 },
  [Class.ROGUE]        = { helm=39817, arms=39818, chest=39822, legs=39823, gloves=39820, feet=39821, wrist=39819 },
  [Class.SHADOWKNIGHT] = { helm=39789, arms=39790, chest=39794, legs=39795, gloves=39792, feet=39793, wrist=39791 },
  [Class.SHAMAN]       = { helm=39824, arms=39825, chest=39829, legs=39830, gloves=39827, feet=39828, wrist=39826 },
  [Class.WARRIOR]      = { helm=39761, arms=39762, chest=39766, legs=39767, gloves=39764, feet=39765, wrist=39763 },
  [Class.WIZARD]       = { helm=39838, arms=39839, chest=39843, legs=39844, gloves=39841, feet=39842, wrist=39840 },
}

-- Spirit Mark item -> slot, and Crafting Mold item -> slot
por.spirit_mark_slot = {
  [85657] = "helm",   -- Vision
  [85655] = "arms",   -- Air
  [85658] = "chest",  -- Battle
  [85652] = "legs",   -- Fire
  [85654] = "gloves", -- Earth
  [85653] = "feet",   -- Water
  [85656] = "wrist",  -- Scale
}
por.spirit_mold_slot = {
  [85659] = "helm",
  [85660] = "arms",
  [85665] = "chest",
  [85664] = "legs",
  [85661] = "gloves",
  [85662] = "feet",
  [85663] = "wrist",
}

-- Grant the class-appropriate Spirit Mark piece for the slot to every owned class.
function por.grant_spirit_piece(client, slot)
  local n = 0
  for class_id, pieces in pairs(por.spirit_mark_armor) do
    if client:HasClassID(class_id) then
      local item = pieces[slot]
      if item then
        client:SummonFixedItem(item)
        n = n + 1
      end
    end
  end
  return n
end

-- Challenge of the Circle: casters get the Necklace, melee get the Veil.
por.caster_classes = {
  [Class.CLERIC] = true, [Class.DRUID] = true, [Class.SHAMAN] = true,
  [Class.ENCHANTER] = true, [Class.MAGICIAN] = true, [Class.NECROMANCER] = true, [Class.WIZARD] = true,
}

function por.grant_circle_reward(client)
  local n = 0
  for class_id = 1, 16 do
    if client:HasClassID(class_id) then
      if por.caster_classes[class_id] then
        if not client:HasItem(39700) then
          client:SummonFixedItem(39700) -- Necklace of the Circle Champion
          n = n + 1
        end
      else
        if not client:HasItem(39699) then
          client:SummonFixedItem(39699) -- Veil of the Circle Champion
          n = n + 1
        end
      end
    end
  end
  return n
end

-- Task activity ids for the script-driven steps (mirror por_razorthorn_access.sql).
por.activity = {
  -- Task 3000 Saga Skins: deliver the two bound volumes to Maelin
  saga_vol1 = 9,
  saga_vol2 = 10,
  -- Task 3001 Preparing: materials + skin -> armor
  prep_comb  = 3,
  prep_blood = 4,
  prep_soot  = 5,
  -- Task 3002 Become the Vessel: deliver the five armor pieces
  vessel_armor = { [88093] = 3, [88094] = 4, [88095] = 5, [88096] = 6, [88097] = 7 },
}

-- Which Preparing activity each skin corresponds to.
por.prep_skin_activity = { [88069] = 6, [88072] = 7, [88076] = 8, [88077] = 9, [88074] = 10 }

-- Class -> reward item id. Rewards are granted for EVERY class the (multiclass)
-- client owns, per the Triptych reward policy.
por.reward_groups = {
  -- Plane of Rage spell tasks (any of the ten kill/collect tasks)
  rage = {
    [Class.BARD]         = 77992, -- Spell: Arcane Aria
    [Class.BEASTLORD]    = 78017, -- Tome of Rake
    [Class.BERSERKER]    = 77986, -- Skill: Bloodthirst
    [Class.CLERIC]       = 77996, -- Spell: Elixir of Divinity
    [Class.DRUID]        = 77999, -- Spell: Barkspur
    [Class.ENCHANTER]    = 78005, -- Spell: Ward of Bedazzlement
    [Class.MAGICIAN]     = 78011, -- Spell: Spear of Ro
    [Class.MONK]         = 77984, -- Skill: Heel of Kanji
    [Class.NECROMANCER]  = 78014, -- Spell: Grave Pact
    [Class.PALADIN]      = 77988, -- Spell: Ward of Tunare
    [Class.RANGER]       = 77994, -- Spell: Scorched Earth
    [Class.ROGUE]        = 77982, -- Skill: Razorarc
    [Class.SHADOWKNIGHT] = 77990, -- Spell: Theft of Agony
    [Class.SHAMAN]       = 78002, -- Spell: Nectar of Pain
    [Class.WARRIOR]      = 77980, -- Skill: Mock
    [Class.WIZARD]       = 78008, -- Spell: Ice Block
  },
  -- Ruins of Takish-Hiz spell tasks (The Key to the Past / Burning Prince / Message from the Past)
  takishhiz = {
    [Class.CLERIC]       = 77998, -- Spell: Aura of the Pious
    [Class.DRUID]        = 78001, -- Spell: Aura of Life
    [Class.ENCHANTER]    = 78007, -- Spell: Illusionist's Aura
    [Class.MAGICIAN]     = 78013, -- Spell: Rathe's Strength
    [Class.NECROMANCER]  = 78016, -- Spell: Death Rune
    [Class.SHAMAN]       = 78004, -- Spell: Idol of Malos
    [Class.WIZARD]       = 78010, -- Spell: Fire Rune
  },
  -- 55th level aura task "The Chalice of Life" (Lilthill`yan`s Ghost)
  aura55 = {
    [Class.BARD]         = 78024, -- Spell: Aura of Insight
    [Class.BERSERKER]    = 78022, -- Tome of Aura of Rage
    [Class.CLERIC]       = 78025, -- Spell: Aura of the Zealot
    [Class.DRUID]        = 78026, -- Spell: Aura of the Grove
    [Class.ENCHANTER]    = 78028, -- Spell: Beguiler's Aura
    [Class.MAGICIAN]     = 78030, -- Spell: Earthen Strength
    [Class.MONK]         = 78021, -- Tome of Disciples Aura
    [Class.NECROMANCER]  = 78031, -- Spell: Dark Rune
    [Class.PALADIN]      = 78023, -- Spell: Holy Aura
    [Class.ROGUE]        = 78020, -- Tome of Poison Spurs
    [Class.SHAMAN]       = 78027, -- Spell: Idol of Malo
    [Class.WARRIOR]      = 78019, -- Tome of Myrmidon's Aura
    [Class.WIZARD]       = 78029, -- Spell: Fire Mark
  },
  -- Plane of Magic / Skylance arc (The Library / Oubliette / Laboratory)
  skylance = {
    [Class.BARD]         = 77993, -- Spell: Aura of the Muse
    [Class.BEASTLORD]    = 78018, -- Spell: Spirit of Oroshar
    [Class.BERSERKER]    = 77987, -- Skill: Bloodlust Aura
    [Class.CLERIC]       = 77997, -- Spell: Puratus
    [Class.DRUID]        = 78000, -- Spell: Moonshadow
    [Class.ENCHANTER]    = 78006, -- Spell: Mind Shatter
    [Class.MAGICIAN]     = 78012, -- Spell: Iceflame Guard
    [Class.MONK]         = 77985, -- Skill: Master's Aura
    [Class.NECROMANCER]  = 78015, -- Spell: Mind Flay
    [Class.PALADIN]      = 77989, -- Spell: Blessed Aura
    [Class.RANGER]       = 77995, -- Spell: Elddar's Grasp
    [Class.ROGUE]        = 77983, -- Skill: Poison Spikes Trap
    [Class.SHADOWKNIGHT] = 77991, -- Spell: Decrepit Skin
    [Class.SHAMAN]       = 78003, -- Spell: Ghost of Renewal
    [Class.WARRIOR]      = 77981, -- Skill: Champion's Aura
    [Class.WIZARD]       = 78009, -- Spell: Chaos Flame
  },
}

-- Grant the class-appropriate reward(s) for every class the client owns.
-- Returns the number of rewards granted.
function por.grant_rewards(client, group)
  local rewards = por.reward_groups[group]
  if not rewards then
    return 0
  end
  local granted = 0
  for class_id, item_id in pairs(rewards) do
    if client:HasClassID(class_id) then
      client:SummonFixedItem(item_id)
      granted = granted + 1
    end
  end
  return granted
end

-- True when the client possesses every id in the list.
function por.has_all(client, ids)
  for _, id in ipairs(ids) do
    if not client:HasItem(id) then
      return false
    end
  end
  return true
end

-- Count how many instances of item_id are present in a trade (slots 1..4).
function por.traded_count(trade, item_id)
  local n = 0
  for i = 1, 4 do
    local inst = trade["item" .. i]
    if inst and inst.valid and inst:GetID() == item_id then
      n = n + 1
    end
  end
  return n
end

-- Zone-in data for the Prophecy of Ro instances (safe coords from the zone table).
por.zones = {
  skylance     = { id = 371, name = "Skylance",                            x = 0,    y = -95,  z = 2,   h = 0 },
  takishruinsa = { id = 377, name = "The Root of Ro",                      x = 18,   y = -138, z = -29, h = 0 },
  takishruins  = { id = 376, name = "Ruins of Takish-Hiz",                 x = -983, y = 269,  z = 62,  h = 0 },
  ragea        = { id = 375, name = "Razorthorn, Tower of Sullon Zek",     x = 354,  y = 63,   z = 3,   h = 0 },
  theatera     = { id = 381, name = "Deathknell, Tower of Dissonance",     x = 0,    y = -108, z = 4,   h = 0 },
}

-- Create an expedition for the given zone key and move the requester into it.
-- Returns true on success. Mirrors the GoD/OoW expedition pattern.
function por.enter(client, zone_key, expedition_name, min_players, max_players, duration, lockout)
  local z = por.zones[zone_key]
  if not z then
    return false
  end
  local dz = client:CreateExpedition({
    expedition = {
      name        = expedition_name or z.name,
      min_players = min_players or 1,
      max_players = max_players or 6,
    },
    instance = {
      zone    = zone_key,
      version = 0,
      duration = eq.seconds(duration or "6h"),
    },
    zonein = { x = z.x, y = z.y, z = z.z, h = z.h },
  })
  if dz.valid then
    if lockout then
      dz:AddReplayLockout(eq.seconds(lockout))
    end
    local instance_id = dz:GetInstanceID()
    if instance_id and instance_id > 0 then
      client:MovePCInstance(z.id, instance_id, z.x, z.y, z.z, z.h)
    end
    return true
  end
  return false
end

return por
