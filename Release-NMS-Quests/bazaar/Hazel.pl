############################################
# ZONE: Bazaar
# VERSION: 1.0
# TYPE: Custom (NMS)
#
# *** NPC INFORMATION ***
#
# NAME: Hazel
# RACE: Wood Elf
# LEVEL: 65
#
# *** PURPOSE ***
#
# Buff bot - hail to receive a level-appropriate
# full buff bar (<10, 10-24, 25-45, 46+).
#
############################################

sub EVENT_SAY {
	if($text=~/hail/i) {	
		if($ulevel < 10) {
			@buffs = (
			89, 	#Daring - Level 17 Cleric HP/AC Buff
			485,	#Symbol of Transal - Level 11 Cleric HP Buff
			368,	#Spirit Armor - Level 15 Cleric AC Buff 
			278,	#Spirit of Wolf
			254,	#Firefist - Level 17 Ranger Atk Buff
			332, 	#Shield of Fire - Level 7 Mage DS Buff
			2521,	#Talisman of the Beast - SHM STR Buff
			269, 	#Feet Like Cat - SHM AGI Buff
			279, 	#Spirit of Bear - SHM STAM Buff
			10,
			11274);	#Augmentation - Level 28 ENC Haste BUFF
		}
		elsif($ulevel >= 10 && $ulevel < 25) {
			@buffs = (
			312,	#Valor - Level 33 Cleric HP/AC Buff
			487,	#Symbol of Pinzarn - Cleric HP Buff
			167,	#Talisman of Tnarg
			19,		#Armor of Faith - Cleric AC Buff
			278,	#Spirit of Wolf
			254,	#Firefist
			332,	#Shield of Fire
			149,	#Spirit of Ox
			146,	#Spirit of Monkey
			144,	#Regeneration
			10,
			11274);	#Augmentation - Level 28 ENC Haste Buff
		}
		elsif($ulevel >= 25 && $ulevel < 46) {
			@buffs = (
			4053,	#blessing of temperance
			168,	#Talisman of Tnarg
			2524,	#Spirit of Bih`li
			254,	#Firefist
			412,	#Shield of Fire
			149,	#Spirit of Ox
			146,	#Spirit of Monkey
			138,	#Regeneration
			1693, 	#clarity
			10,
			172);	#Augmentation - Level 28 ENC Haste Buff
		}
		elsif($ulevel >= 46) {
			@buffs = (
			2122,	#Ancient: Gift of Aegolism
		#	4108,	#Aura of Reverence - Clr spell haste
			2530,	#Khura's Focusing
			2524,	#Spirit of Bih`li
			3441,	#Blessing of Replenishment
			3486,	#Shield of Fire
			2570,	#KEI
			11274,
			2895);	#Speed of the Brood - haste
		}
		plugin::DiaWind("Good luck with your adventures, {gold}$name~. =2=");
		foreach my $spell (@buffs) {
			quest::selfcast($spell);
		}		
	}
}
# END of FILE Zone:bazaar -- Hazel.pl
