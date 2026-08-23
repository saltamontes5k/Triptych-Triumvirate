#include "FloatingTextManager.h"
#include "Renderable.h"
#include "Text.h"

FloatingTextManager::FloatingTextManager()
{
}


FloatingTextManager::~FloatingTextManager()
{
	Cleanup();
}

void FloatingTextManager::Initialize()
{

	ID3DXFont* ArialFont;
	HRESULT hr = D3DXCreateFont(g_pDevice, 24, 0, FW_NORMAL, 1, false, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, PROOF_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Arial", &ArialFont);
	if (SUCCEEDED(hr))
	{
		fontMap[EFonts::EFontArial] = ArialFont;
	}
	else
	{
		fontMap[EFonts::EFontArial] = nullptr;
	}

	ID3DXFont* ArialBFont;
	hr = D3DXCreateFont(g_pDevice, 24, 0, FW_BOLD, 1, false, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, PROOF_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Arial", &ArialBFont);
	if (SUCCEEDED(hr))
	{
		fontMap[EFonts::EFontArialBold] = ArialBFont;
	}
	else
	{
		fontMap[EFonts::EFontArialBold] = nullptr;
	}
}

void FloatingTextManager::Cleanup()
{

	for (auto delIt : HudObjects)
	{
		delete delIt;
		delIt = nullptr;
	}
	HudObjects.clear();

	for (auto fntItem : fontMap)
	{
		if (fntItem.second)
		{
			fntItem.second->Release();
			fntItem.second = nullptr;
		}
	}
	fontMap.clear();

	for (auto delIt : DeadHudObjects)
	{
		if (delIt)
		{
			delete delIt;
			delIt = nullptr;
		}
	}

	DeadHudObjects.clear();

	for (auto spellText : spellTextures)
	{
		if (spellText.second)
		{
			delete spellText.second;
			spellText.second = nullptr;
		}
	}

	spellTextures.clear();
}

EQ::Random randomNums;

int zPosition = 0;

extern bool addedTestText;
void FloatingTextManager::AddDamageText(PSPAWNINFO actor, int damage, int spellId, uint8_t nHitType)
{

	DamageText* tmp = new DamageText();

	tmp->Damage = damage;
	tmp->LastTick = MQGetTickCount64();
	tmp->SpellID = spellId;
	tmp->hitType = nHitType;
	bool isLocalActor = (PSPAWNINFO)pLocalPlayer == actor;
	tmp->fontColor = isLocalActor ? D3DXCOLOR(1.0f, 0.0f, 0.0f, 1.0f) : GetFontColorFromHitType(nHitType);
	tmp->fontSizePct = GetFontSizePctFromHitType(nHitType);
	auto rOffsetX = 0.0f;
	auto rOffsetY = 0.0f;
	auto rOffsetZ = zPosition - 5;
	zPosition = (zPosition + 1) % 10;

	if (isLocalActor)
		rOffsetZ -= -5;


	tmp->InitialActorLocation = D3DXVECTOR3(actor->X + rOffsetX, actor->Y + rOffsetY, actor->Z - rOffsetZ);
	tmp->LocationTween = tweeny::from(0).to(150).during(1000);
	tmp->OpacityTween = tweeny::from(1.0f).to(0).during(1000);
	if (spellId)
		tmp->Icon = LoadSpellImage(spellId);



	tmp->m_Text->Initialize(fontMap[GetFontTypeFromHitType(nHitType)], std::to_string(damage));

	HudObjects.push_back(tmp);
}

D3DXCOLOR FloatingTextManager::GetFontColorFromHitType(uint8_t nHitType)
{
	if (nHitType & 4)
		return D3DXCOLOR(0.0f, 1.0f, 0.0f, 1.0f);
	return D3DXCOLOR(1.0f, 1.0f, 1.0f, 1.0f);
}

float FloatingTextManager::GetFontSizePctFromHitType(uint8_t nHitType)
{
	if (nHitType & 2)
		return 0.6f;

	return 1.0f;
}

EFonts FloatingTextManager::GetFontTypeFromHitType(uint8_t nHitType)
{
	if (nHitType & 1)
		return EFonts::EFontArialBold;
	return EFonts::EFontArial;
}

float mapValue(float mainValue, float inValueMin, float inValueMax, float outValueMin, float outValueMax)
{
	return (mainValue - inValueMin) * (outValueMax - outValueMin) / (inValueMax - inValueMin) + outValueMin;
}

void FloatingTextManager::Render()
{

	if (!g_pDevice)
		return;

	auto current = MQGetTickCount64();
	int index = 0;
	for (auto it : HudObjects)
	{
		it->Display = true;
		if (it->LastTick == 0)
			it->LastTick = current;

		D3DXVECTOR3 screen;

		D3DXVECTOR3 world;
		world.x = it->InitialActorLocation.y;
		world.y = it->InitialActorLocation.x;
		world.z = it->InitialActorLocation.z;

		WorldToScreen(world, &screen);


		auto res = it->LocationTween.step((int)(current - it->LastTick));
		auto opacity = it->OpacityTween.step((int)(current - it->LastTick));
		it->LastTick = current;

		RECTF spriteRect = RECTF(), textRect = RECTF();

		auto dist = GetDistance3D((PSPAWNINFO)pLocalPlayer, world.y, world.x, world.z);

		//Convert 50 and 500 distance range to 0f and 1f range. Scale text accordingly
		float textScale = 0.85f;//mapValue(dist, 50.f, 500.f, 0.85f, 1.1f);
		float iconScale = 0.5f;//mapValue(dist, 50.f, 500.f, 0.65f, 0.85f);

		textScale = Clamp<float>(textScale, 0.45f, 1.0f);
		iconScale = Clamp<float>(iconScale, 0.45f, 1.0f);

		textScale *= it->fontSizePct;
		iconScale *= it->fontSizePct;


		if (it->Icon)
			it->Icon->GetRect(&spriteRect,   iconScale);

		it->m_Text->GetRect(&textRect, textScale);

		auto totalWidth = spriteRect.right + textRect.right;

		auto startx = screen.x - (totalWidth / 2);
		auto starty = screen.y + (abs(textRect.bottom - spriteRect.bottom) / 2.0f);

		if (it->Icon)
		{
			it->Icon->Render(D3DXVECTOR3(startx, starty - res, 0), D3DXVECTOR3(iconScale, iconScale, 1.0f), D3DXCOLOR(1, 1, 1, opacity), 0);
			startx += 50 * iconScale;
		}

		it->m_Text->Render(D3DXVECTOR3(startx, starty - res - 2.5f, 0), D3DXVECTOR3(textScale, textScale, 1.0f), D3DXCOLOR(it->fontColor.r, it->fontColor.g, it->fontColor.b, opacity), 2);

		if (opacity == 0)
		{
			DeadHudObjects.push_back(it);
		}
	}

	for (auto delIt : DeadHudObjects)
	{
		HudObjects.remove(delIt);
		delete delIt;
		delIt = nullptr;
	}
	DeadHudObjects.clear();
	
}

Sprite* FloatingTextManager::LoadSpellImage(int id)
{

	auto find = spellTextures.find(id);

	if (spellTextures.find(id) != spellTextures.end())
		return (*find).second;

	auto spell = GetSpellByID(id);

	if (!spell)
		return false;

	char tmp[MAX_STRING] = { 0 };

	sprintf_s(tmp, "%s\\SpellIcons\\%d.png", gszEQPath, spell->SpellIcon);

	Sprite* sprite = new Sprite();
	auto res = sprite->Initialize(g_pDevice, std::string(tmp), 40, 40);

	if (res)
		spellTextures.insert(pair<int, Sprite*>(id, sprite));
	else
		return nullptr;

	return sprite;
}
