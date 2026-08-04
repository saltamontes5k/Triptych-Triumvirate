local Util = {};

Util.Classes = {};
Util.Classes.Warrior = 1;
Util.Classes.Cleric = 2;
Util.Classes.Paladin = 3;
Util.Classes.Ranger = 4;
Util.Classes["Shadow Knight"] = 5;
Util.Classes.Shadowknight = 5;
Util.Classes.Druid = 6;
Util.Classes.Monk = 7;
Util.Classes.Bard = 8;
Util.Classes.Rogue = 9;
Util.Classes.Shaman = 10;
Util.Classes.Necromancer = 11;
Util.Classes.Wizard = 12;
Util.Classes.Magician = 13;
Util.Classes.Enchanter = 14;
Util.Classes.Beastlord = 15;
Util.Classes.Berserker = 16;
Util.Classes[1] = "Warrior";
Util.Classes[2] = "Cleric";
Util.Classes[3] = "Paladin";
Util.Classes[4] = "Ranger";
Util.Classes[5] = "Shadow Knight";
Util.Classes[6] = "Druid";
Util.Classes[7] = "Monk";
Util.Classes[8] = "Bard";
Util.Classes[9] = "Rogue";
Util.Classes[10] = "Shaman";
Util.Classes[11] = "Necromancer";
Util.Classes[12] = "Wizard";
Util.Classes[13] = "Magician";
Util.Classes[14] = "Enchanter";
Util.Classes[15] = "Beastlord";
Util.Classes[16] = "Berserker";
Util.Class_count = 16;

function Util:deconstruct_classes(bitmask)
	local classes = {};
	local count = 0;
	for i = 1,Util.Class_count,1 do
		if bitmask % 2 == 1 then
			classes[i] = true;
			classes[Util.Classes[i]] = true;
			count = count + 1;
		else
			classes[i] = false;
			classes[Util.Classes[i]] = false;
		end
		bitmask = math.floor(bitmask / 2);
	end
	classes.count = count;

	return classes;
end

function Util:has_class(client, classid)
	local class_bits = client:GetClassBitmask();
	local classes = Util:deconstruct_classes(class_bits);

	return classes[classid];
end

function Util:deconstruct_slots(bitmask)
	local slots = {};
	for i=Slot.Charm,Slot.Ammo,1 do
		if bitmask % 2 == 1 then
			slots[i] = true;
		else
			slots[i] = false;
		end
		bitmask = math.floor(bitmask / 2);
	end

	return slots;
end

return Util;
