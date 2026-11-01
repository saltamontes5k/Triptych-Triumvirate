-- Native inventory slots, never bank/shared-bank storage. No task credit here.
local M={}
local function held(slot)
 return (slot>=Slot.PossessionsBegin and slot<=Slot.PossessionsEnd)
  or (slot>=Slot.PossessionsBagsBegin and slot<=Slot.PossessionsBagsEnd)
end
local function quantity(i)return i:IsStackable()and math.max(0,i:GetCharges())or 1 end
function M.count(c,id)
 local total=0;local inv=c:GetInventory()
 for _,slot in ipairs(c:GetInventorySlots())do
  if held(slot)then local i=inv:GetItem(slot);if i.valid and i:GetID()==id then total=total+quantity(i)end end
 end
 return total
end
function M.give(c,id,charges)
 -- GetItemIDAt returns INVALID_ID for an empty slot; test the native instance.
 if c:GetInventory():GetItem(Slot.Cursor).valid then
  c:Message(13,'Please empty your cursor first.');return false
 end
 local before=M.count(c,id);c:SummonItem(id,charges or 1)
 return M.count(c,id)>before
end
function M.take_one(c,id)
 local before=M.count(c,id);if before==0 then return false end
 local inv=c:GetInventory()
 for _,slot in ipairs(c:GetInventorySlots())do
  if held(slot)then
   local i=inv:GetItem(slot)
   if i.valid and i:GetID()==id and quantity(i)>0 then
    -- Zero deletes an entire nonstackable instance; one consumes one stack unit.
    c:DeleteItemInInventory(slot,i:IsStackable()and 1 or 0,true)
    return M.count(c,id)==before-1
   end
  end
 end
 return false
end
return M
