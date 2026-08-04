-- a_clay_monolith #296049 - Second set on stairs
function event_spawn(e)
	e.self:SetSpecialAbility(35, 1); --turn on immunity
	e.self:SetSpecialAbility(19, 1); --turn on melee immune
	e.self:SetSpecialAbility(20, 1); --turn on magic immune
	e.self:SetSpecialAbility(24, 1); --turn on anti aggro
end

function event_signal(e)
	e.self:SetSpecialAbility(35, 0); --turn off immunity
	e.self:SetSpecialAbility(19, 0); --turn off melee immune
	e.self:SetSpecialAbility(20, 0); --turn off magic immune
	e.self:SetSpecialAbility(24, 0); --turn off anti aggro
end
