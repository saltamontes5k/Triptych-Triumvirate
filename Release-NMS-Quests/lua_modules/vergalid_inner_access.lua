-- Original personal shard/statue route. All values are server configuration;
-- native casts/custody and source-backed possession checks remain required.
local D=require('achievement_quest_vergalid_data')
local M={}
local function inside(c,b)return c:GetX()>=b.minx and c:GetX()<=b.maxx and c:GetY()>=b.miny and c:GetY()<=b.maxy and c:GetZ()>=b.minz and c:GetZ()<=b.maxz end
local function has_key(c,r)
 -- Native inventory mask: personal2 + bank4 + cursor32. Never keyring-only:
 -- the2007 report says destroying the shard removes access.
 return c:GetInventory():HasItem(r.flawless_item,1,38)>=0
end
function M.cast(e)
 local r=D.inner_access
 if not D.enabled or not r or not r.enabled or eq.get_zone_id()~=404 then return 0 end
 if not e.spell or e.spell:ID()~=r.arid_spell or e.cast_item_id~=r.arid_item or
    not e.cast_item_charge_consumed or not inside(e.self,r.crystals)then return 0 end
 -- Successful native item cast/charge custody, never a GM spell command or
 -- a packet naming the effect without the actual source item.
 if not has_key(e.self,r)then e.self:SummonItem(r.flawless_item,1)end
 if has_key(e.self,r)then e.self:Message(15,'You infuse the crystal\'s power into Vergalid\'s life stream.')end
 return 0
end
function M.click(e)
 local r=D.inner_access
 if not D.enabled or not r or not r.enabled or eq.get_zone_id()~=404 or e.door:GetDoorID()~=r.door_id then return 0 end
 if e.door:GetDoorName()~=r.door_model or e.self:CalculateDistance(e.door:GetX(),e.door:GetY(),e.door:GetZ())>r.click_range then return 1 end
 if not has_key(e.self,r)then e.self:Message(13,'You need the Flawless Indicolite Shard to use this passage.');return 1 end
 -- Move only this player through the statue, retaining the current instance.
 -- Do not open a shared door for unkeyed followers or transport the group.
 local p=e.self:GetX()>r.side_x and r.inner or r.outer
 e.self:MovePCInstance(404,eq.get_zone_instance_id(),p.x,p.y,p.z,p.heading)
 return 1
end
return M
