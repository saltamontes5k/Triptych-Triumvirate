function event_say(e)
	if e.message:findi("Hail") then
		local stuffs_link = eq.silent_say_link("stuffs")
		e.self:Say(
			string.format(
				"Grimror have no time ta talk. Gots [%s] ta do.",
				stuffs_link
			)
		)
	elseif e.message:findi("stuffs") then
		local big_plan_link = eq.silent_say_link("big plan")
		e.self:Say(
			string.format(
				"I wuz sent here by Zulort to, err. . . To gadder some alchemy type stuffs. Him have [%s], and need me to travel lots.",
				big_plan_link
			)
		)
	elseif e.message:findi("big plan") then
		local help_grimror_link = eq.silent_say_link("help Grimror")
		e.self:Emote(
			string.format(
				"laughs. 'Me not tell you dat! Grimror keep secrets secret. You gonna [%s] or no?'",
				help_grimror_link
			)
		)
	elseif e.message:findi("help Grimror") then
		local dem_tings_link = eq.silent_say_link("dem tings")
		e.self:Say("Dat good!")
		e.self:Say(
			string.format(
				"Grimror been getting compon ents for dayz now and Grimror still not finushed. You gonna get [%s] fur me?",
				dem_tings_link
			)
		)
	elseif e.message:findi("dem tings") then
		e.self:Say("Grimror need bile, dat stuff es strong here! But Grimror keent seem to git eet all. Bile comz from da leetle bugs. Keel little bugs, and geeve Grimror dere leetel bodiez and Grimror give yuuz anyting dat yuuz want. Dere on four leetel buggiez dat Grimror still neez, two uf dem come from da fliez, one comez from da wurmiez, and one comez from the moss-skeeterz. Yuuz bring Grimror dere lavas and Grimror geeve yuuz, and yuuz freends, anyting yuuz want")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 9290, item2 = 9291, item3 = 9292, item4 = 9293}) then
		e.self:Say("Yuuz dun guud! But Grimror keent geeve you anyting, but Grimror have dis. Grimror also have seekret information. Krypt of Deekay in in here. Dunt tink yuuz wanna go in dere. Dere be mean old rotten keengs in dere, yuuz dunt want ta mess wif dem, dere also be udder sortz uf baddies in dere, be carefuul if yuuz goin dat way. I hurd stories dat Bertoshulus es in dere too, Grimror even saw him in here one time. In dis place yuuz only gots ta worry about Grummus, him fatter dan Grimror, got theek skin too. Him have key ta get inna de Krypt,but Grimror knew da seekret way een. Dat bracer keen make da portil into de Krypt tink dat yuuz belongz dere. Guud barshin!")

		e.other:SummonItem(9294) -- Item: Bangle of Disease Warding
	end
end