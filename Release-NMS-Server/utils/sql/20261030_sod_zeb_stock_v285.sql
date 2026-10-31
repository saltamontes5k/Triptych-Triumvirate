-- 20261030_sod_zeb_stock_v285.sql - custom migration (v285)
-- Void Zebuxoruk stock brought to the raspersrealm themeVoid.html page,
-- plus the Kunark partisan task faction fix (v282's 19 duty tasks paid
-- no Tynoc faction; the v147 convention pays 1224 +150).
-- Twin content of manifest entry '20261030_sod_zeb_stock' (v285).
-- Idempotent: the merchantlist DELETE covers the whole v110 range and
-- every UPDATE is absolute.
--
-- Zebuxoruk merchants 459000-465000 = thevoida..thevoidg (v110).
-- The page's live-EQ scroll ids do not exist here (19015 is Ingot of
-- Sacrament in this Al'Kabor-lineage set); every page spell/tome maps
-- to this set's native base-rank item instead: 'Spell: X' / 'Song: X'
-- / 'Tome of X' (their scrolleffect values ARE the live page ids, so
-- the scribe path is identical).
-- Prices are plat stand-ins for the live purity points (v110
-- convention): spells/tomes = page points x 1000 (155k-195k by
-- version), Chronal Shears = purity x 10k, the Void C gear = page
-- points x 100 (matches the v110 Archaic 150k armor scale), Lesser /
-- Major quartzites interpolated (150k / 200k between v110's Minor
-- 100k / Greater 250k / Glowing 500k).

START TRANSACTION;

-- ============================================================
-- 1. Prices for the newly stocked page items.
-- ============================================================
UPDATE `items` SET `price` = 155000 WHERE `id` IN (118765,118250,119105,119150,118026,119429,118645,39306);
UPDATE `items` SET `price` = 165000 WHERE `id` IN (117846,118395,118770,118818,119066,118470,119207,118592,118967,119235,119452,118458,118102,118902);
UPDATE `items` SET `price` = 175000 WHERE `id` IN (117843,118244,119254,118434,119186,117907,118809,119438,119364,118089,118407,118020,117870,118741,118281,118190,118797,119305);
UPDATE `items` SET `price` = 185000 WHERE `id` IN (118126,118257,118108,118979,119446,119385,117932,118782,118887,118929,118446,117966,119033,118651);
UPDATE `items` SET `price` = 195000 WHERE `id` IN (117816,117828,117780,118869,118086,118148,119117,118428,119257,118860,118570,118791,118762,118630,119248,117913,117969,119030,118669,119093,117920,119299,118973);
UPDATE `items` SET `price` = 50000  WHERE `id` = 105873;  -- Faintly Pulsating Chronal Shear (5 purity)
UPDATE `items` SET `price` = 100000 WHERE `id` = 105874;  -- Dimly Pulsating Chronal Shear (10)
UPDATE `items` SET `price` = 150000 WHERE `id` = 105875;  -- Pulsating Chronal Shear (15)
UPDATE `items` SET `price` = 200000 WHERE `id` = 105876;  -- Brightly Pulsating Chronal Shear (20)
UPDATE `items` SET `price` = 250000 WHERE `id` = 105967;  -- Brilliantly Pulsating Chronal Shear (25)
UPDATE `items` SET `price` = 150000 WHERE `id` IN (103111,103121); -- Lesser Corrupted/Dyadic Quartzite
UPDATE `items` SET `price` = 200000 WHERE `id` IN (103112,103122); -- Major Corrupted/Dyadic Quartzite
-- Void C gear, page points x 100 (1425-1685):
UPDATE `items` SET `price` = 142500 WHERE `id` IN (106928,106940);
UPDATE `items` SET `price` = 143500 WHERE `id` IN (106929,106936,106941,106948);
UPDATE `items` SET `price` = 144500 WHERE `id` IN (106937,106949);
UPDATE `items` SET `price` = 145500 WHERE `id` IN (106939,106951);
UPDATE `items` SET `price` = 146500 WHERE `id` IN (106934,106946);
UPDATE `items` SET `price` = 147500 WHERE `id` IN (106930,106942);
UPDATE `items` SET `price` = 148500 WHERE `id` IN (106931,106943);
UPDATE `items` SET `price` = 151000 WHERE `id` IN (106932,106944);
UPDATE `items` SET `price` = 152500 WHERE `id` IN (106933,106945);
UPDATE `items` SET `price` = 153500 WHERE `id` IN (106938,106950);
UPDATE `items` SET `price` = 168500 WHERE `id` IN (106935,106947);

-- ============================================================
-- 2. Zebuxoruk stock, page-faithful per version.
-- ============================================================
DELETE FROM `merchantlist` WHERE `merchantid` BETWEEN 459000 AND 465000;

-- Void A: Silenced/Quiet Tinea, the Deviation Chamber, 16 cocoons.
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,1,103049);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,2,103050);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,3,103078);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,4,103062);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,5,103063);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,6,103064);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,7,103065);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,8,103066);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,9,103067);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,10,103068);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,11,103069);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,12,103070);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,13,103071);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,14,103072);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,15,103073);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,16,103074);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,17,103075);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,18,103076);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (459000,19,103077);

-- Void B: Archaic set, Chronal Shear, 6 spells + 2 tomes, Hushed/
-- Whispering Tinea, Minor Corrupted/Dyadic Quartzite (+ the two
-- non-page Minor Quartz grades v110 stocked, kept).
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,1,103300);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,2,103301);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,3,103302);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,4,103303);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,5,103304);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,6,103305);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,7,103306);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,8,103307);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,9,103308);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,10,103309);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,11,103310);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,12,103311);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,13,103312);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,14,103313);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,15,103314);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,16,103315);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,17,103316);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,18,103317);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,19,103318);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,20,103319);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,21,103320);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,22,103321);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,23,103322);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,24,103323);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,25,103324);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,26,103325);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,27,103326);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,28,103327);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,29,105873);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,30,118765); -- Spell: Finsternacht Orb
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,31,118250); -- Spell: Frondspur
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,32,119105); -- Spell: Mindshear Horror
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,33,119150); -- Spell: Talisman of the Lynx
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,34,118026); -- Spell: Vow of Valiance
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,35,119429); -- Spell: Wildmagic Blast
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,36,118645); -- Tome of Calanin's Synergy
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,37,39306);  -- Tome of Overpowering Frenzy
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,38,103051);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,39,103052);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,40,103110);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,41,103120);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,42,103115);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (460000,43,103125);

-- Void C: the 24-page gear set (Kithicor drop duplicates), Chronal
-- Shear, 13 spells + 1 tome, Rustling/Humming Tinea, Lesser pair +
-- the Minor combat band.
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,1,106928);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,2,106929);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,3,106930);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,4,106931);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,5,106932);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,6,106933);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,7,106934);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,8,106935);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,9,106936);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,10,106937);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,11,106938);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,12,106939);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,13,106940);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,14,106941);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,15,106942);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,16,106943);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,17,106944);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,18,106945);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,19,106946);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,20,106947);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,21,106948);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,22,106949);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,23,106950);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,24,106951);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,25,105874);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,26,117846); -- Song: Aura of Rodcet
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,27,118395); -- Spell: Befuddler's Aura
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,28,118770); -- Spell: Bonestitch Effigy
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,29,118818); -- Spell: Charge for Honor
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,30,119066); -- Spell: Charge for Power
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,31,118470); -- Spell: Dominating Aura
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,32,119207); -- Spell: Grezan's Drowse
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,33,118592); -- Spell: Jolt of Many
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,34,118967); -- Spell: Jolting Swings
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,35,119235); -- Spell: Listlessness
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,36,119452); -- Spell: Mindfreeze
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,37,118458); -- Spell: Runic Shimmer Aura
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,38,118102); -- Spell: Twelfth Night
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,39,118902); -- Tome of Jolting Frontkicks
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,40,103053);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,41,103054);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,42,103111);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,43,103121);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,44,103130);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,45,103135);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,46,103140);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,47,103145);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (461000,48,103150);

-- Void D: Temporal Polymorphic Cell, Culling Vortexes, Chronal Shear,
-- 17 spells + 1 tome, Murmuring Tinea, Major pair + 105 combat band.
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,1,42961);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,2,103057);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,3,103058);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,4,105875);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,5,117843);  -- Song: Pests of the Piper
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,6,118244);  -- Spell: Annihilate the Anomalous
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,7,119254);  -- Spell: Antecedent's Intervention
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,8,118434);  -- Spell: Aura of Abstract Acumen
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,9,119186);  -- Spell: Bite of the Ukun
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,10,117907); -- Spell: Bite of the Vitrik
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,11,118809); -- Spell: Burst of Dawnlight
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,12,119438); -- Spell: Funnel of Frigidity
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,13,119364); -- Spell: Gelid Snap
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,14,118089); -- Spell: Holy Ground
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,15,118407); -- Spell: Mana Reiterate
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,16,118020); -- Spell: Promised Recuperation
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,17,117870); -- Spell: Promised Rejuvenation (page: Rejuvination)
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,18,118741); -- Spell: Pyre of the Forgotten
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,19,118281); -- Spell: Survival of the Felicitous
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,20,118190); -- Spell: Winter's Flare
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,21,118797); -- Spell: Withering Decay
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,22,119305); -- Tome of Shield Topple
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,23,103055);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,24,103112);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,25,103122);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,26,103131);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,27,103136);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,28,103141);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,29,103146);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (462000,30,103151);

-- Void E: Chronal Shear, 11 spells + 3 tomes, Temporal Molting Cell,
-- the three Prismatic Mutation Nexuses, Greater pair (+ the two
-- non-page Greater Quartz grades v110 stocked, kept) + 125 combat band.
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,1,105876);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,2,118126);  -- Spell: Blessed Aquifer
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,3,118257);  -- Spell: Carapace of the Reptile
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,4,118108);  -- Spell: Chromassail
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,5,118979);  -- Spell: Devastating Blades
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,6,119446);  -- Spell: Ethereal Iceblight
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,7,119385);  -- Spell: Flashblaze
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,8,117932);  -- Spell: Growl of the Jaguar
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,9,118782);  -- Spell: Soul Reaper's Pyre
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,10,118887); -- Spell: Steely Stance
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,11,118929); -- Spell: Summer's Mist
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,12,118446); -- Spell: Twincast Aura
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,13,117966); -- Tome of Eradicator's Volley
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,14,119033); -- Tome of Procure Sap
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,15,118651); -- Tome of Whorl of Fists
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,16,103056);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,17,103059);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,18,103060);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,19,103061);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,20,103113);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,21,103123);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,22,103118);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,23,103128);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,24,103132);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,25,103137);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,26,103142);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,27,103147);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (463000,28,103152);

-- Void F: Chronal Shear, 16 spells/songs + 7 tomes, the Greater combat
-- band, Glowing Corrupted/Dyadic Quartzite (moved here from G per page).
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,1,105967);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,2,117816);  -- Song: Arcane Arietta
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,3,117828);  -- Song: Cantata of Courage
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,4,117780);  -- Song: Gruber's Lively Crescendo
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,5,118869);  -- Spell: Aurora of Dawnlight
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,6,118086);  -- Spell: Blood of the Unsullied
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,7,118148);  -- Spell: Nature's Searing Wrath
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,8,119117);  -- Spell: Malarian Skin
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,9,118428);  -- Spell: Mana Reiterate Aura (page: Reiturate)
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,10,119257); -- Spell: Pack of Aina
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,11,118860); -- Spell: Preservation of Tunare
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,12,118570); -- Spell: Rumbling Servant
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,13,118791); -- Spell: Scorching Shadow
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,14,118762); -- Spell: Slitheren Venom
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,15,118630); -- Spell: Twincast
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,16,119248); -- Spell: Ward of Restoration
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,17,117913); -- Spell: Yowl at the Moon
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,18,117969); -- Tome of Combat Frenzy
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,19,119030); -- Tome of Daggerlunge
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,20,118669); -- Tome of Defer Death
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,21,119093); -- Tome of Final Breath
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,22,117920); -- Tome of Foray
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,23,119299); -- Tome of Knuckle Crush
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,24,118973); -- Tome of Sureshot Discipline
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,25,103133);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,26,103138);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,27,103143);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,28,103148);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,29,103153);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,30,103114);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (464000,31,103124);

-- Void G: the Glowing Quartz family (page G list; the two Glowing
-- Quartzites moved to F).
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,1,103119);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,2,103129);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,3,103134);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,4,103139);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,5,103144);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,6,103149);
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (465000,7,103154);

-- ============================================================
-- 3. Kunark partisan tasks raise Tynoc, Herald of Scale (1224),
--    the v147 theme convention (page: theme quests raise Tynoc).
-- ============================================================
UPDATE `tasks` SET `faction_reward` = 1224, `faction_amount` = 150 WHERE `id` BETWEEN 303200 AND 303218;

COMMIT;
