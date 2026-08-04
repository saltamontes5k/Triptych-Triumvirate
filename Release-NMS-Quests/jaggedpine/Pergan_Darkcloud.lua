---- Quest:Jaggedpine Recipes
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hello there " .. e.other:GetName() .. ". My wife Nerdala and I have been in the business of making delicacies from the fresh ingredients available locally in our forest. Well, really my wife is the better cook but I'm pretty good at making [Noodles].");
	elseif(e.message:findi("noodles")) then
		e.self:Say("Noodles are pretty easy. They are just Flour, Egg and Water. It's [how you use the Noodles] after you make them that is important.");
	elseif(e.message:findi("how")) then
		e.self:Say("There's a whole bunch of things you can do with Noodles but the best thing you can do with them are to make [pastas] and [casseroles].");
	elseif(e.message:findi("pastas")) then
		e.self:Say("Well, you're going to need to talk to my wife about those recipes. She guards them pretty closely though so you may have to do some prying. Now what I am really good at is making Omelets!");
	elseif(e.message:findi("casseroles")) then
		e.self:Say("Well, you're going to need to talk to my wife about those recipes. She guards them pretty closely though so you may have to do some prying. Now what I am really good at is making Omelets!");
	end
end

function event_trade(e)
    local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade)
end
