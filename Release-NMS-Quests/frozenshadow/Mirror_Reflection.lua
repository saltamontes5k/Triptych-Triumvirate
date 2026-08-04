-- Monk Pre Epic

local hate_list = nil;

function event_spawn(e)
	eq.set_timer('checkhate', 1000);
	clone(e);
end

function event_timer(e)
	if e.timer == 'checkhate' then
		hate_list = e.self:CountHateList();
		if hate_list ~= nil and tonumber(hate_list) > 1 then
			eq.depop();
		end
	end
end

function clone(e)
  e.self:SendIllusionPacket(
    {
      race = e.other:GetRace(),
      gender = e.other:GetGender(),
      texture = e.other:GetTexture(),
      helmtexture = e.other:GetHelmTexture(),
      size = e.other:GetSize(),
      haircolor = e.other:GetHairColor(),
      hairstyle = e.other:GetHairStyle(),
      beard = e.other:GetBeardType(),
      beardcolor = e.other:GetBeardColor(),
      eyecolor1 = e.other:GetEyeColor1(),
      eyecolor2 = e.other:GetEyeColor2(),
      luclinface = e.other:GetLuclinFace()
    }
	);
end
