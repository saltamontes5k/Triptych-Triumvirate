-- Bazaar zone boot marker for the glamour vendor stock rotation.
--
-- Runs once per zone process boot (lua_parser loads <zone>/script_init.lua at
-- parser init). The fresh value + 7-day expiry drive the re-roll check in
-- quests/bazaar/Stablehand_Ponyboy.pl:
--   - a changed marker means "fresh zone/world boot since the last roll";
--   - an expired (undef) marker means "7 days elapsed while the server stayed
--     up", which is the weekly arm.
-- If this boot-time write ever fails, the Ponyboy driver re-arms the marker
-- itself and the behaviour degrades to a rare extra re-roll, never a stale one.

quest.set_data("bazaar_boot_marker", tostring(os.time()), "604800")
