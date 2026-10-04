-- a steamwork gardener (436730) -- Lost Lumpling clue. Say "Lumpling" to
-- trigger its spiderling brood; it fights once provoked (task credit).

function event_say(e)
	if e.message:findi("lumpling") then
		if e.other:IsTaskActive(300034)
			and not e.self:GetEntityVariable("provoked") then
			e.self:SetEntityVariable("provoked", "1")
			e.self:Say("*hiss-click* LUMPLING? The little organic pulls my "
				.. "weeds. She belongs to the BROOD now.")
			local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
			for i = 1, 3 do
				local mob = eq.spawn2(436737, 0, 0, x + math.random(-30, 30),
					y + math.random(-30, 30), z, 0)
				if mob ~= nil then mob:AddToHateList(e.other, 1) end
			end
			e.self:AddToHateList(e.other, 500)
		else
			e.self:Say("*whirr* Weeds. Weeds and watering. That is all.")
		end
	end
end
