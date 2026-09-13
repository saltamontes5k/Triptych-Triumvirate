UPDATE npc_types SET name = 'Mal\'zeth_V\'Tide' WHERE id = 1120001125;

UPDATE npc_types SET name = 'First_Ripple', race = 211, bodytype = 24, model = 0 WHERE id = 12000195;

UPDATE items SET Name = 'A Shimmering Writ', lore = 'From First Ripple' WHERE id = 18471;

UPDATE books SET name = 'FirstRippleWrit', txtfile = 'The current has carried you back to me.\r\n\r\nThe deep remembers what you have forgotten.\r\n\r\nCome meet me in the Bazaar and I will explain.\r\n\r\nHow? I have already shown you the way! \r\n\r\nOpen your AA window\r\n\r\nThen make a hotkey for Bazaar and Back and click it.\r\n\r\nLooking forward to drifting together again, old friend.\r\n\r\n-First Ripple' WHERE id = 437;

UPDATE items SET filename = 'FirstRippleWrit' WHERE id = 18471;

UPDATE items_reference SET filename = 'FirstRippleWrit' WHERE id = 18471;
