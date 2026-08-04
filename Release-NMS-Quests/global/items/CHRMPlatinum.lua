-- CHRMPlatinum

function event_scale_calc(e)
    local money = e.owner:GetAllMoney() / 100000000;

    -- Ensure money is at least 0
    if money < 0 then
        money = 0;
    end

    -- Apply a log scale for money greater than 1 (100k platinum)
    if money > 1 then
        money = 1 + math.log10(money);
    end

    e.self:SetScale(money);
end
