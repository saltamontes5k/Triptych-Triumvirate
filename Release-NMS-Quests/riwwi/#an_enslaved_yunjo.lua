task_ids = require('task_ids')
function event_say(e)
  local started = tonumber(eq.get_zone():GetVariable("arena_started")) or 0

  if e.other:IsTaskActivityActive(task_ids.bic_riwwi, 10) or e.other:IsTaskActivityActive(task_ids.bic_riwwi, 11) then
    if e.message:findi('hail') and started == 0 then
      e.other:Message(MT.NPCQuestSay, "An enslaved yunjo says 'It's you! The champion everyone has spoken of! Have you come to defy the Muramites?'")
    end
    if e.message:findi('hail') and started == 1 then
      e.other:Message(MT.NPCQuestSay, "An enslaved yunjo says 'You are very strong. If you wish to challenge the Muramites, hand me the item Turlini gave you and I will gain their attention again.'")
      end
    if e.message:findi('defy') then
      e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
      eq.depop_with_timer(282096)
      eq.depop_with_timer(282026)
      eq.unique_spawn(282098, 0, 0, -174, 625, 73, 258)
      e.other:SummonItem(52223)
      eq.get_zone():SetVariable("arena_started", "1")
      e.other:UpdateTaskActivity(task_ids.bic_riwwi, 10, 1)
    end
  end
end

function event_signal(e)
  if e.signal == 1 then
    e.self:Say("Stand fast and prepare for a fight! They're sending a bloodthirsty beast into the arena to kill you as we speak. If you defeat it, place the head in this sack as proof and return it to Turlini. He is the leader of the resistance and may be able to assist you for helping us.")
  end
end

function event_trade(e)
  local item_lib = require("items")

  if item_lib.check_turn_in(e.trade, {item1 = 52085}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 1, 5)
    e.other:SummonItem(52224)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52086}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 2, 5)
    e.other:SummonItem(52225)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52087}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 3, 5)
    e.other:SummonItem(52226)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52088}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 4, 5)
    e.other:SummonItem(52227)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52089}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 5, 5)
    e.other:SummonItem(52228)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52090}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 6, 5)
    e.other:SummonItem(52229)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52091}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 7, 5)
    e.other:SummonItem(52230)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52092}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 8, 5)
    e.other:SummonItem(52231)
  end
  if item_lib.check_turn_in(e.trade, {item1 = 52093}) then
    e.other:Message(MT.Red, "An enslaved yunjo shouts '" .. e.other:GetCleanName() .. " defies you! Do you hear me? " .. e.other:GetCleanName() .. " defies you and will destroy your kind!'")
    eq.signal(282098, 9, 5)
    e.other:SummonItem(52232)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
