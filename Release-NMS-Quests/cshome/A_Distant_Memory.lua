---@param e NPCEventSay
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Do you remember that item being stronger than it is?... That's because it was. Bring me four of any basic item and 500pp and I will give you a version worthy of your Rose Colored memories. Bring me four copies of any Rose Colored item and 2,000pp and I will give you exactly what your memory desires- absolute Apocrypha.")
    end
end

---@param e NPCEventTrade
function event_trade(e)
    local item_lib = require("items")
    
    local platinum = 500
    local item_id = 0
    local item_count = 0
    local reward_item_id = 0

    for i = 1, 4 do
        local inst = e.trade["item"..i]
        if inst ~= nil then
            if item_count == 0 then
                item_id = inst:GetItem():ID()
                item_count = 1
            else
                if item_id ~= inst:GetItem():ID() then
                    e.self:Say("You traded different items, I need 4 of the same item.")
                    item_lib.return_items(e.self, e.other, e.trade)
                    return
                end
                item_count = item_count+1
            end
        end
    end

    if item_count ~= 4 then
        e.self:Say("I need 4 of the same item to trade.")
        item_lib.return_items(e.self, e.other, e.trade)
        return
    end

    if item_id == 0 then
        e.self:Say("I need 4 of any item.")
        item_lib.return_items(e.self, e.other, e.trade)
        return
    end

    local item_name = eq.get_item_name(item_id)

    if item_name:find("Rose Colored") == 1 then
        platinum = 2000
        reward_item_id = item_id+100000
        if item_id < 80000 then reward_item_id = item_id+10000 end
        local apoc_name = eq.get_item_name(reward_item_id)
        if apoc_name:find("Apocryphal") ~= 1 then
            e.self:Say("I am unable to upgrade this Rose Colored item to Apocryphal.")
            item_lib.return_items(e.self, e.other, e.trade)
            return
        end
        is_rose_colored = true
    end

    if item_name:find("Apocryphal") == 1 then
        e.self:Say("I am unable to upgrade an Apocryphal item")
        item_lib.return_items(e.self, e.other, e.trade)
        return
    end

    if reward_item_id == 0 then
        reward_item_id = item_id+700000
        if item_id < 10000 then reward_item_id = item_id+70000 end
        local rose_name = eq.get_item_name(reward_item_id)
        if rose_name:find("Rose Colored") ~= 1 then
            e.self:Say("I am unable to upgrade this normal item to Rose Colored.")
            item_lib.return_items(e.self, e.other, e.trade)
            return
        end
    end

	if not item_lib.check_turn_in(e.trade, {item1 = item_id, item2 = item_id, item3 = item_id, item4 = item_id, platinum = platinum}) then
        e.self:Say(string.format("I require %d platinum to upgrade this item.", platinum))
        item_lib.return_items(e.self, e.other, e.trade)
        return
	end

    e.self:Say("Here, this is how I remember it.")
    e.other:SummonItem(reward_item_id)
    e.other:Ding()
	item_lib.return_items(e.self, e.other, e.trade)
end