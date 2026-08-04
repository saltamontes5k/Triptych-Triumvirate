function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. researcher!  There are many things to be found here.  Our selection grows daily.  Would you [care for any books]?");
	elseif e.message:findi("any book") then
		e.self:Say("Excellent!  I love to see the young so interested in knowledge.  What subject would you like to research? My most interesting topics today would have to be the [Hole], [old Paineel], the [Underfoot], and the [history of Paineel].");
	elseif e.message:findi("history of paineel") then
		e.self:Say("Tis an excellent topic. " .. e.other:GetName() .. ".  Much can be learned of a civilization if one first understands its history.  I hope you enjoy the book.");
		if not e.other:HasItem(18093) then
			e.other:SummonItem(18093); -- Item: History of Paineel
		end
	elseif e.message:findi("hole") then
		e.self:Say("Here you are. " .. e.other:GetName() .. ".  The book has old bindings and is worthless to most. but the value of knowledge is priceless.");
		if not e.other:HasItem(18091) then
			e.other:SummonItem(18091); -- Item: History of the Hole
		end
	elseif e.message:findi("underfoot") then
		e.self:Say("Excellent choice. " .. e.other:GetName() .. ".  The Underfoot is a mysterious place.  I hope you get as much from the book as I did.");
		if not e.other:HasItem(18094) then
			e.other:SummonItem(18094); -- Item: Underfoot Musings
		end
	elseif e.message:findi("old paineel") then
		e.self:Say("Take this book. " .. e.other:GetName() .. ".  It contains the history of the ancient city from which we came.");
		if not e.other:HasItem(18092) then
			e.other:SummonItem(18092); -- Item: Old Paineel
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
