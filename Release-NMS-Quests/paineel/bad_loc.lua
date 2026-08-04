-- Ports people from 0 0 0 to safe loc

function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 20, xloc + 20, yloc - 20, yloc + 20);
end

function event_enter(e)
	e.other:MovePC(75, 200,800,1.51,0);
end
