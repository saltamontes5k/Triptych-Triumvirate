task_ids = require('task_ids')
task_list = {
  task_ids.enchanted_platinum_bar,
  task_ids.enchanted_silver_bar,
  task_ids.enchanted_gold_bar,
  task_ids.enchanted_electrum_bar,
  task_ids.enchanted_velium_bar,
  task_ids.enchanted_clay,
  task_ids.enchanted_adamantite,
  task_ids.enchanted_brellium,
  task_ids.viscous_mana,
  task_ids.cloudy_mana,
  task_ids.clear_mana,
  task_ids.distilled_mana,
  task_ids.purified_mana,
  task_ids.imbued_opal,
  task_ids.imbued_topaz,
  task_ids.imbued_pebble,
  task_ids.imbued_amber,
  task_ids.imbued_sapphire,
  task_ids.imbued_ruby,
  task_ids.imbued_emerald,
  task_ids.imbued_black_pearl,
  task_ids.imbued_diamond,
  task_ids.imbued_quartz,
  task_ids.imbued_black_sapphire,
  task_ids.imbued_peridot,
  task_ids.imbued_ivory,
  task_ids.imbued_jade,
  task_ids.imbued_fire_opal,
  task_ids.diamond_of_disease,
  task_ids.diamond_of_justice,
  task_ids.diamond_of_nightmares,
  task_ids.diamond_of_storms,
  task_ids.diamond_of_earth,
  task_ids.diamond_of_torment,
  task_ids.diamond_of_valor,
  task_ids.diamond_of_war,
  task_ids.diamond_of_air,
  task_ids.diamond_of_fire,
  task_ids.diamond_of_water
}
good_list = {
  task_ids.rebreather,
  task_ids.aqualung,
  task_ids.clockwork_grease,
  task_ids.wind_bow_cam,
  task_ids.philter_of_trans
};

function say_price(e)
  --TODO: Do SSF check here
  e.other:Message(MT.NPCQuestSay, "Jeweler Imua says 'A hardy adventurer such as yourself, with access to friends and tradesmen, I would ask the sum of 2000 platinum coins for my services.")
   --e.other:Message(MT.NPCQuestSay, "Jeweler Imua says 'For such a brave adventurer, facing this world of danger all alone, I would ask only the amount of 200 platinum coins to complete the work.")
end

function event_say(e)
  if e.message:findi('hail') then
    e.other:Message(MT.NPCQuestSay, "Jeweler Imua says 'Greetings, " .. e.other:GetCleanName() ..".  I've had some time to practice my enchanting and can now make some enchanting [" .. eq.say_link('goods') .. "].  If you would like for me to make something for you, just let me know.  I've also gotten a line on some unusual tinkering and alchemy [" .. eq.say_link("items") .. "], if you're interested.  If we've already discussed which item you would like to make, but you need me to remind you of the [" .. eq.say_link('price') .. "], I can.'")
  end
  if e.message:findi('goods') then
    e.other:Message(MT.NPCQuestSay, "Jeweler Imua says 'Wonderful!  Just let me know which you would like, then bring me the materials and my payment.  Hmm, for one such as you...")
    say_price(e)
    e.other:TaskSelector(task_list)
  end
  if e.message:findi('items') then
    e.other:Message(MT.NPCQuestSay, "Jeweler Imua says 'Wonderful!  Just let me know which item you are interested in, then bring me the materials and the payment.  Hmm, for one such as you...")
    say_price(e)
    e.other:TaskSelector(good_list)
  end
  if e.message:findi('price') then
    say_price(e)
  end
end

function event_trade(e)
  local item_lib = require("items")
  -- TODO: If SSF, set this to 200 plat
  local cost = 2000;
  local item_list = {
    [task_ids.enchanted_platinum_bar] = {item1 = 16503, platinum = cost},
    [task_ids.enchanted_silver_bar] = {item1 = 16500, platinum = cost},
    [task_ids.enchanted_gold_bar] = {item1 = 16502, platinum = cost},
    [task_ids.enchanted_electrum_bar] = {item1 = 16501, platinum = cost},
    [task_ids.enchanted_velium_bar] = {item1 = 22098, platinum = cost},
    [task_ids.enchanted_clay] = {item1 = 16902, platinum = cost},
    [task_ids.enchanted_adamantite] = {item1 = 10475, platinum = cost},
    [task_ids.enchanted_brellium] = {item1 = 10474, platinum = cost},
    [task_ids.viscous_mana] = {item1 = 10024, item2 = 16965, platinum = cost},
    [task_ids.cloudy_mana] = {item1 = 10028, item2 = 16965, platinum = cost},
    [task_ids.clear_mana] = {item1 = 10029, item2 = 16965, platinum = cost},
    [task_ids.distilled_mana] = {item1 = 10034, item2 = 10034, item3 = 16965, platinum = cost},
    [task_ids.imbued_opal] = {item1 = 10030, platinum = cost},
    [task_ids.imbued_topaz] = {item1 = 10025, platinum = cost},
    [task_ids.imbued_pebble] = {item1 = 12832, platinum = cost},
    [task_ids.imbued_amber] = {item1 = 10022, platinum = cost},
    [task_ids.imbued_sapphire] = {item1 = 10034, platinum = cost},
    [task_ids.imbued_ruby] = {item1 = 10035, platinum = cost},
    [task_ids.imbued_emerald] = {item1 = 10029, platinum = cost},
    [task_ids.imbued_black_pearl] = {item1 = 10012, platinum = cost},
    [task_ids.imbued_diamond] = {item1 = 10037, platinum = cost},
    [task_ids.imbued_quartz] = {item1 = 10021, platinum = cost},
    [task_ids.imbued_black_sapphire] = {item1 = 10036, platinum = cost},
    [task_ids.imbued_peridot] = {item1 = 10028, platinum = cost},
    [task_ids.imbued_ivory] = {item1 = 22504, platinum = cost},
    [task_ids.imbued_jade] = {item1 = 10023, platinum = cost},
    [task_ids.imbued_fire_opal] = {item1 = 10031, platinum = cost},
    [task_ids.diamond_of_disease] = {item1 = 29346, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_justice] = {item1 = 21954, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_nightmares] = {item1 = 29525, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_storms] = {item1 = 29526, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_earth] = {item1 = 29523, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_torment] = {item1 = 26635, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_valor] = {item1 = 29956, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_war] = {item1 = 29419, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_air] = {item1 = 29524, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_fire] = {item1 = 29521, item2 = 15981, platinum = cost},
    [task_ids.diamond_of_water] = {item1 = 29522, item2 = 15981, platinum = cost},
  };
  local goods_list = {
    [task_ids.clockwork_grease] = {item1 = 12564, item2 = 12564, item3 = 21347, platinum = cost},
    [task_ids.wind_bow_cam] = {item1 = 30486, item2 = 30496, item3 = 30500, platinum = cost}
  };

  if e.other:IsTaskActive(task_ids.aqualung) then
    if item_lib.check_turn_in(e.trade, {item1 = 13019}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 0, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16850}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 1, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16857}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 2, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16861}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 3, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16862}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 4, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16890}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 5, 1)
    end
    if item_lib.check_turn_in(e.trade, {platinum = cost}) then
      e.other:UpdateTaskActivity(task_ids.aqualung, 6, 1)
    end
    return
  end

  if e.other:IsTaskActive(task_ids.rebreather) then
    if item_lib.check_turn_in(e.trade, {item1 = 4001}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 0, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16873}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 1, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16881}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 2, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16888}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 3, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16891}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 4, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16892}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 5, 1)
    end
    if item_lib.check_turn_in(e.trade, {platinum = cost}) then
      e.other:UpdateTaskActivity(task_ids.rebreather, 6, 1)
    end
    return
  end

  if e.other:IsTaskActive(task_ids.purified_mana) then
    if item_lib.check_turn_in(e.trade, {item1 = 10035, item2 = 10035, item3 = 10035, item4 = 10035}) then
      e.other:UpdateTaskActivity(task_ids.purified_mana, 0, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16965}) then
      e.other:UpdateTaskActivity(task_ids.purified_mana, 1, 1)
    end
    if item_lib.check_turn_in(e.trade, {platinum = cost}) then
      e.other:UpdateTaskActivity(task_ids.purified_mana, 2, 1)
    end
    return
  end
  
  if e.other:IsTaskActive(task_ids.philter_of_trans) then
    if item_lib.check_turn_in(e.trade, {item1 = 95922, item2 = 95922, item3 = 95922}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 0, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 14242, item2 = 14242}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 1, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 16510}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 2, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 22143}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 3, 1)
    end
    if item_lib.check_turn_in(e.trade, {item1 = 95843}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 4, 1)
    end
    if item_lib.check_turn_in(e.trade, {platinum = cost}) then
      e.other:UpdateTaskActivity(task_ids.philter_of_trans, 5, 1)
    end
    return
  end

  for i=1, #task_list do
    if not (task_list[i] == task_ids.purified_mana) or not (task_list[i] == task_ids.rebreather) or not (task_list[i] == task_ids.aqualung) then
      if e.other:IsTaskActive(task_list[i]) then
        if item_lib.check_turn_in(e.trade, item_list[task_list[i]]) then
          e.other:UpdateTaskActivity(task_list[i], 0, 1)
          e.other:UpdateTaskActivity(task_list[i], 1, 1)
          e.other:UpdateTaskActivity(task_list[i], 2, 1)
          return
        end
      end
    end
  end
  for i=1, #good_list do
    if not (good_list[i] == task_ids.purified_mana) or not (good_list[i] == task_ids.rebreather) or not (good_list[i] == task_ids.aqualung) then
      if e.other:IsTaskActive(good_list[i]) then
        if item_lib.check_turn_in(e.trade, goods_list[good_list[i]]) then
          e.other:UpdateTaskActivity(good_list[i], 0, 1)
          e.other:UpdateTaskActivity(good_list[i], 1, 1)
          e.other:UpdateTaskActivity(good_list[i], 2, 1)
          e.other:UpdateTaskActivity(good_list[i], 3, 1)
        end
        return
      end
    end
  end


  item_lib.return_items(e.self, e.other, e.trade)
end
