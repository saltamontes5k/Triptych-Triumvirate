-- ============================================================================
-- Endgame revamp -- Prismatic Scale augs + Quarm's Plane of Time drops
-- Date: 2026-10-04
--
-- The 16 Prismatic Scale raid augs (PoP endgame: 1801, 1802, 9600-9612,
-- 17730) sat at 60/60/5 with zero heroics (Legendary 1/1/2) -- far below the
-- soul-aug standard (L70 305 / L75 327 / L85 370 hp+mana+ac). Quarm (the PoP
-- endboss, npc 223201) drops no augment at all; his signature drops (Whorl of
-- Unnatural Forces 27280, Stone of Flowing Time 26987, Prismatic Ring of
-- Resistance 26989) already carry the era's strongest numerics but no
-- heroics.
--
-- Direct sets (GREATEST guards -- nothing is nerfed):
--   * Prismatic Scales: base 160/160/25 + thematic heroics at 6 (Elements
--     gets a triple); Enchanted = 2x numerics + 12s; Legendary = 2x + 18s.
--   * Whorl of Unnatural Forces: 240/210/90 + hSta/hMR/hFR 10 (tiers 2x/3x).
--   * Stone of Flowing Time: 235/205/40 + hInt/hWis/hCR 8 (tiers 2x/3x).
--   * Prismatic Ring of Resistance: 225/225/35 + hMR/hFR/hCR 8 (tiers 2x/3x).
--
-- Sentinel for the migration check: Prismatic Scale of Cleaving (1801) hp = 160.
-- Twin of ManifestEntry .version = 105 in
-- common/database/database_update_manifest_custom.cpp
-- ==========================================================================="""

-- Prismatic Scale of Cleaving (1801) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_str = GREATEST(heroic_str, 6), heroic_dex = GREATEST(heroic_dex, 6) WHERE id = 1801;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_str = GREATEST(heroic_str, 12), heroic_dex = GREATEST(heroic_dex, 12) WHERE id = 1801 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_str = GREATEST(heroic_str, 18), heroic_dex = GREATEST(heroic_dex, 18) WHERE id = 1801 + 2000000;
-- Prismatic Scale of Ferocity (1802) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_str = GREATEST(heroic_str, 6), heroic_sta = GREATEST(heroic_sta, 6) WHERE id = 1802;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_str = GREATEST(heroic_str, 12), heroic_sta = GREATEST(heroic_sta, 12) WHERE id = 1802 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_str = GREATEST(heroic_str, 18), heroic_sta = GREATEST(heroic_sta, 18) WHERE id = 1802 + 2000000;
-- Prismatic Scale of Sharpshooting (9600) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_dex = GREATEST(heroic_dex, 6), heroic_agi = GREATEST(heroic_agi, 6) WHERE id = 9600;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_dex = GREATEST(heroic_dex, 12), heroic_agi = GREATEST(heroic_agi, 12) WHERE id = 9600 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_dex = GREATEST(heroic_dex, 18), heroic_agi = GREATEST(heroic_agi, 18) WHERE id = 9600 + 2000000;
-- Prismatic Scale of Blocking (9601) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_sta = GREATEST(heroic_sta, 6), heroic_agi = GREATEST(heroic_agi, 6) WHERE id = 9601;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 12), heroic_agi = GREATEST(heroic_agi, 12) WHERE id = 9601 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 18), heroic_agi = GREATEST(heroic_agi, 18) WHERE id = 9601 + 2000000;
-- Prismatic Scale of Dodging (9602) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_agi = GREATEST(heroic_agi, 6), heroic_mr = GREATEST(heroic_mr, 6) WHERE id = 9602;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_agi = GREATEST(heroic_agi, 12), heroic_mr = GREATEST(heroic_mr, 12) WHERE id = 9602 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_agi = GREATEST(heroic_agi, 18), heroic_mr = GREATEST(heroic_mr, 18) WHERE id = 9602 + 2000000;
-- Prismatic Scale of Magic (9603) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_int = GREATEST(heroic_int, 6), heroic_cha = GREATEST(heroic_cha, 6) WHERE id = 9603;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 12), heroic_cha = GREATEST(heroic_cha, 12) WHERE id = 9603 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 18), heroic_cha = GREATEST(heroic_cha, 18) WHERE id = 9603 + 2000000;
-- Prismatic Scale of Affliction (9604) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_int = GREATEST(heroic_int, 6), heroic_dr = GREATEST(heroic_dr, 6) WHERE id = 9604;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 12), heroic_dr = GREATEST(heroic_dr, 12) WHERE id = 9604 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 18), heroic_dr = GREATEST(heroic_dr, 18) WHERE id = 9604 + 2000000;
-- Prismatic Scale of Enhancement (9605) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_wis = GREATEST(heroic_wis, 6), heroic_cha = GREATEST(heroic_cha, 6) WHERE id = 9605;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 12), heroic_cha = GREATEST(heroic_cha, 12) WHERE id = 9605 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 18), heroic_cha = GREATEST(heroic_cha, 18) WHERE id = 9605 + 2000000;
-- Prismatic Scale of Torment (9606) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_sta = GREATEST(heroic_sta, 6), heroic_mr = GREATEST(heroic_mr, 6) WHERE id = 9606;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 12), heroic_mr = GREATEST(heroic_mr, 12) WHERE id = 9606 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 18), heroic_mr = GREATEST(heroic_mr, 18) WHERE id = 9606 + 2000000;
-- Prismatic Scale of Healing (9607) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_wis = GREATEST(heroic_wis, 6), heroic_mr = GREATEST(heroic_mr, 6) WHERE id = 9607;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 12), heroic_mr = GREATEST(heroic_mr, 12) WHERE id = 9607 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 18), heroic_mr = GREATEST(heroic_mr, 18) WHERE id = 9607 + 2000000;
-- Prismatic Scale of Summoning (9608) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_cha = GREATEST(heroic_cha, 6), heroic_sta = GREATEST(heroic_sta, 6) WHERE id = 9608;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_cha = GREATEST(heroic_cha, 12), heroic_sta = GREATEST(heroic_sta, 12) WHERE id = 9608 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_cha = GREATEST(heroic_cha, 18), heroic_sta = GREATEST(heroic_sta, 18) WHERE id = 9608 + 2000000;
-- Prismatic Scale of Range (9609) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_agi = GREATEST(heroic_agi, 6), heroic_str = GREATEST(heroic_str, 6) WHERE id = 9609;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_agi = GREATEST(heroic_agi, 12), heroic_str = GREATEST(heroic_str, 12) WHERE id = 9609 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_agi = GREATEST(heroic_agi, 18), heroic_str = GREATEST(heroic_str, 18) WHERE id = 9609 + 2000000;
-- Prismatic Scale of Hastened Casting (9610) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_int = GREATEST(heroic_int, 6), heroic_dex = GREATEST(heroic_dex, 6) WHERE id = 9610;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 12), heroic_dex = GREATEST(heroic_dex, 12) WHERE id = 9610 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_int = GREATEST(heroic_int, 18), heroic_dex = GREATEST(heroic_dex, 18) WHERE id = 9610 + 2000000;
-- Prismatic Scale of Preservation (9611) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_sta = GREATEST(heroic_sta, 6), heroic_cr = GREATEST(heroic_cr, 6) WHERE id = 9611;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 12), heroic_cr = GREATEST(heroic_cr, 12) WHERE id = 9611 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_sta = GREATEST(heroic_sta, 18), heroic_cr = GREATEST(heroic_cr, 18) WHERE id = 9611 + 2000000;
-- Prismatic Scale of Faerune (9612) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_wis = GREATEST(heroic_wis, 6), heroic_agi = GREATEST(heroic_agi, 6) WHERE id = 9612;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 12), heroic_agi = GREATEST(heroic_agi, 12) WHERE id = 9612 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_wis = GREATEST(heroic_wis, 18), heroic_agi = GREATEST(heroic_agi, 18) WHERE id = 9612 + 2000000;
-- Prismatic Scale of Elements (17730) + tiers
UPDATE items SET hp = GREATEST(hp, 160), mana = GREATEST(mana, 160), ac = GREATEST(ac, 25), heroic_mr = GREATEST(heroic_mr, 6), heroic_fr = GREATEST(heroic_fr, 6), heroic_cr = GREATEST(heroic_cr, 6) WHERE id = 17730;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_mr = GREATEST(heroic_mr, 12), heroic_fr = GREATEST(heroic_fr, 12), heroic_cr = GREATEST(heroic_cr, 12) WHERE id = 17730 + 1000000;
UPDATE items SET hp = GREATEST(hp, 320), mana = GREATEST(mana, 320), ac = GREATEST(ac, 50), heroic_mr = GREATEST(heroic_mr, 18), heroic_fr = GREATEST(heroic_fr, 18), heroic_cr = GREATEST(heroic_cr, 18) WHERE id = 17730 + 2000000;

-- Quarm's Plane of Time drops + tiers
-- Prismatic Ring of Resistance (26989)
UPDATE items SET hp = GREATEST(hp, 225), mana = GREATEST(mana, 225), ac = GREATEST(ac, 35), heroic_mr = GREATEST(heroic_mr, 8), heroic_fr = GREATEST(heroic_fr, 8), heroic_cr = GREATEST(heroic_cr, 8) WHERE id = 26989;
UPDATE items SET hp = GREATEST(hp, 450), mana = GREATEST(mana, 450), ac = GREATEST(ac, 70), heroic_mr = GREATEST(heroic_mr, 16), heroic_fr = GREATEST(heroic_fr, 16), heroic_cr = GREATEST(heroic_cr, 16) WHERE id = 26989 + 1000000;
UPDATE items SET hp = GREATEST(hp, 450), mana = GREATEST(mana, 450), ac = GREATEST(ac, 70), heroic_mr = GREATEST(heroic_mr, 24), heroic_fr = GREATEST(heroic_fr, 24), heroic_cr = GREATEST(heroic_cr, 24) WHERE id = 26989 + 2000000;

