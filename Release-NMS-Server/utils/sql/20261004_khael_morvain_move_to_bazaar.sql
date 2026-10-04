-- ============================================================================
-- 2026-10-04 Move Khael the Spellforger and Morvain the Diminisher to Bazaar
--
-- Both item-tier NPCs spawned in the Guild Lobby. Move them into the Bazaar so
-- players can find the up-tier (Khael) and down-tier (Morvain) services there.
--
--   spawn2 id 2141246 -> bazaar at (36, -681, 3)   Khael the Spellforger
--   spawn2 id 2141247 -> bazaar at (36, -686, 3)   Morvain the Diminisher (beside Khael)
--
-- The quest scripts move from guildlobby/ to bazaar/ (EQEmu loads NPC scripts
-- by name per zone).
-- Idempotent.
-- ============================================================================

UPDATE spawn2
SET zone = 'bazaar',
    x    = 36,
    y    = -681,
    z    = 3
WHERE id = 2141246;

UPDATE spawn2
SET zone = 'bazaar',
    x    = 36,
    y    = -686,
    z    = 3
WHERE id = 2141247;
