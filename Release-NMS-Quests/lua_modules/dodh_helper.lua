-- dodh_helper.lua - Depths of Darkhollow (Dreadspire / Demi-Plane of Blood) access.
--
-- ROUGH FRAMEWORK for the five-task access chain from Bonzz's
-- "Dreadspire, The Demi-Plane of Blood" guide, matching dodh_access.sql.
--
-- IMPORTANT: item and task ids are the local PEQ ids, not the Allakhazam ids
-- the walkthroughs use. Keep in sync with Release-NMS-Quests/dodh_access.sql.

local dodh = {}

dodh.tasks = {
  frustrated_functionary = 505745, -- Melion Pell (Dreadspire): Dreadspire Library key
  library_book           = 505746, -- Treddlehoop (Corathus): Study of Mystical Vision
  eyes_wide_open         = 505747, -- Treddlehoop: Bloody Cloth Eye Patch
  misty_for_you          = 505748, -- Coldwind Blackfoot (Nektulos): Moon-shaped Diamond Pendant
  eye_bound              = 505749, -- Coldwind Blackfoot: Vule's Eye
}

dodh.items = {
  -- access chain
  treddlehoop_device    = 88005, -- Treddlehoop's Wonderful Monoculor Seeing Device
  shard_mystical_glass  = 88006,
  study_mystical_vision = 88007,
  coral_golden_necklace = 88009,
  monocle_of_blood      = 88013,
  elixir_velvet_blood   = 88014,
  crypt_dust            = 88015,
  funerary_pouch        = 88016, -- Funeral Donation Pouch
  crypt_blood_slurry    = 88017,
  bloody_cloth_eyepatch = 88018,
  polished_glass_shard  = 88019,
  blurry_lens           = 88020,
  lens_of_bound_eyes    = 88021,
  moon_diamond_pendant  = 88022,
  lens_of_eye_glass     = 88034,
  vules_eye             = 88035,
  drop_accursed_blood   = 88036,
  dreadspire_crest      = 88042,

  -- Demi-Plane curse blockers (turned in to the Dreadspire quartet)
  congealed_blood_redfang = 52522,
  rune_etched_stone       = 52523,
  shrunken_head           = 52524,
  sisters_handkerchief    = 52525,
}

dodh.flags = {
  library_key = "dodh.library_key",
  monocle     = "dodh.monocle",
}

-- Demi-Plane "Aura of Crimson Mists" curse removal. Each of the four blocker
-- turn-ins (Ur-Koraag, Arturos, Ariahn, Irrissa) absorbs 25%; all four fully
-- suppress it. Tracked with buckets because no blocker AA exists in this DB.
function dodh.grant_blocker(client, item_id, label)
  local key = "dodh.blocker." .. tostring(item_id)
  if (tonumber(client:GetBucket(key)) or 0) == 1 then
    client:Message(15, "You have already absorbed that blocker's power.")
    return
  end
  client:SetBucket(key, "1")
  local n = (tonumber(client:GetBucket("dodh.blockers")) or 0) + 1
  client:SetBucket("dodh.blockers", tostring(n))
  if n >= 4 then
    client:SetBucket("dodh.demiplane_blocked", "1")
    client:Message(15, "The Aura of Crimson Mists is fully suppressed. The Demi-Plane of Blood no longer tears at you.")
  else
    client:Message(15, string.format("%s absorbed. The Aura of Crimson Mists weakens (%d of 4 blockers).", label, n))
  end
end

-- ===========================================================================
-- Curse of Blood (loot rights) + Aura of Crimson Mists (zone AoE)
-- ===========================================================================

-- The five "Curse of Blood" raids. A client that has broken all five gains
-- loot rights inside the Demi-Plane of Blood (dodh.demiplane_loot).
dodh.curses = {
  shyra    = "Matriarch Shyra",
  bloodeye = "Bloodeye",
  council  = "The Council of Nine",
  draygun  = "Emperor Draygun",
  sendaii  = "Sendaii, the Hive Queen",
}

local function curse_complete(client)
  for key in pairs(dodh.curses) do
    if (tonumber(client:GetBucket("dodh.curse." .. key)) or 0) ~= 1 then
      return false
    end
  end
  return true
end

function dodh.has_loot_rights(client)
  return (tonumber(client:GetBucket("dodh.demiplane_loot")) or 0) == 1
end

function dodh.grant_curse(client, key)
  if not dodh.curses[key] then
    return
  end
  if (tonumber(client:GetBucket("dodh.curse." .. key)) or 0) == 1 then
    return
  end
  client:SetBucket("dodh.curse." .. key, "1")
  if curse_complete(client) then
    client:SetBucket("dodh.demiplane_loot", "1")
    client:Message(15, "All five Curse of Blood raids are broken. You may claim the spoils of the Demi-Plane of Blood.")
  else
    client:Message(15, string.format("%s's curse is broken. The Demi-Plane of Blood will remember it.", dodh.curses[key]))
  end
end

-- Grant a curse credit to every client in the current zone (raid death hook).
function dodh.grant_curse_zone(key)
  if not dodh.curses[key] then
    return
  end
  local el = eq.get_entity_list()
  local cl = el and el:GetClientList()
  if not cl then
    return
  end
  for _, c in ipairs(cl.entries) do
    if c.valid then
      dodh.grant_curse(c, key)
    end
  end
end

-- Number of curse blockers absorbed (0..4); 4 == fully immune to the Aura.
function dodh.blocker_count(client)
  return tonumber(client:GetBucket("dodh.blockers")) or 0
end

-- "Aura of Crimson Mists" rank by blocker count. 0 blockers = rank I (100%),
-- 1 = II (75%), 2 = III (50%), 3 = IV (25%), 4 = nil (fully suppressed).
dodh.aura_spells = { 7023, 7024, 7025, 7026 }

function dodh.aura_spell(client)
  local n = dodh.blocker_count(client)
  if n >= 4 then
    return nil
  end
  return dodh.aura_spells[n + 1]
end

-- Move the requester into Dreadspire Keep. The zone is static for now; the
-- library/lower-spire key gating is represented by flags, not zone locks.
function dodh.enter_dreadspire(client)
  client:Message(15, "You step through the seeing device into Dreadspire Keep.");
  client:MovePC(351, 0, 147, -1354, 0);
  return true;
end

return dodh;
