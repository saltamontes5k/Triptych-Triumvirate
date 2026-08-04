task_ids = require("task_ids")

function event_say(e)
  local qvic_flag = tonumber(e.other:GetAccountBucket("god.flags.qvic")) or 0
  if e.message:findi('hail') then
    if not e.other:IsTaskCompleted(task_ids.trusik_task) or qvic_flag ~= 1 then
      e.other:Message(MT.NPCQuestSay, "The Sentinel of the Altar ignores your every attempt to interact with it.")
    else
      get_expedition(e)
    end
  end
end

function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {item1 = 60173}) then
    get_expedition(e)
    e.other:SummonItem(60173)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end

function get_expedition(e)
  local dz_zoner = eq.get_entity_list():GetMobByNpcTypeID(293232)
  local dz_coord = { zone="kodtaz", x=dz_zoner:GetX(), y=dz_zoner:GetY(), z=dz_zoner:GetZ(), h=dz_zoner:GetHeading() }
  local dz_info = {
    expedition = { name="Ikkinz, Antechamber of Destruction", min_players=1, max_players=6 },
    instance = { zone="ikkinz", version=6, duration=eq.seconds("13h") },
    compass = dz_coord,
    safereturn = { zone="kodtaz", x=1279, y=-2004, z=-349.375, h=336 },
    zonein = dz_coord,
  }
  local dz = e.other:CreateExpedition(dz_info)
  if dz.valid then
    dz:AddReplayLockout(eq.seconds("14h"))
    e.other:Message(MT.NPCQuestSay, "The Sentinel of the Altar motions for you to enter the altar through the entrance behind him.")
  end
end
