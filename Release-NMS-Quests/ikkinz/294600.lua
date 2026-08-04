local chosen_class = ''
require('bit')
function has_class(e, class_id)
  local char_bm = e:GetClassBitmask()
  return bit.band(char_bm, 2^(class_id - 1)) == 2^(class_id - 1)
end

function event_death_complete(e)
	eq.zone_emote(MT.Yellow,"The sentinel's rubble drops to the ground. It has been defeated.");
	eq.signal(294597,1,0); -- NPC: #Trigger_Ikkinz_3
end

function event_timer(e)
  if(e.timer=="OOBcheck") then
	  if (e.self:GetX() < 500 or e.self:GetX() > 700 or e.self:GetY() > -120 or e.self:GetY() < -300) then
		  e.self:CastSpell(3791,e.self:GetID()); -- Spell: Ocean's Cleansing
		  e.self:GotoBind();
		  e.self:WipeHateList();
		  e.self:SetHP(e.self:GetMaxHP());
    end
  end
end

function event_combat(e)
	if e.joined then
		eq.set_timer("OOBcheck", 3 * 1000);
    class_emote(e)
	else
		eq.stop_timer("OOBcheck");
	end
end

function event_spawn(e)
  set_vuln(e)
end

function event_cast_on(e)
  local do_damage = false
  if chosen_class == 'bard' then
    if e.spell:ID() == 3367 or e.spell:ID() == 4971 or e.spell:ID() == 3370 or e.spell:ID() == 3373 or e.spell:ID() == 3363 or e.spell:ID() == 3366 then
      do_damage = true
    end
  elseif chosen_class == 'beastlord' then
    if e.spell:ID() == 3492 or e.spell:ID() == 3493 or e.spell:ID() == 4972 or e.spell:ID() == 32 or e.spell:ID() == 4876 or e.spell:ID() == 4874 then
      do_damage = true
    end
  elseif chosen_class == 'cleric' then
    if e.spell:ID() == 3481 or e.spell:ID() == 3476 or e.spell:ID() == 3482 or e.spell:ID() == 3473 or e.spell:ID() == 3469 or e.spell:ID() == 4973 or e.spell:ID() == 3477 or e.spell:ID() == 4881 or e.spell:ID() == 3464 then
      do_damage = true
    end
  elseif chosen_class == 'druid' then
    if e.spell:ID() == 3435 or e.spell:ID() == 3434 or e.spell:ID() == 3437 or e.spell:ID() == 3446 or e.spell:ID() == 3449 or e.spell:ID() == 4106 or e.spell:ID() == 4974 or e.spell:ID() == 4885 or e.spell:ID() == 4884 or e.spell:ID() == 3452 then
      do_damage = true
    end
  elseif chosen_class == 'enchanter' then
    if e.spell:ID() == 3342 or e.spell:ID() == 3345 or e.spell:ID() == 3348 or e.spell:ID() == 3349 or e.spell:ID() == 4975 or e.spell:ID() == 4879 then
      do_damage = true
    end
  elseif chosen_class == 'necromancer' then
    if e.spell:ID() == 3315 or e.spell:ID() == 3306 or e.spell:ID() == 3309 or e.spell:ID() == 4098 or e.spell:ID() == 3303 or e.spell:ID() == 4890 or e.spell:ID() == 4891 or e.spell:ID() == 4889 then
      do_damage = true
    end
  elseif chosen_class == 'shadowknight' then
    if e.spell:ID() == 3400 or e.spell:ID() == 6 or e.spell:ID() == 456 or e.spell:ID() == 3401 or e.spell:ID() == 3408 or e.spell:ID() == 3489 or e.spell:ID() == 3491 or e.spell:ID() == 4982 or e.spell:ID() == 4904 or e.spell:ID() == 3413 then
      do_damage = true
    end
  elseif chosen_class == 'shaman' then
    if e.spell:ID() == 3379 or e.spell:ID() == 3386 or e.spell:ID() == 4095 or e.spell:ID() == 3394 or e.spell:ID() == 3390 or e.spell:ID() == 3396 then
      do_damage = true
    end
  elseif chosen_class == 'wizard' then
    if e.spell:ID() == 6737 or e.spell:ID() == 3328 or e.spell:ID() == 3330 or e.spell:ID() == 3331 or e.spell:ID() == 3335 or e.spell:ID() == 3976 or e.spell:ID() == 3334 or e.spell:ID() == 3336 or e.spell:ID() == 4066 or e.spell:ID() == 3333 or e.spell:ID() == 4981 or e.spell:ID() == 4905 or e.spell:ID() == 5458 or e.spell:ID() == 3191 or e.spell:ID() == 33339 or e.spell:ID() == 4907 or e.spell:ID() == 4906 then
      do_damage = true
    end
  end
  if do_damage then
    e.self:Emote("shakes violently as the energies of your spell syncronizes with it's body, causing additional cracks to appear!")
    e.self:SetHP(e.self:GetHP() - math.floor((e.self:GetMaxHP() / 10)))
  end
end
    
function set_vuln(e)
  --Get a random player in the area
  local subject = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 1000)
  local classes = {
    BARD = "bard",
    BEASTLORD = "beastlord",
    BERSERKER = "berserker",
    CLERIC = "cleric",
    DRUID = "druid",
    ENCHANTER = "enchanter",
    MAGICIAN = "magician",
    MONK = "monk",
    NECROMANCER = "necromancer",
    PALADIN = "paladin",
    RANGER = "ranger",
    ROGUE = "rogue",
    SHADOWKNIGHT = "shadowknight",
    SHAMAN = "shaman",
    WARRIOR = "warrior",
    WIZARD = "wizard"
  }

  local class_list = {}
  for class_const, class_name in pairs(classes) do
    if has_class(subject, Class[class_const]) then
      table.insert(class_list, class_name)
    end
  end

  --Pick a random class from the class list
  chosen_class = class_list[math.random(#class_list)]

  if chosen_class == 'berserker' then
    e.self:ModSkillDmgTaken(74, 200) --Frenzy
  elseif chosen_class == 'monk' then
    e.self:ModSkillDmgTaken(21, 200) --Dragon Punch
    e.self:ModSkillDmgTaken(23, 200) --Eagle Strike
    e.self:ModSkillDmgTaken(26, 200) --Flying Kick
    e.self:ModSkillDmgTaken(30, 200) --Kick
    e.self:ModSkillDmgTaken(38, 200) --Round Kick
    e.self:ModSkillDmgTaken(52, 200) --Tiger Claw
  elseif chosen_class == 'ranger' then
    e.self:ModSkillDmgTaken(7, 200) --Archery
  elseif chosen_class == 'rogue' then
    e.self:ModSkillDmgTaken(8, 200) --Backstab
  elseif chosen_class == 'warrior' then
    e.self:ModSkillDmgTaken(0, 200) --1HB
    e.self:ModSkillDmgTaken(1, 200) --1HS
    e.self:ModSkillDmgTaken(2, 200) --2HB
    e.self:ModSkillDmgTaken(3, 200) --2HS
    e.self:ModSkillDmgTaken(36, 200) --1HP
    e.self:ModSkillDmgTaken(77, 200) --2HP
    e.self:ModSkillDmgTaken(10, 200) --Bash
    e.self:ModSkillDmgTaken(30, 200) --Kick
  elseif chosen_class == 'paladin' then
    e.self:SetBodyType(BT.Undead, true)
  end
end

function class_emote(e)
  local message = ''
  if chosen_class == 'bard' then
    message = " fears the power of a foreboding melody."
  elseif chosen_class == 'beastlord' then
    message = " fears the power of deep gashes of feral savagery."
  elseif chosen_class == 'berserker' then
    message = " shies away from a heavy blade."
  elseif chosen_class == 'cleric' then
    message = " fears the power of a celestial spirit."
  elseif chosen_class == 'druid' then
    message = " seems weak in the face of the power of nature."
  elseif chosen_class == 'enchanter' then
    message = " appears vulnerable in mind and body."
  elseif chosen_class == 'magician' then
    message = " fears the power of summoned elements."
  elseif chosen_class == 'monk' then
    message = " fears the power of focused tranquility."
  elseif chosen_class == 'necromancer' then
    message = " fears the doom of death."
  elseif chosen_class == 'paladin' then
    message = " fears the power of a holy blade."
  elseif chosen_class == 'ranger' then
    message = " seems vulnerable to a true shot and fast blades."
  elseif chosen_class == 'rogue' then
    message = " fears what it cannot see."
  elseif chosen_class == 'shadowknight' then
    message = " dreads the strike of the dead."
  elseif chosen_class == 'shaman' then
    message = " cringes at the appearance of talismans."
  elseif chosen_class == 'warrior' then
    message = " fears the power of brute force and brawn."
  elseif chosen_class == 'wizard' then
    message = " falters when struck by the powers of magic itself."
  end

  e.self:Emote(message)
end
