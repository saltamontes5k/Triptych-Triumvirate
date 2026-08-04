--Ikkinz Raid #1: Chambers of Righteousness  
--spawn group 98734-98741 Crumbling_Monument (294344) adds

function event_signal(e)
  local guardian = eq.get_entity_list():GetMobByNpcTypeID(294341)
if (e.signal == 1) then
 if(e.self:GetSp2() == 98734) then
   eq.debug("Activating 1")
        e.self:SetSpecialAbility(24, 0); --turn off immunity
		e.self:SetSpecialAbility(35, 0); -- turn off immunity
		e.self:SetSpecialAbility(19, 0);
		e.self:SetSpecialAbility(20, 0);
  	e.self:AddToHateList(guardian:GetTarget(), 1)
    eq.set_timer("deactivate1", 15 * 1000);
 end
elseif (e.signal == 2) then
 if(e.self:GetSp2() == 98735) then
	   eq.debug("Activating 2")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
	e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate2", 15 * 1000);
 end
elseif (e.signal == 3) then
 if(e.self:GetSp2() == 98736) then
	   eq.debug("Activating 3")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
	e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate3", 15 * 1000);
 end
elseif (e.signal == 4) then
 if(e.self:GetSp2() == 98737) then
	   eq.debug("Activating 4")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
	e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate4", 15 * 1000);
 end
elseif (e.signal == 5) then
 if(e.self:GetSp2() == 98738) then
	   eq.debug("Activating 5")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
	e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate5", 15 * 1000);
 end
elseif (e.signal == 6) then
 if(e.self:GetSp2() == 98739) then
	   eq.debug("Activating 6")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
  e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate6", 15 * 1000);
 end
elseif (e.signal == 7) then
 if(e.self:GetSp2() == 98740) then
	   eq.debug("Activating 7")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
  e.self:AddToHateList(guardian:GetTarget(), 1)
  eq.set_timer("deactivate7", 15 * 1000);
 end
elseif (e.signal == 8) then
 if(e.self:GetSp2() == 98741) then
	   eq.debug("Activating 8")
e.self:SetSpecialAbility(24, 0); --turn off immunity
	e.self:SetSpecialAbility(35, 0); -- turn off immunity
	e.self:SetSpecialAbility(19, 0);
	e.self:SetSpecialAbility(20, 0);
  e.self:AddToHateList(guardian:GetTarget(), 1)
	eq.set_timer("deactivate8", 15 * 1000);
 end
end
end

function event_timer(e)
	if (e.timer == "deactivate1") then
		if(e.self:GetSp2() == 98734) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate1");
		end
	elseif (e.timer == "deactivate2") then
		if(e.self:GetSp2() == 98735) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate2");
		end
	elseif (e.timer == "deactivate3") then
		if(e.self:GetSp2() == 98736) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate3");
		end
	elseif (e.timer == "deactivate4") then
		if(e.self:GetSp2() == 98737) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate4");
		end
	elseif (e.timer == "deactivate5") then
		if(e.self:GetSp2() == 98738) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate5");
		end
	elseif (e.timer == "deactivate6") then
		if(e.self:GetSp2() == 98739) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate6");
		end
	elseif (e.timer == "deactivate7") then
		if(e.self:GetSp2() == 98740) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate7");
		end
	elseif (e.timer == "deactivate8") then
		if(e.self:GetSp2() == 98741) then
        	e.self:SetSpecialAbility(24, 1); --turn on immunity
        	e.self:SetSpecialAbility(35, 1); --turn turn on immunity
		e.self:WipeHateList();
		eq.stop_timer("deactivate8");
		end
    	end
end
