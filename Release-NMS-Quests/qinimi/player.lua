-- Task ID definitions
local bic_abysmal = 9
local bic_qinimi = 8
local bic_barindu = 10
local bic_riwwi = 11
local bic_ferubi = 12
local bic_sewers = 13
local bic_vxed = 14
local bic_tipt = 15
local bic_outer = 16
local bic_yxtta = 17
local bic_kodtaz = 18

function event_loot(e)
	if(e.self:HasClass(Class.DRUID) and e.item:GetID() == 62870) then
		local qglobals = eq.get_qglobals(e.self);
		if(qglobals["druid_epic"] == "10") then
			if(qglobals["druid_epic_qin"] == nil ) then
				eq.spawn2(893,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- #a chest (Epic 2.0)
				eq.set_global("druid_epic_qin","1",5,"F");
			end
		else
			return 1;
		end		
	end
end

function event_player_pickup(e)
  if e.item:GetID() == 67397 then
    e.self:UpdateTaskActivity(bic_qinimi, 0, 1)
  end
end
