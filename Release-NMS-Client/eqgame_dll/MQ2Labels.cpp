// MQ2Labels.cpp : Defines the entry point for the DLL application.
//

// MQ2 Custom Labels


#include "MQ2Main.h"
#include <sstream>
#include <cstdint>
#include "core_log.h"


// NMS: 3-letter abbreviations
static const char* ClassAbbr[17] =
{
	"",     // 0 unused
	"WAR",  // 1
	"CLR",  // 2
	"PAL",  // 3
	"RNG",  // 4
	"SHD",  // 5
	"DRU",  // 6
	"MNK",  // 7
	"BRD",  // 8
	"ROG",  // 9
	"SHM",  // 10
	"NEC",  // 11
	"WIZ",  // 12
	"MAG",  // 13
	"ENC",  // 14
	"BST",  // 15
	"BER"   // 16
};

// NMS: Server-mirrored class title resolver
static const char* GetClassTitle(BYTE class_id, BYTE level)

{
	switch (class_id)
	{
	case 1: // Warrior
		if (level >= 75) return "Imperator";
		if (level >= 70) return "Vanquisher";
		if (level >= 65) return "Overlord";
		if (level >= 60) return "Warlord";
		if (level >= 55) return "Myrmidon";
		if (level >= 51) return "Champion";
		return "Warrior";

	case 2: // Cleric
		if (level >= 75) return "Exemplar";
		if (level >= 70) return "Prelate";
		if (level >= 65) return "Archon";
		if (level >= 60) return "HighPriest";
		if (level >= 55) return "Templar";
		if (level >= 51) return "Vicar";
		return "Cleric";

	case 3: // Paladin
		if (level >= 75) return "HolyDefender";
		if (level >= 70) return "Lord";
		if (level >= 65) return "LordProtector";
		if (level >= 60) return "Crusader";
		if (level >= 55) return "Knight";
		if (level >= 51) return "Cavalier";
		return "Paladin";

	case 4: // Ranger
		if (level >= 75) return "Huntmaster";
		if (level >= 70) return "Plainswalker";
		if (level >= 65) return "ForestStalker";
		if (level >= 60) return "Warder";
		if (level >= 55) return "Outrider";
		if (level >= 51) return "Pathfinder";
		return "Ranger";

	case 5: // Shadow Knight
		if (level >= 75) return "Bloodreaver";
		if (level >= 70) return "ScourgeKnight";
		if (level >= 65) return "DreadLord";
		if (level >= 60) return "GraveLord";
		if (level >= 55) return "Revenant";
		if (level >= 51) return "Reaver";
		return "ShadowKnight";

	case 6: // Druid
		if (level >= 75) return "StormCaller";
		if (level >= 70) return "Natureguard";
		if (level >= 65) return "StormWarden";
		if (level >= 60) return "Hierophant";
		if (level >= 55) return "Preserver";
		if (level >= 51) return "Wanderer";
		return "Druid";

	case 7: // Monk
		if (level >= 75) return "Ashenhand";
		if (level >= 70) return "StoneFist";
		if (level >= 65) return "Transcendent";
		if (level >= 60) return "Grandmaster";
		if (level >= 55) return "Master";
		if (level >= 51) return "Disciple";
		return "Monk";

	case 8: // Bard
		if (level >= 75) return "Lyricist";
		if (level >= 70) return "Performer";
		if (level >= 65) return "Maestro";
		if (level >= 60) return "Virtuoso";
		if (level >= 55) return "Troubadour";
		if (level >= 51) return "Minstrel";
		return "Bard";

	case 9: // Rogue
		if (level >= 75) return "Shadowblade";
		if (level >= 70) return "Nemesis";
		if (level >= 65) return "Deceiver";
		if (level >= 60) return "Assassin";
		if (level >= 55) return "Blackguard";
		if (level >= 51) return "Rake";
		return "Rogue";

	case 10: // Shaman
		if (level >= 75) return "Spiritwatcher";
		if (level >= 70) return "Soothsayer";
		if (level >= 65) return "Prophet";
		if (level >= 60) return "Oracle";
		if (level >= 55) return "Luminary";
		if (level >= 51) return "Mystic";
		return "Shaman";

	case 11: // Necromancer
		if (level >= 75) return "Deathcaller";
		if (level >= 70) return "Wraith";
		if (level >= 65) return "ArchLich";
		if (level >= 60) return "Warlock";
		if (level >= 55) return "Defiler";
		if (level >= 51) return "Heretic";
		return "Necromancer";

	case 12: // Wizard
		if (level >= 75) return "Pyromancer";
		if (level >= 70) return "GrandArcanist";
		if (level >= 65) return "Arcanist";
		if (level >= 60) return "Sorcerer";
		if (level >= 55) return "Evoker";
		if (level >= 51) return "Channeler";
		return "Wizard";

	case 13: // Magician
		if (level >= 75) return "GrandSummoner";
		if (level >= 70) return "ArchMagus";
		if (level >= 65) return "ArchConvoker";
		if (level >= 60) return "ArchMage";
		if (level >= 55) return "Conjurer";
		if (level >= 51) return "Elementalist";
		return "Magician";

	case 14: // Enchanter
		if (level >= 75) return "Entrancer";
		if (level >= 70) return "Bedazzler";
		if (level >= 65) return "Coercer";
		if (level >= 60) return "Phantasmist";
		if (level >= 55) return "Beguiler";
		if (level >= 51) return "Illusionist";
		return "Enchanter";

	case 15: // Beastlord
		if (level >= 75) return "Frostblood";
		if (level >= 70) return "Wildblood";
		if (level >= 65) return "FeralLord";
		if (level >= 60) return "SavageLord";
		if (level >= 55) return "Animist";
		if (level >= 51) return "Primalist";
		return "Beastlord";

	case 16: // Berserker
		if (level >= 75) return "Juggernaut";
		if (level >= 70) return "Ravager";
		if (level >= 65) return "Fury";
		if (level >= 60) return "Rager";
		if (level >= 55) return "Vehement";
		if (level >= 51) return "Brawler";
		return "Berserker";
	}

	return "Unknown";
}

typedef enum eStatEntry
{
	eStatClassesBitmask = 1,
	eStatCurHP,
	eStatCurMana,
	eStatCurEndur,
	eStatMaxHP,
	eStatMaxMana,
	eStatMaxEndur,
	eStatMitigation,
	eStatEvasion,
	eStatSTR,
	eStatSTA,
	eStatDEX,
	eStatAGI,
	eStatINT,
	eStatWIS,
	eStatCHA,
	eStatMR,
	eStatFR,
	eStatCR,
	eStatDR,
	eStatPR,
	eStatHPRegen,
	eStatManaRegen,
	eStatEndurRegen,
	eStatATK,
	eStatHaste,
	eStatHeroicSTR,
	eStatHeroicSTA,
	eStatHeroicDEX,
	eStatHeroicAGI,
	eStatHeroicINT,
	eStatHeroicWIS,
	eStatHeroicCHA,
	eStatHeroicMR,
	eStatHeroicFR,
	eStatHeroicCR,
	eStatHeroicDR,
	eStatHeroicPR,
	eStatAC,
	eStatSpellDmg,
	eStatHealAmt,
	eStatCombatEffects,
	eStatSpellShield,
	eStatShielding,
	eStatDamageShield,
	eStatDoTShield,
	eStatDSMitigation,
	eStatAvoidance,
	eStatAccuracy,
	eStatStunResist,
	eStatStrikethrough,
	eStatClairvoyance,
	eStatShieldAC,
	eStatSpellCastTime01,
	eStatSpellCastTime02,
	eStatSpellCastTime03,
	eStatSpellCastTime04,
	eStatSpellCastTime05,
	eStatSpellCastTime06,
	eStatSpellCastTime07,
	eStatSpellCasttime08,
	eStatSpellCastTime09,
	eStatSpellCastTime10,
	eStatSpellCastTime11,
	eStatSpellCastTime12,
	eStatTrackingValue,
	eStatAttackMode,
	eStatWornATK,
	eStatItemEXP,
	eStatSpellCritRate,
	eStatSpellCritRatio,
	eStatHealCritRate,
	eStatHoTCritRate,
	eStatDoTCritRate,
	eStatDoTCritRatio,
	eStatMeleeCritRate,
	eStatMeleeCritRatio,
	eStatPetFlurryRate,
	eStatPetMeleeCritRate,
	eStatPetAvoidance,
	eStatPetMeleeMitigation,
	eStatPrimaryActualDelay,
	eStatSecondaryActualDelay,
	eStatPet0Taunt,
	eStatPet1Taunt,
	eStatPet2Taunt,
	eStatPet0Hold,
	eStatPet1Hold,
	eStatPet2Hold,
	eStatPet0GHold,
	eStatPet1GHold,
	eStatPet2GHold,
	eStatPet0Focus,
	eStatPet1Focus,
	eStatPet2Focus,
	eStatPet0Spellhold,
	eStatPet1Spellhold,
	eStatPet2Spellhold,
	eStatPet0SPO,
	eStatPet1SPO,
	eStatPet2SPO,
	eStatCapSpellShield,
	eStatCapShielding,
	eStatCapDamageShield,
	eStatCapDoTShield,
	eStatCapDSMitigation,
	eStatCapAvoidance,
	eStatCapAccuracy,
	eStatCapStunResist,
	eStatCapStrikethrough,
	eStatCapCombatEffects,
	eStatCapHealAmount,
	eStatCapSpellDamage,
	eStatCapWornATK,
	eStatCapClairvoyance,
	eStatArcheryCritRate,
	eStatRuneAmount,
	eStatSpellRuneAmount,
	eStatCapSTR,
	eStatCapSTA,
	eStatCapDEX,
	eStatCapAGI,
	eStatCapINT,
	eStatCapWIS,
	eStatCapCHA,
	eStatCapMR,
	eStatCapFR,
	eStatCapCR,
	eStatCapDR,
	eStatCapPR,
	eStatDummyValue,
	eStatMax
};

typedef enum EQLabelTypes {
	Name = 1,
	Level = 2,
	Class = 3,
	Deity = 4,
	Strength = 5,
	Stamina = 6,
	Dexterity = 7,
	Agility = 8,
	Wisdom = 9,
	Intelligence = 10,
	Charisma = 11,
	SavevsPoison = 12,
	SavevsDisease = 13,
	SavevsFire = 14,
	SavevsCold = 15,
	SavevsMagic = 16,
	CurrentHitPoints = 17,
	MaximumHitPoints = 18,
	HitPointPercentage = 19,
	ManaPercentage = 20,
	StaminaEndurancePercentage = 21,
	CurrentMitigation = 22,
	CurrentOffense = 23,
	Weight = 24,
	MaximumWeight = 25,
	ExperiencePercentage = 26,
	AlternateExperiencePercentage = 27,
	TargetName = 28,
	TargetHitPointPercentage = 29,
	GroupMember1Name = 30,
	GroupMember2Name = 31,
	GroupMember3Name = 32,
	GroupMember4Name = 33,
	GroupMember5Name = 34,
	GroupMember1HealthPercentage = 35,
	GroupMember2HealthPercentage = 36,
	GroupMember3HealthPercentage = 37,
	GroupMember4HealthPercentage = 38,
	GroupMember5HealthPercentage = 39,
	GroupPet1HealthPercentage = 40,
	GroupPet2HealthPercentage = 41,
	GroupPet3HealthPercentage = 42,
	GroupPet4HealthPercentage = 43,
	GroupPet5HealthPercentage = 44,
	Buff0 = 45,
	Buff1 = 46,
	Buff2 = 47,
	Buff3 = 48,
	Buff4 = 49,
	Buff5 = 50,
	Buff6 = 51,
	Buff7 = 52,
	Buff8 = 53,
	Buff9 = 54,
	Buff10 = 55,
	Buff11 = 56,
	Buff12 = 57,
	Buff13 = 58,
	Buff14 = 59,
	Spell1 = 60,
	Spell2 = 61,
	Spell3 = 62,
	Spell4 = 63,
	Spell5 = 64,
	Spell6 = 65,
	Spell7 = 66,
	Spell8 = 67,
	PlayersPetName = 68,
	PlayersPetHPPercent = 69,
	PlayersCurrentHP = 70,
	CurrentAlternateAdvancementPointsAvailabletoSpend = 71,
	CurrentExperiencePercentageAssignedtoAlternateAdvancement = 72,
	CharacterLastName = 73,
	CharacterTitle = 74,
	CurrentMP3SongName = 75,
	CurrentMP3SongDurationMinutesValue = 76,
	CurrentMP3SongDurationSecondsValue = 77,
	CurrentMP3SongPositionMinutesValue = 78,
	CurrentMP3SongPositionSecondsValue = 79,
	Song1 = 80,
	Song2 = 81,
	Song3 = 82,
	Song4 = 83,
	Song5 = 84,
	Song6 = 85,
	PetBuff1 = 86,
	PetBuff2 = 87,
	PetBuff3 = 88,
	PetBuff4 = 89,
	PetBuff5 = 90,
	PetBuff6 = 91,
	PetBuff7 = 92,
	PetBuff8 = 93,
	PetBuff9 = 94,
	PetBuff10 = 95,
	PetBuff11 = 96,
	PetBuff12 = 97,
	PetBuff13 = 98,
	PetBuff14 = 99,
	PetBuff15 = 100,
	PetBuff16 = 101,
	PetBuff17 = 102,
	PetBuff18 = 103,
	PetBuff19 = 104,
	PetBuff20 = 105,
	PetBuff21 = 106,
	PetBuff22 = 107,
	PetBuff23 = 108,
	PetBuff24 = 109,
	PetBuff25 = 110,
	PetBuff26 = 111,
	PetBuff27 = 112,
	PetBuff28 = 113,
	PetBuff29 = 114,
	PetBuff30 = 115,
	PersonalTributeTimer = 116,
	CurrentAmountofTributePoints = 117,
	TotalCareerTribute = 118,
	TributeCostPer10Mins = 119,
	TargetofTargetPercentage = 120,
	GuildTributeTimer = 121,
	GuildTributePool = 122,
	GuildTributePayment = 123,
	ManaNumber = 124,
	ManaNumberMax = 125,
	EnduranceNumber = 126,
	EnduranceNumberMax = 127,
	ManaMaxMana = 128,
	EnduranceMaxEndurance = 129,
	None130 = 130,
	None131 = 131,
	TaskSystemDurationTimer = 132,
	Spell9 = 133,
	CastingSpellName = 134,
	TargetofTargetName = 135,
	CorruptionResist = 136,
	PlayerCombatTimerLabel = 137,
	Spell10 = 138,
	GroupMember1ManaPercentage = 139,
	GroupMember2ManaPercentage = 140,
	GroupMember3ManaPercentage = 141,
	GroupMember4ManaPercentage = 142,
	GroupMember5ManaPercentage = 143,
	GroupMember1EndurancePercentage = 144,
	GroupMember2EndurancePercentage = 145,
	GroupMember3EndurancePercentage = 146,
	GroupMember4EndurancePercentage = 147,
	GroupMember5EndurancePercentage = 148,
	Spell11 = 149,
	Spell12 = 150,
	HPPercentageExtendedTargetWindow0 = 151,
	HPPercentageExtendedTargetWindow1 = 152,
	HPPercentageExtendedTargetWindow2 = 153,
	HPPercentageExtendedTargetWindow3 = 154,
	HPPercentageExtendedTargetWindow4 = 155,
	HPPercentageExtendedTargetWindow5 = 156,
	HPPercentageExtendedTargetWindow6 = 157,
	HPPercentageExtendedTargetWindow7 = 158,
	HPPercentageExtendedTargetWindow8 = 159,
	HPPercentageExtendedTargetWindow9 = 160,
	HPPercentageExtendedTargetWindow10 = 161,
	HPPercentageExtendedTargetWindow11 = 162,
	HPPercentageExtendedTargetWindow12 = 163,
	HPPercentageExtendedTargetWindow13 = 164,
	HPPercentageExtendedTargetWindow14 = 165,
	HPPercentageExtendedTargetWindow15 = 166,
	HPPercentageExtendedTargetWindow16 = 167,
	HPPercentageExtendedTargetWindow17 = 168,
	HPPercentageExtendedTargetWindow18 = 169,
	HPPercentageExtendedTargetWindow19 = 170,
	ManaPercentageExtendedTargetWindow0 = 171,
	ManaPercentageExtendedTargetWindow1 = 172,
	ManaPercentageExtendedTargetWindow2 = 173,
	ManaPercentageExtendedTargetWindow3 = 174,
	ManaPercentageExtendedTargetWindow4 = 175,
	ManaPercentageExtendedTargetWindow5 = 176,
	ManaPercentageExtendedTargetWindow6 = 177,
	ManaPercentageExtendedTargetWindow7 = 178,
	ManaPercentageExtendedTargetWindow8 = 179,
	ManaPercentageExtendedTargetWindow9 = 180,
	ManaPercentageExtendedTargetWindow10 = 181,
	ManaPercentageExtendedTargetWindow11 = 182,
	ManaPercentageExtendedTargetWindow12 = 183,
	ManaPercentageExtendedTargetWindow13 = 184,
	ManaPercentageExtendedTargetWindow14 = 185,
	ManaPercentageExtendedTargetWindow15 = 186,
	ManaPercentageExtendedTargetWindow16 = 187,
	ManaPercentageExtendedTargetWindow17 = 188,
	ManaPercentageExtendedTargetWindow18 = 189,
	ManaPercentageExtendedTargetWindow19 = 190,
	EndurancePercentageExtendedTargetWindow0 = 191,
	EndurancePercentageExtendedTargetWindow1 = 192,
	EndurancePercentageExtendedTargetWindow2 = 193,
	EndurancePercentageExtendedTargetWindow3 = 194,
	EndurancePercentageExtendedTargetWindow4 = 195,
	EndurancePercentageExtendedTargetWindow5 = 196,
	EndurancePercentageExtendedTargetWindow6 = 197,
	EndurancePercentageExtendedTargetWindow7 = 198,
	EndurancePercentageExtendedTargetWindow8 = 199,
	EndurancePercentageExtendedTargetWindow9 = 200,
	EndurancePercentageExtendedTargetWindow10 = 201,
	EndurancePercentageExtendedTargetWindow11 = 202,
	EndurancePercentageExtendedTargetWindow12 = 203,
	EndurancePercentageExtendedTargetWindow13 = 204,
	EndurancePercentageExtendedTargetWindow14 = 205,
	EndurancePercentageExtendedTargetWindow15 = 206,
	EndurancePercentageExtendedTargetWindow16 = 207,
	EndurancePercentageExtendedTargetWindow17 = 208,
	EndurancePercentageExtendedTargetWindow18 = 209,
	EndurancePercentageExtendedTargetWindow19 = 210,
	Haste = 211,
	HitPointRegeneration = 212,
	ManaRegeneration = 213,
	EnduranceRegeneration = 214,
	SpellShield = 215,
	CombatEffects = 216,
	Shielding = 217,
	DamageShielding = 218,
	DamageOverTimeShielding = 219,
	DamageShieldMitigation = 220,
	Avoidance = 221,
	Accuracy = 222,
	StunResist = 223,
	StrikeThrough = 224,
	HealAmount = 225,
	SpellDamage = 226,
	Clairvoyance = 227,
	SkillDamageBash = 228,
	SkillDamageBackstab = 229,
	SkillDamageDragonpunch = 230,
	SkillDamageEaglestrike = 231,
	SkillDamageFlyingkick = 232,
	SkillDamageKick = 233,
	SkillDamageRoundkick = 234,
	SkillDamageTigerclaw = 235,
	SkillDamageFrenzy = 236,
	WeightMaxWeight = 237,
	BaseStrength = 238,
	BaseStamina = 239,
	BaseDexterity = 240,
	BaseAgility = 241,
	BaseWisdom = 242,
	BaseIntelligence = 243,
	BaseCharisma = 244,
	BaseSavevsPoison = 245,
	BaseSavevsDisease = 246,
	BaseSavevsFire = 247,
	BaseSavevsCold = 248,
	BaseSavevsMagic = 249,
	BaseSavevsCorruption = 250,
	HeroicStrength = 251,
	HeroicStamina = 252,
	HeroicDexterity = 253,
	HeroicAgility = 254,
	HeroicWisdom = 255,
	HeroicIntelligence = 256,
	HeroicCharisma = 257,
	HeroicSavevsPoison = 258,
	HeroicSavevsDisease = 259,
	HeroicSavevsFire = 260,
	HeroicSavevsCold = 261,
	HeroicSavevsMagic = 262,
	HeroicSavevsCorruption = 263,
	CapStrength = 264,
	CapStamina = 265,
	CapDexterity = 266,
	CapAgility = 267,
	CapWisdom = 268,
	CapIntelligence = 269,
	CapCharisma = 270,
	CapSavevsPoison = 271,
	CapSavevsDisease = 272,
	CapSavevsFire = 273,
	CapSavevsCold = 274,
	CapSavevsMagic = 275,
	CapSavevsCorruption = 276,
	CapSpellShield = 277,
	CapCombatEffects = 278,
	CapShielding = 279,
	CapDamageShielding = 280,
	CapDamageOverTimeShielding = 281,
	CapDamageShieldMitigation = 282,
	CapAvoidance = 283,
	CapAccuracy = 284,
	CapStunResist = 285,
	CapStrikeThrough = 286,
	CapSkillDamageBash = 287,
	CapSkillDamageBackstab = 288,
	CapSkillDamageDragonpunch = 289,
	CapSkillDamageEaglestrike = 290,
	CapSkillDamageFlyingkick = 291,
	CapSkillDamageKick = 292,
	CapSkillDamageRoundkick = 293,
	CapSkillDamageTigerclaw = 294,
	CapSkillDamageFrenzy = 295,
	LoyaltyTokenCount = 296,
	TributeTrophyTimer = 297,
	TributeTrophyCost = 298,
	GuildTributeTrophyTimer = 299,
	GuildTributeTrophyCost = 300,
	TargetofPetHP = 301,
	AggroTargetName = 302,
	AggroMostHatedName = 303,
	AggroMostHatedNameNoLock = 304,
	AggroMyHatePercent = 305,
	AggroMyHatePercentNoLock = 306,
	AggroMostHatedHatePercent = 307,
	AggroMostHatedHatePercentNoLock = 308,
	AggroGroup1HatePercent = 309,
	AggroGroup2HatePercent = 310,
	AggroGroup3HatePercent = 311,
	AggroGroup4HatePercent = 312,
	AggroGroup5HatePercent = 313,
	AggroExtendedTarget1HatePercent = 314,
	AggroExtendedTarget2HatePercent = 315,
	AggroExtendedTarget3HatePercent = 316,
	AggroExtendedTarget4HatePercent = 317,
	AggroExtendedTarget5HatePercent = 318,
	AggroExtendedTarget6HatePercent = 319,
	AggroExtendedTarget7HatePercent = 320,
	AggroExtendedTarget8HatePercent = 321,
	AggroExtendedTarget9HatePercent = 322,
	AggroExtendedTarget10HatePercent = 323,
	AggroExtendedTarget11HatePercent = 324,
	AggroExtendedTarget12HatePercent = 325,
	AggroExtendedTarget13HatePercent = 326,
	AggroExtendedTarget14HatePercent = 327,
	AggroExtendedTarget15HatePercent = 328,
	AggroExtendedTarget16HatePercent = 329,
	AggroExtendedTarget17HatePercent = 330,
	AggroExtendedTarget18HatePercent = 331,
	AggroExtendedTarget19HatePercent = 332,
	AggroExtendedTarget20HatePercent = 333,
	NA334 = 334,
	MercenaryAAExperiencePercentLabel = 335,
	MercenaryAAExperiencePointsLabel = 336,
	MercenaryAAExperiencePointsSpentLabel = 337,
	MercenaryHP = 338,
	MercenaryMaxHP = 339,
	MercenaryMana = 340,
	MercenaryMaxMana = 341,
	MercenaryEndurance = 342,
	MercenaryMaxEndurance = 343,
	MercenaryArmorClass = 344,
	MercenaryAttack = 345,
	MercenaryHastePercent = 346,
	MercenaryStrength = 347,
	MercenaryStamina = 348,
	MercenaryIntelligence = 349,
	MercenaryWisdom = 350,
	MercenaryAgility = 351,
	MercenaryDexterity = 352,
	MercenaryCharisma = 353,
	MercenaryCombatHPRegeneration = 354,
	MercenaryCombatManaRegeneration = 355,
	MercenaryCombatEnduranceRegeneration = 356,
	MercenaryHealAmount = 357,
	MercenarySpellDamage = 358,
	NA359 = 359,
	PowerSourcePercentageRemaining = 360,
	NA361 = 361,
	Velocity = 401,
	AccuracyAgain = 402,
	Evasion = 403,
	NA404 = 404,
	Spell13 = 414,
	Spell14 = 415,
	NA416 = 416,
	ExtraBuff0 = 500,
	ExtraBuff1 = 501,
	ExtraBuff2 = 502,
	ExtraBuff3 = 503,
	ExtraBuff4 = 504,
	ExtraBuff5 = 505,
	ExtraBuff6 = 506,
	ExtraBuff7 = 507,
	ExtraBuff8 = 508,
	ExtraBuff9 = 509,
	ExtraBuff10 = 510,
	ExtraBuff11 = 511,
	ExtraBuff12 = 512,
	ExtraBuff13 = 513,
	ExtraBuff14 = 514,
	ExtraBuff15 = 515,
	ExtraBuff16 = 516,
	ExtraBuff17 = 517,
	ExtraBuff18 = 518,
	ExtraBuff19 = 519,
	ExtraBuff20 = 520,
	ExtraBuff21 = 521,
	ExtraBuff22 = 522,
	ExtraBuff23 = 523,
	ExtraBuff24 = 524,
	ExtraBuff25 = 525,
	ExtraBuff26 = 526,
	ExtraBuff27 = 527,
	ExtraBuff28 = 528,
	ExtraBuff29 = 529,
	ExtraBuff30 = 530,
	ExtraBuff31 = 531,
	ExtraBuff32 = 532,
	ExtraBuff33 = 533,
	ExtraBuff34 = 534,
	ExtraBuff35 = 535,
	ExtraBuff36 = 536,
	ExtraBuff37 = 537,
	ExtraBuff38 = 538,
	ExtraBuff39 = 539,
	ExtraBuff40 = 540,
	ExtraBuff41 = 541,
	SavevsCorruption = 542,
	NA549 = 549,
	BlockedBuff0 = 550,
	BlockedBuff1 = 551,
	BlockedBuff2 = 552,
	BlockedBuff3 = 553,
	BlockedBuff4 = 554,
	BlockedBuff5 = 555,
	BlockedBuff6 = 556,
	BlockedBuff7 = 557,
	BlockedBuff8 = 558,
	BlockedBuff9 = 559,
	BlockedBuff10 = 560,
	BlockedBuff11 = 561,
	BlockedBuff12 = 562,
	BlockedBuff13 = 563,
	BlockedBuff14 = 564,
	BlockedBuff15 = 565,
	BlockedBuff16 = 566,
	BlockedBuff17 = 567,
	BlockedBuff18 = 568,
	BlockedBuff19 = 569,
	BlockedBuff20 = 570,
	BlockedBuff21 = 571,
	BlockedBuff22 = 572,
	BlockedBuff23 = 573,
	BlockedBuff24 = 574,
	BlockedBuff25 = 575,
	BlockedBuff26 = 576,
	BlockedBuff27 = 577,
	BlockedBuff28 = 578,
	BlockedBuff29 = 579,
	NA580 = 580,
	SongBuff0 = 600,
	SongBuff1 = 601,
	SongBuff2 = 602,
	SongBuff3 = 603,
	SongBuff4 = 604,
	SongBuff5 = 605,
	SongBuff6 = 606,
	SongBuff7 = 607,
	SongBuff8 = 608,
	SongBuff9 = 609,
	SongBuff10 = 610,
	SongBuff11 = 611,
	SongBuff12 = 612,
	SongBuff13 = 613,
	SongBuff14 = 614,
	SongBuff15 = 615,
	SongBuff16 = 616,
	SongBuff17 = 617,
	SongBuff18 = 618,
	SongBuff19 = 619,
	SongBuff20 = 620,
	SongBuff21 = 621,
	SongBuff22 = 622,
	SongBuff23 = 623,
	SongBuff24 = 624,
	SongBuff25 = 625,
	SongBuff26 = 626,
	SongBuff27 = 627,
	SongBuff28 = 628,
	SongBuff29 = 629,
	NA630 = 630,
	PetBlockedBuff0 = 650,
	PetBlockedBuff1 = 651,
	PetBlockedBuff2 = 652,
	PetBlockedBuff3 = 653,
	PetBlockedBuff4 = 654,
	PetBlockedBuff5 = 655,
	PetBlockedBuff6 = 656,
	PetBlockedBuff7 = 657,
	PetBlockedBuff8 = 658,
	PetBlockedBuff9 = 659,
	PetBlockedBuff10 = 660,
	PetBlockedBuff11 = 661,
	PetBlockedBuff12 = 662,
	PetBlockedBuff13 = 663,
	PetBlockedBuff14 = 664,
	PetBlockedBuff15 = 665,
	PetBlockedBuff16 = 666,
	PetBlockedBuff17 = 667,
	PetBlockedBuff18 = 668,
	PetBlockedBuff19 = 669,
	PetBlockedBuff20 = 670,
	PetBlockedBuff21 = 671,
	PetBlockedBuff22 = 672,
	PetBlockedBuff23 = 673,
	PetBlockedBuff24 = 674,
	PetBlockedBuff25 = 675,
	PetBlockedBuff26 = 676,
	PetBlockedBuff27 = 677,
	PetBlockedBuff28 = 678,
	PetBlockedBuff29 = 679,
	MeleePower = 1002,
	SpellPower = 1003,
	HealingPower = 1004,
	SpellHaste = 1009,
	MeleeHaste = 1010,
	HealingHaste = 1011,
	SpellCrit = 1012,
	MeleeCrit = 1013,
	HealingCrit = 1014,
	Walkspeed = 1015,
	Runspeed = 1016,
	ClassesBitmask = 1017,
	Mitigation = 1018,
	AAPoints = 1019,
	EQLabelTypesMax,
	};

	typedef string(*pEqTypesFunc)(EQLabelTypes LabelID);

	std::map<EQLabelTypes, pEqTypesFunc> eqTypesMap;
	std::map<EQLabelTypes, eStatEntry> statLabelMappings;
	std::map<eStatEntry, int64_t> statEntries;


	std::string GetStringRepresentationOfStat(eStatEntry statType)
	{
		auto statItr = statEntries.find(statType);
		if (statItr != statEntries.end())
		{
			std::stringstream strStream;
			strStream << statItr->second;
			return strStream.str();
		}

		return " ";
	}

	// NMS: Safely returns the client-side base class name for a RoF2 class ID, rejecting invalid values.
	static const char* GetClientClassName(int class_id)
	{
		// RoF2 valid class range: 1�16
		if (class_id < 1 || class_id > 16)
			return "Unknown";

		return (const char*)GetClassDesc(class_id);
	}


	// NMS: Builds a multiline, class title list from the multiclass bitmask using player level.
	std::string GetStringRepresentationOfClass()
	{
		auto itr = statEntries.find(eStatClassesBitmask);
		if (itr == statEntries.end())
			return "None";

		uint32_t mask = static_cast<uint32_t>(itr->second);
		if (!mask)
			return "None";

		if (!pLocalPlayer || !pLocalPlayer->Data.pSpawn)
			return "None";

		uint8_t level = pLocalPlayer->Data.pSpawn->Level;
		std::string result;

		for (int class_id = 1; class_id <= 16; ++class_id)
		{
			uint32_t bit = (1u << (class_id - 1));
			if (mask & bit)
			{
				if (!result.empty())
					result += "\n";

				// ONLY the title here
				result += GetClassTitle(class_id, level);
			}
		}

		return result.empty() ? "None" : result;
	}

// NMS: Routes an EQ label type to its mapped stat formatter, returning the formatted stat string for UI display.
std::string EQLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return string(" ");

	auto iter = statLabelMappings.find(EQLabelTypes(LabelID));
	if (iter == statLabelMappings.end())
		return string(" ");

	return GetStringRepresentationOfStat(iter->second);
}

static std::string GetClassAbbreviationString()
{
	auto itr = statEntries.find(eStatClassesBitmask);
	if (itr == statEntries.end())
		return "";

	uint32_t mask = static_cast<uint32_t>(itr->second);
	if (!mask)
		return "";

	std::string result;

	for (int class_id = 1; class_id <= 16; ++class_id)
	{
		uint32_t bit = (1u << (class_id - 1));
		if (mask & bit)
		{
			if (!result.empty())
				result += "\n";

			result += ClassAbbr[class_id];
		}
	}

	return result;
}

// NMS: Builds a multiline list of 3-letter class abbreviations from the multiclass bitmask for UI display.
std::string EQDualManaLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return " ";

	return GetStringRepresentationOfStat(eStatCurMana) + " / " +
		GetStringRepresentationOfStat(eStatMaxMana);
}



std::string EQDualHPLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return " ";

	return GetStringRepresentationOfStat(eStatCurHP) + " / " +
		GetStringRepresentationOfStat(eStatMaxHP);
}

std::string EQHPPercentageLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return " ";

	auto statItrCur = statEntries.find(eStatCurHP);
	auto statItrMax = statEntries.find(eStatMaxHP);

	if (statItrCur == statEntries.end() || statItrMax == statEntries.end())
		return " ";

	auto statCur = statItrCur->second;
	auto statMax = statItrMax->second;

	if (statMax <= 0 || statCur < 0)
		return " ";

	int outVal = static_cast<int>(
		(double)statCur / (double)statMax * 100.0
		);

	std::stringstream strStream;
	strStream << outVal;
	return strStream.str();
}



std::string EQManaPercentageLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return " ";

	auto statItrCur = statEntries.find(eStatCurMana);
	auto statItrMax = statEntries.find(eStatMaxMana);

	if (statItrCur == statEntries.end() || statItrMax == statEntries.end())
		return " ";

	auto statCur = statItrCur->second;
	auto statMax = statItrMax->second;

	if (statMax <= 0 || statCur < 0)
		return " ";

	int outVal = static_cast<int>(
		(double)statCur / (double)statMax * 100.0
		);

	std::stringstream strStream;
	strStream << outVal;
	return strStream.str();
}


std::string EQEndurPercentageLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return " ";

	auto statItrCur = statEntries.find(eStatCurEndur);
	auto statItrMax = statEntries.find(eStatMaxEndur);

	if (statItrCur == statEntries.end() || statItrMax == statEntries.end())
		return " ";

	auto statCur = statItrCur->second;
	auto statMax = statItrMax->second;

	if (statMax <= 0 || statCur < 0)
		return " ";

	int outVal = static_cast<int>(
		(double)statCur / (double)statMax * 100.0
		);

	std::stringstream strStream;
	strStream << outVal;
	return strStream.str();
}


std::string EQGaugeLabelFunction(eStatEntry curStat, eStatEntry maxStat, int* outVal)
{
	if (!outVal)
		return " ";

	auto statItrCur = statEntries.find(curStat);
	auto statItrMax = statEntries.find(maxStat);

	if (statItrCur == statEntries.end() || statItrMax == statEntries.end())
	{
		*outVal = 0;
		return " ";
	}

	auto statCur = statItrCur->second;
	auto statMax = statItrMax->second;

	if (statMax <= 0 || statCur < 0)
	{
		*outVal = 0;
		return " ";
	}

	*outVal = static_cast<int>(
		(double)statCur / (double)statMax * 1000.0
		);

	std::stringstream strStream;
	strStream << *outVal;
	return strStream.str();
}


std::string EQDualEndurLabelFunction(EQLabelTypes LabelID)
{
	if (LabelID >= EQLabelTypesMax)
		return string(" ");

	return GetStringRepresentationOfStat(eStatCurEndur) + " / " + GetStringRepresentationOfStat(eStatMaxEndur);
}


typedef struct ServerAuthStatEntry_Struct {
	uint32_t statKey;
	uint64_t statValue;
} ServerAuthStatEntry_Struct;

typedef struct ServerAuthStat_Struct
{
	uint32_t count;
	ServerAuthStatEntry_Struct entries[0];
};

PLUGIN_API BOOL OnLabelReceivePPPacket()
{
	statEntries.clear();
	return true;
}

PLUGIN_API BOOL OnRecvServerAuthStatLabelPacket(DWORD Type, PVOID Packet, DWORD Size)
{
	if ((Size <= 4) || !Packet)
		return true;

	ServerAuthStat_Struct* incValues = (ServerAuthStat_Struct*)Packet;
	if (incValues->count * sizeof(ServerAuthStatEntry_Struct) != (Size - 4))
		return true;

	for (uint32_t i = 0; i < incValues->count; ++i)
	{
		uint32_t key = incValues->entries[i].statKey;
		uint64_t val = incValues->entries[i].statValue;

		// Existing storage logic
		if (key == 0 || key >= eStatMax)
			continue;

		statEntries[(eStatEntry)key] = val;
	}

	if (pLocalPlayer)
	{
		auto itrCurHP = statEntries.find(eStatCurHP);
		auto itrMaxHP = statEntries.find(eStatMaxHP);
		auto itrCurMana = statEntries.find(eStatCurMana);
		auto itrMaxMana = statEntries.find(eStatMaxMana);
		auto itrCurEndur = statEntries.find(eStatCurEndur);
		auto itrMaxEndur = statEntries.find(eStatMaxEndur);

		// Synchronize raw values in pLocalPlayer->Data
		if (itrCurHP != statEntries.end()) pLocalPlayer->Data.HPCurrent = static_cast<LONG>(itrCurHP->second);
		if (itrMaxHP != statEntries.end()) pLocalPlayer->Data.HPMax = static_cast<DWORD>(itrMaxHP->second);
		if (itrCurMana != statEntries.end()) pLocalPlayer->Data.ManaCurrent = static_cast<DWORD>(itrCurMana->second);
		if (itrMaxMana != statEntries.end()) pLocalPlayer->Data.ManaMax = static_cast<DWORD>(itrMaxMana->second);
		if (itrCurEndur != statEntries.end()) pLocalPlayer->Data.EnduranceCurrent = static_cast<DWORD>(itrCurEndur->second);
		if (itrMaxEndur != statEntries.end()) pLocalPlayer->Data.EnduranceMax = static_cast<DWORD>(itrMaxEndur->second);

		// Synchronize raw values in pLocalPlayer->Data.pSpawn if present
		if (pLocalPlayer->Data.pSpawn)
		{
			if (itrCurHP != statEntries.end()) pLocalPlayer->Data.pSpawn->HPCurrent = static_cast<LONG>(itrCurHP->second);
			if (itrMaxHP != statEntries.end()) pLocalPlayer->Data.pSpawn->HPMax = static_cast<DWORD>(itrMaxHP->second);
			if (itrCurMana != statEntries.end()) pLocalPlayer->Data.pSpawn->ManaCurrent = static_cast<DWORD>(itrCurMana->second);
			if (itrMaxMana != statEntries.end()) pLocalPlayer->Data.pSpawn->ManaMax = static_cast<DWORD>(itrMaxMana->second);
			if (itrCurEndur != statEntries.end()) pLocalPlayer->Data.pSpawn->EnduranceCurrent = static_cast<DWORD>(itrCurEndur->second);
			if (itrMaxEndur != statEntries.end()) pLocalPlayer->Data.pSpawn->EnduranceMax = static_cast<DWORD>(itrMaxEndur->second);
		}
	}

	return true;
}


// CSidlManager::CreateLabel 0x5F2470
// the tool tip is already copied out of the 
// in class CControlTemplate.  use this struct
// to mock up the class, so we don't have to
// worry about class instatiation and crap

struct _CControl {
    /*0x000*/    DWORD Fluff[0x24]; // if this changes update ISXEQLabels.cpp too
    /*0x090*/    CXSTR * EQType;
};


// optimize off because the tramp looks blank to the compiler
// and it doesn't respect the fact the it will be a real routine
#pragma optimize ("g", off)


class CSidlManagerHook {
public:
    class CXWnd * CreateLabel_Trampoline(class CXWnd *, struct _CControl *);
    class CXWnd * CreateLabel_Detour(class CXWnd *CWin, struct _CControl *CControl)
    {
        CLABELWND *p;
        class CXWnd *tmp = CreateLabel_Trampoline(CWin, CControl);
        p = (CLABELWND *)tmp;
        if (CControl->EQType) {
            *((DWORD *)&p->SidlPiece) = atoi(CControl->EQType->Text);
        } else {
            *((DWORD *)&p->SidlPiece) = 0;
        }

        return tmp;
    }
};


DETOUR_TRAMPOLINE_EMPTY(
	class CXWnd* CSidlManagerHook::CreateLabel_Trampoline(
		class CXWnd*, struct _CControl*
	)
);

int __cdecl GetGaugeValueFromEQ_Trampoline(
	int, class CXStr*, bool*, unsigned long*
);

int __cdecl GetGaugeValueFromEQ_Detour(
	int EQType,
	class CXStr* out,
	bool* arg3,
	unsigned long* colorout)
{
	int ret = GetGaugeValueFromEQ_Trampoline(EQType, out, arg3, colorout);

	// We ONLY override the gauge fill value here.
	// Label text is handled elsewhere via label hooks.
	switch (EQType)
	{
	case 1: // HP
		EQGaugeLabelFunction(eStatCurHP, eStatMaxHP, &ret);
		break;

	case 2: // Mana
		EQGaugeLabelFunction(eStatCurMana, eStatMaxMana, &ret);
		break;

	case 3: // Endurance
		EQGaugeLabelFunction(eStatCurEndur, eStatMaxEndur, &ret);
		break;

	case 6: // Target HP (self only)
		if (pTarget && pLocalPlayer && (((PSPAWNINFO)pTarget)->SpawnID == ((PSPAWNINFO)pLocalPlayer)->SpawnID))
		{
			EQGaugeLabelFunction(eStatCurHP, eStatMaxHP, &ret);
		}
		break;

	case 26: { // Active combat discipline duration gauge
		if (pLocalPlayer && GetCharInfo2())
		{
			PCHARINFO2 pCI2 = GetCharInfo2();
			PSPELL pActiveDisc = nullptr;
			DWORD remainingTicks = 0;

			// >= 20: only banded true discs qualify -- stock spell linked-recast timers (1..19)
			// must not drive the disc duration gauge (see note in MQ2Pulse.cpp).

			// Scan regular buffs
			for (int i = 0; i < NUM_LONG_BUFFS; i++) {
				LONG spellID = pCI2->Buff[i].SpellID;
				if (spellID > 0) {
					PSPELL pSpell = GetSpellByID(spellID);
					if (pSpell && pSpell->CARecastTimerID >= 20 && pSpell->CARecastTimerID != 0xFFFFFFFF) {
						pActiveDisc = pSpell;
						remainingTicks = pCI2->Buff[i].Duration;
						break;
					}
				}
			}

			// Scan short buffs
			if (!pActiveDisc) {
				for (int i = 0; i < 0x37; i++) {
					LONG spellID = pCI2->ShortBuff[i].SpellID;
					if (spellID > 0) {
						PSPELL pSpell = GetSpellByID(spellID);
						if (pSpell && pSpell->CARecastTimerID >= 20 && pSpell->CARecastTimerID != 0xFFFFFFFF) {
							pActiveDisc = pSpell;
							remainingTicks = pCI2->ShortBuff[i].Duration;
							break;
						}
					}
				}
			}

			static DWORD s_lastActiveDiscID = 0;
			static DWORD s_castTime = 0;
			static DWORD s_totalDurationMs = 0;
			static DWORD s_maxTicks = 0;
			static DWORD s_lastRemainingTicks = 0;

			if (pActiveDisc) {
				int fill = 0;
				int upkeep = *(int*)&pActiveDisc->Unknown0x19c[0];
				DWORD elapsed = 0;

				if (upkeep > 0) {
					// It's a toggled/upkeep discipline! Leave the bar full.
					fill = 1000;
				} else {
					// Smooth countdown real-time calculation
					if (s_lastActiveDiscID != pActiveDisc->ID || remainingTicks > s_lastRemainingTicks) {
						s_lastActiveDiscID = pActiveDisc->ID;
						s_castTime = GetTickCount();
						s_maxTicks = remainingTicks;
						s_totalDurationMs = remainingTicks * 6000;
					}
					s_lastRemainingTicks = remainingTicks;

					elapsed = GetTickCount() - s_castTime;
					if (elapsed < s_totalDurationMs && s_totalDurationMs > 0) {
						fill = ((s_totalDurationMs - elapsed) * 1000) / s_totalDurationMs;
						if (fill > 1000) fill = 1000;
						if (fill < 0) fill = 0;
					} else {
						fill = 0;
					}
				}

				static DWORD lastPrint = 0;
				DWORD now = GetTickCount();
				if (now - lastPrint > 1000) {
					lastPrint = now;
					char dbg[256];
					sprintf_s(dbg, "[NMS-Client] GetGauge(26): ID=%d, upkeep=%d, remainingTicks=%d, maxTicks=%d, elapsed=%d, totalMs=%d, fill=%d\n", 
						pActiveDisc->ID, upkeep, remainingTicks, s_maxTicks, elapsed, s_totalDurationMs, fill);
					OutputDebugStringA(dbg);
				}

				return fill;
			} else {
				s_lastActiveDiscID = 0;
				s_castTime = 0;
				s_totalDurationMs = 0;
				s_maxTicks = 0;
				s_lastRemainingTicks = 0;
			}
		}
		return 0;
	}

	default:
		break;
	}

	return ret;
}


int __cdecl GetLabelFromEQ_Trampoline(int, class CXStr*, bool*, unsigned long*);
int __cdecl GetLabelFromEQ_Detour(int EQType, class CXStr* out, bool* arg3, unsigned long* colorout)
{

	int ret = GetLabelFromEQ_Trampoline(EQType, out, arg3, colorout);

	if (!out || !out->Ptr)
		return ret;

	
	if (EQType == EQLabelTypes::HitPointPercentage)
	{
		if (pTarget && pLocalPlayer && (((PSPAWNINFO)pTarget)->SpawnID == ((PSPAWNINFO)pLocalPlayer)->SpawnID))
		{
			std::string text = EQHPPercentageLabelFunction((EQLabelTypes)EQType);
			SetCXStr(&out->Ptr, (PCHAR)text.c_str());
		}
		return ret;
	}

	
	auto it = eqTypesMap.find((EQLabelTypes)EQType);
	if (it == eqTypesMap.end() || !it->second)
		return ret;


	char buffer[MAX_STRING] = { 0 };
	GetCXStr(out->Ptr, buffer, MAX_STRING);
	std::string clientText(buffer);


	switch (EQType)
	{
	case EQLabelTypes::Strength:
	case EQLabelTypes::Stamina:
	case EQLabelTypes::Agility:
	case EQLabelTypes::Dexterity:
	case EQLabelTypes::Wisdom:
	case EQLabelTypes::Intelligence:
	case EQLabelTypes::Charisma:
	{
		size_t slash = clientText.find('/');
		if (slash == std::string::npos)
			return ret;

		auto mapIt = statLabelMappings.find((EQLabelTypes)EQType);
		if (mapIt == statLabelMappings.end())
			return ret;

		auto statIt = statEntries.find(mapIt->second);
		if (statIt == statEntries.end())
			return ret;

		std::string finalText =
			std::to_string((int)statIt->second) +
			clientText.substr(slash);

		SetCXStr(&out->Ptr, (PCHAR)finalText.c_str());
		return ret;
	}

	default:
		break;
	}

	std::string serverText = it->second((EQLabelTypes)EQType);
	if (!serverText.empty())
		SetCXStr(&out->Ptr, (PCHAR)serverText.c_str());

	return ret;
}


// CLabelHook::Draw_Detour

class CLabelHook {
public:
	VOID Draw_Trampoline(VOID);
	VOID Draw_Detour(VOID)
	{
		PCLABELWND pThisLabel;
		__asm { mov[pThisLabel], ecx };

		// NMS: Detects item tier suffixes in label text and overrides the CXWnd text color (UnknownCW) with custom ARGB values for Enchanted (Vibrant Blue) and Legendary (Orange-Gold) items.
		if (pThisLabel && pThisLabel->Wnd.WindowText)
		{
			char szBuffer[MAX_STRING] = { 0 };
			GetCXStr(pThisLabel->Wnd.WindowText, szBuffer, MAX_STRING);
			if (strstr(szBuffer, "(Enchanted)"))
			{
				pThisLabel->Wnd.UnknownCW = 0xFF4E78FF; // Vibrant Blue
			}
			else if (strstr(szBuffer, "(Legendary)"))
			{
				pThisLabel->Wnd.UnknownCW = 0xFFFFA500; // Orange-Gold
			}
		}

		Draw_Trampoline();

		if (!pThisLabel)
			return;

		auto iter = eqTypesMap.find((EQLabelTypes)pThisLabel->SidlPiece);
		if (iter == eqTypesMap.end())
			return;

		auto func = iter->second;
		if (!func)
			return;

		std::string eqtypesString = (*func)(iter->first);
		if (!eqtypesString.empty())
		{
			SetCXStr(&pThisLabel->Wnd.WindowText, (PCHAR)eqtypesString.c_str());
		}
	}
};


class EQCharacter1Hook {
public:
	int32_t MaxHP_Trampoline(int, int);
	int32_t MaxHP_Detour(int a1, int a2)
	{
		auto itr = statEntries.find(eStatMaxHP);
		if (itr != statEntries.end())
		{
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return MaxHP_Trampoline(a1, a2);
	}

	int32_t MaxMana_Trampoline(int);
	int32_t MaxMana_Detour(int a1)
	{
		auto itr = statEntries.find(eStatMaxMana);
		if (itr != statEntries.end())
		{
			// For display purposes we really, really should not care what the value is.
			// Only that it's the 'right' value for unconscious purposes.
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return MaxMana_Trampoline(a1);
	}

	int32_t MaxEndurance_Trampoline(int);
	int32_t MaxEndurance_Detour(int a1)
	{
		auto itr = statEntries.find(eStatMaxEndur);
		if (itr != statEntries.end())
		{
			// For display purposes we really, really should not care what the value is.
			// Only that it's the 'right' value for unconscious purposes.
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return MaxEndurance_Trampoline(a1);
	}

	int32_t CurHP_Trampoline(int, unsigned char);
	int32_t CurHP_Detour(int a1, unsigned char a2)
	{
		auto itr = statEntries.find(eStatCurHP);
		if (itr != statEntries.end())
		{
			// For display purposes we really, really should not care what the value is.
			// Only that it's the 'right' value for unconscious purposes.
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return CurHP_Trampoline(a1, a2);
	}

	int32_t CurMana_Trampoline(int);
	int32_t CurMana_Detour(int a1)
	{
		auto itr = statEntries.find(eStatCurMana);
		if (itr != statEntries.end())
		{
			// For display purposes we really, really should not care what the value is.
			// Only that it's the 'right' value for unconscious purposes.
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return CurMana_Trampoline(a1);
	}
	int32_t CurEndurance_Trampoline(int);
	int32_t CurEndurance_Detour(int a1)
	{
		auto itr = statEntries.find(eStatCurEndur);
		if (itr != statEntries.end())
		{
			// For display purposes we really, really should not care what the value is.
			// Only that it's the 'right' value for unconscious purposes.
			return itr->second >= (INT_MAX - 1)
				? INT_MAX - 1
				: static_cast<int32_t>(itr->second);
		}

		return CurEndurance_Trampoline(a1);
	}

	int IsSpellcaster_Trampoline(void);
	int IsSpellcaster_Detour(void)
	{
		PCHARINFO pChar = GetCharInfo();
		if (pChar && (void*)this == (void*)&pChar->vtable2)
		{
			extern uint32_t g_cauth_bitmask;
			if (g_cauth_bitmask != 0)
			{
				if (g_cauth_bitmask & 0x7EBEu)
				{
					return 1;
				}
				return 0;
			}
		}
		return IsSpellcaster_Trampoline();
	}

	int IsSpellcaster_2_Trampoline(int a1, int a2, int a3, int a4);
	int IsSpellcaster_2_Detour(int a1, int a2, int a3, int a4)
	{
		PCHARINFO pChar = GetCharInfo();
		if (pChar && (void*)this == (void*)&pChar->vtable2)
		{
			extern uint32_t g_cauth_bitmask;
			if (g_cauth_bitmask != 0)
			{
				if (g_cauth_bitmask & 0x7EBEu)
				{
					return 1;
				}
				return 0;
			}
		}
		return IsSpellcaster_2_Trampoline(a1, a2, a3, a4);
	}

	int IsSpellcaster_3_Trampoline(void);
	int IsSpellcaster_3_Detour(void)
	{
		if (pLocalPlayer && (void*)this == (void*)pLocalPlayer)
		{
			extern uint32_t g_cauth_bitmask;
			if (g_cauth_bitmask != 0)
			{
				if (g_cauth_bitmask & 0x7EBEu)
				{
					return 1;
				}
				return 0;
			}
		}
		return IsSpellcaster_3_Trampoline();
	}

};

DETOUR_TRAMPOLINE_EMPTY(VOID CLabelHook::Draw_Trampoline(VOID));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::CurHP_Trampoline(int, unsigned char));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::CurMana_Trampoline(int));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::CurEndurance_Trampoline(int));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::MaxHP_Trampoline(int, int));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::MaxMana_Trampoline(int));
DETOUR_TRAMPOLINE_EMPTY(int32_t EQCharacter1Hook::MaxEndurance_Trampoline(int));
DETOUR_TRAMPOLINE_EMPTY(int EQCharacter1Hook::IsSpellcaster_Trampoline(void));
DETOUR_TRAMPOLINE_EMPTY(int EQCharacter1Hook::IsSpellcaster_2_Trampoline(int, int, int, int));
DETOUR_TRAMPOLINE_EMPTY(int EQCharacter1Hook::IsSpellcaster_3_Trampoline(void));

DETOUR_TRAMPOLINE_EMPTY(int __cdecl GetGaugeValueFromEQ_Trampoline(int, class CXStr *, bool *, unsigned long *));
DETOUR_TRAMPOLINE_EMPTY(int __cdecl GetLabelFromEQ_Trampoline(int, class CXStr *, bool *, unsigned long *));
BOOL StealNextGauge=FALSE;
DWORD NextGauge=0;

// Called once, when the plugin is to initialize
PLUGIN_API VOID InitializeMQ2Labels(VOID)
{
 //   DebugSpewAlways("Initializing MQ2Labels");
	eqTypesMap[EQLabelTypes::CurrentHitPoints] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::ManaNumber] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::EnduranceNumber] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::MaximumHitPoints] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::ManaNumberMax] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::EnduranceNumberMax] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::PlayersCurrentHP] = EQDualHPLabelFunction;
	eqTypesMap[EQLabelTypes::ManaMaxMana] = EQDualManaLabelFunction;
	eqTypesMap[EQLabelTypes::EnduranceMaxEndurance] = EQDualEndurLabelFunction;
	eqTypesMap[EQLabelTypes::Strength] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Stamina] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Dexterity] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Agility] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Wisdom] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Intelligence] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Charisma] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::HitPointPercentage] = EQHPPercentageLabelFunction;
	eqTypesMap[EQLabelTypes::ManaPercentage] = EQManaPercentageLabelFunction;
	eqTypesMap[EQLabelTypes::StaminaEndurancePercentage] = EQEndurPercentageLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsMagic] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsCold] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsFire] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsPoison] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsDisease] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::SavevsCorruption] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Class] = [](EQLabelTypes)
		{
			return GetStringRepresentationOfClass();
		};
	eqTypesMap[(EQLabelTypes)6666] = [](EQLabelTypes)
		{
			return GetClassAbbreviationString();
		};

	eqTypesMap[EQLabelTypes::AAPoints] = EQLabelFunction;
	
	// MIT (EQType 6668 from XML) -> route to the MIT label
	eqTypesMap[(EQLabelTypes)6668] = [](EQLabelTypes)
		{
			return EQLabelFunction(EQLabelTypes::Mitigation);
		};

// AVD (EQType 6667 from XML) -> route to Avoidance label
	eqTypesMap[(EQLabelTypes)6667] = [](EQLabelTypes)
		{
			return EQLabelFunction(EQLabelTypes::Avoidance);
		};
	eqTypesMap[EQLabelTypes::CurrentOffense] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::CurrentMitigation] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Mitigation] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Avoidance] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::HitPointRegeneration] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::ManaRegeneration] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::EnduranceRegeneration] = EQLabelFunction;
	eqTypesMap[EQLabelTypes::Clairvoyance] = EQLabelFunction;

	statLabelMappings[EQLabelTypes::CurrentHitPoints] = eStatEntry::eStatCurHP;
	statLabelMappings[EQLabelTypes::ManaNumber] = eStatEntry::eStatCurMana;
	statLabelMappings[EQLabelTypes::EnduranceNumber] = eStatEntry::eStatCurEndur;
	statLabelMappings[EQLabelTypes::MaximumHitPoints] = eStatEntry::eStatMaxHP;
	statLabelMappings[EQLabelTypes::ManaNumberMax] = eStatEntry::eStatMaxMana;
	statLabelMappings[EQLabelTypes::EnduranceNumberMax] = eStatEntry::eStatMaxEndur;
	statLabelMappings[EQLabelTypes::Strength] = eStatEntry::eStatSTR;
	statLabelMappings[EQLabelTypes::Stamina] = eStatEntry::eStatSTA;
	statLabelMappings[EQLabelTypes::Dexterity] = eStatEntry::eStatDEX;
	statLabelMappings[EQLabelTypes::Agility] = eStatEntry::eStatAGI;
	statLabelMappings[EQLabelTypes::Wisdom] = eStatEntry::eStatWIS;
	statLabelMappings[EQLabelTypes::Intelligence] = eStatEntry::eStatINT;
	statLabelMappings[EQLabelTypes::Charisma] = eStatEntry::eStatCHA;
	statLabelMappings[EQLabelTypes::SpellHaste] = eStatEntry::eStatHaste;
	statLabelMappings[EQLabelTypes::MeleeHaste] = eStatEntry::eStatHaste;
	statLabelMappings[EQLabelTypes::HealingHaste] = eStatEntry::eStatHaste;
	statLabelMappings[EQLabelTypes::SpellCrit] = eStatEntry::eStatSpellCritRate;
	statLabelMappings[EQLabelTypes::MeleeCrit] = eStatEntry::eStatMeleeCritRate;
	statLabelMappings[EQLabelTypes::HealingCrit] = eStatEntry::eStatHealCritRate;
	statLabelMappings[EQLabelTypes::SpellPower] = eStatEntry::eStatSpellDmg;
	statLabelMappings[EQLabelTypes::MeleePower] = eStatEntry::eStatWornATK;
	statLabelMappings[EQLabelTypes::HealingPower] = eStatEntry::eStatHealAmt;
	statLabelMappings[EQLabelTypes::SavevsMagic] = eStatEntry::eStatMR;
	statLabelMappings[EQLabelTypes::SavevsCold] = eStatEntry::eStatCR;
	statLabelMappings[EQLabelTypes::SavevsFire] = eStatEntry::eStatFR;
	statLabelMappings[EQLabelTypes::SavevsPoison] = eStatEntry::eStatPR;
	statLabelMappings[EQLabelTypes::SavevsDisease] = eStatEntry::eStatDR;
	statLabelMappings[EQLabelTypes::CurrentOffense] = eStatEntry::eStatATK;
	statLabelMappings[EQLabelTypes::CurrentMitigation] = eStatEntry::eStatAC;
	statLabelMappings[EQLabelTypes::Mitigation] = eStatEntry::eStatMitigation;
	statLabelMappings[EQLabelTypes::Avoidance] = eStatEntry::eStatAvoidance;
	statLabelMappings[EQLabelTypes::ClassesBitmask] = eStatEntry::eStatClassesBitmask;
	statLabelMappings[EQLabelTypes::HitPointRegeneration] = eStatEntry::eStatHPRegen;
	statLabelMappings[EQLabelTypes::ManaRegeneration] = eStatEntry::eStatManaRegen;
	statLabelMappings[EQLabelTypes::EnduranceRegeneration] = eStatEntry::eStatEndurRegen;
	statLabelMappings[EQLabelTypes::Clairvoyance] = eStatEntry::eStatClairvoyance;

	// Custom XML 6xxx Advanced Character Stats (no suffix - the XML already has % and /)
	statLabelMappings[(EQLabelTypes)6671] = eStatEntry::eStatSpellCritRate;
	statLabelMappings[(EQLabelTypes)6672] = eStatEntry::eStatSpellCritRatio;
	statLabelMappings[(EQLabelTypes)6673] = eStatEntry::eStatHealCritRate;
	statLabelMappings[(EQLabelTypes)6674] = eStatEntry::eStatHoTCritRate;
	statLabelMappings[(EQLabelTypes)6675] = eStatEntry::eStatDoTCritRate;
	statLabelMappings[(EQLabelTypes)6676] = eStatEntry::eStatDoTCritRatio;
	statLabelMappings[(EQLabelTypes)6677] = eStatEntry::eStatMeleeCritRate;
	statLabelMappings[(EQLabelTypes)6678] = eStatEntry::eStatMeleeCritRatio;
	statLabelMappings[(EQLabelTypes)6707] = eStatEntry::eStatArcheryCritRate;

	// Custom XML 6xxx Advanced Stats and Caps
	statLabelMappings[(EQLabelTypes)6669] = eStatEntry::eStatWornATK;
	statLabelMappings[(EQLabelTypes)6703] = eStatEntry::eStatCapClairvoyance;
	statLabelMappings[(EQLabelTypes)6704] = eStatEntry::eStatCapHealAmount;
	statLabelMappings[(EQLabelTypes)6705] = eStatEntry::eStatCapSpellDamage;
	statLabelMappings[(EQLabelTypes)6706] = eStatEntry::eStatCapWornATK;

	// Custom XML 6xxx lambdas to bypass EQLabelTypesMax check
	eqTypesMap[(EQLabelTypes)6671] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatSpellCritRate); };
	eqTypesMap[(EQLabelTypes)6672] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatSpellCritRatio); };
	eqTypesMap[(EQLabelTypes)6673] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatHealCritRate); };
	eqTypesMap[(EQLabelTypes)6674] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatHoTCritRate); };
	eqTypesMap[(EQLabelTypes)6675] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatDoTCritRate); };
	eqTypesMap[(EQLabelTypes)6676] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatDoTCritRatio); };
	eqTypesMap[(EQLabelTypes)6677] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatMeleeCritRate); };
	eqTypesMap[(EQLabelTypes)6678] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatMeleeCritRatio); };
	eqTypesMap[(EQLabelTypes)6707] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatArcheryCritRate); };

	eqTypesMap[(EQLabelTypes)6669] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatWornATK); };
	eqTypesMap[(EQLabelTypes)6703] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatCapClairvoyance); };
	eqTypesMap[(EQLabelTypes)6704] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatCapHealAmount); };
	eqTypesMap[(EQLabelTypes)6705] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatCapSpellDamage); };
	eqTypesMap[(EQLabelTypes)6706] = [](EQLabelTypes) { return GetStringRepresentationOfStat(eStatCapWornATK); };

	// Detour EQType 338 to return the dynamic value of Echo of Memory (Alternate Currency ID 6)
	eqTypesMap[(EQLabelTypes)338] = [](EQLabelTypes) {
		if (GetCharInfo() && pPlayerPointManager) {
			return std::to_string(pPlayerPointManager->GetAltCurrency(6));
		}
		return std::string("0");
	};

	// Automatically register custom mappings (EQType >= 1000) in eqTypesMap so they are detoured correctly
	for (std::map<EQLabelTypes, eStatEntry>::const_iterator it = statLabelMappings.begin(); it != statLabelMappings.end(); ++it)
	{
		if (it->first >= 1000 && eqTypesMap.find(it->first) == eqTypesMap.end())
		{
			eqTypesMap[it->first] = EQLabelFunction;
		}
	}

    // Add commands, macro parameters, hooks, etc.
    EzDetour(CLabel__Draw,&CLabelHook::Draw_Detour,&CLabelHook::Draw_Trampoline);
	EzDetour(EQ_Character__Max_HP, &EQCharacter1Hook::MaxHP_Detour, &EQCharacter1Hook::MaxHP_Trampoline);
	EzDetour(EQ_Character__Cur_HP, &EQCharacter1Hook::CurHP_Detour, &EQCharacter1Hook::CurHP_Trampoline);
	EzDetour(EQ_Character__Cur_Mana, &EQCharacter1Hook::CurMana_Detour, &EQCharacter1Hook::CurMana_Trampoline);
	EzDetour(EQ_Character__Max_Mana, &EQCharacter1Hook::MaxMana_Detour, &EQCharacter1Hook::MaxMana_Trampoline);
	EzDetour(EQ_Character__Cur_Endurance, &EQCharacter1Hook::CurEndurance_Detour, &EQCharacter1Hook::CurEndurance_Trampoline);
	EzDetour(EQ_Character__Max_Endurance, &EQCharacter1Hook::MaxEndurance_Detour, &EQCharacter1Hook::MaxEndurance_Trampoline);
	EzDetour(EQ_Character__IsSpellcaster, &EQCharacter1Hook::IsSpellcaster_Detour, &EQCharacter1Hook::IsSpellcaster_Trampoline);
	EzDetour(EQ_Character__IsSpellcaster_2, &EQCharacter1Hook::IsSpellcaster_2_Detour, &EQCharacter1Hook::IsSpellcaster_2_Trampoline);
	EzDetour(EQ_Character__IsSpellcaster_3, &EQCharacter1Hook::IsSpellcaster_3_Detour, &EQCharacter1Hook::IsSpellcaster_3_Trampoline);

    EzDetour(CSidlManager__CreateLabel,&CSidlManagerHook::CreateLabel_Detour,&CSidlManagerHook::CreateLabel_Trampoline);
    EzDetour(__GetGaugeValueFromEQ,GetGaugeValueFromEQ_Detour, GetGaugeValueFromEQ_Trampoline);
	EzDetour(__GetLabelFromEQ, GetLabelFromEQ_Detour, GetLabelFromEQ_Trampoline);
}

// Called once, when the plugin is to shutdown
PLUGIN_API VOID ShutdownLabelsPlugin(VOID)
{
	eqTypesMap.clear();
	statLabelMappings.clear();

	RemoveDetour(CSidlManager__CreateLabel);
	RemoveDetour(CLabel__Draw);
	RemoveDetour(EQ_Character__Max_HP);
	RemoveDetour(EQ_Character__Cur_HP);
	RemoveDetour(EQ_Character__Cur_Mana);
	RemoveDetour(EQ_Character__Max_Mana);
	RemoveDetour(EQ_Character__Cur_Endurance);
	RemoveDetour(EQ_Character__Max_Endurance);
	RemoveDetour(EQ_Character__IsSpellcaster);
	RemoveDetour(EQ_Character__IsSpellcaster_2);
	RemoveDetour(EQ_Character__IsSpellcaster_3);

	RemoveDetour(__GetGaugeValueFromEQ);
	RemoveDetour(__GetLabelFromEQ);
}


