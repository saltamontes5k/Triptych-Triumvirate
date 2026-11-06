-- v350 / v351 / v352 (2026-11-06) -- the card dealer layer.
-- Twin of database_update_manifest_custom.cpp v350 (lon_vendor_claim), v351 (retire
-- lon_account.progression_granted) and v352 (Tessa Shortfoot becomes Card Dealer Tessa).
--
-- Why: the every-account Oathbound starter gift is gone. Free starter decks and booster
-- sales are now the Bazaar card dealer's job (quests/bazaar/12000152.pl), which queues
-- products in lon_delivery; the claims it must not repeat are per account.

CREATE TABLE IF NOT EXISTS `lon_vendor_claim` (
  `account_id` int unsigned NOT NULL,
  `claim_key` varchar(32) NOT NULL,
  `claimed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`,`claim_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- v349's column for the removed gift. Nothing reads it any more.
ALTER TABLE `lon_account` DROP COLUMN `progression_granted`;

-- The vendor NPC: 12000152 was Tessa Shortfoot, a do-nothing Bazaar banker-class NPC
-- (spawn group 5002943, -210.5 -733.9 4.85). Class 1 keeps the bank window from opening
-- on a right-click; the dialogue is the whole interface.
UPDATE `npc_types`
   SET `name` = 'Card_Dealer_Tessa', `lastname` = 'Legends of Norrath', `class` = 1
 WHERE `id` = 12000152;

-- v353: the merchant row, between Katha Firespinner and the alchemist, facing the
-- same way as her neighbours (was the banker platform at -210.5 -733.9).
UPDATE `spawn2`
   SET `x` = 17.5, `y` = -736.7, `z` = 4.85, `heading` = 384
 WHERE `spawngroupID` = 5002943 AND `zone` = 'bazaar';
