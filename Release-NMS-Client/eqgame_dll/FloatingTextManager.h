#pragma once
#include "tweeny/tweeny.h"

#include <map>
#include <vector>
#include <list>
#include <d3d9.h>
#include <d3dx9math.h>


#include "MQ2Main.h"

#include "TickCount.h"
#include "Sprite.h"
#include "Text.h"

enum EFonts {
	EFontArial = 0,
	EFontArialBold = 1,
	EFontMAX = 2
};

extern void WorldToScreen(D3DXVECTOR3 world, D3DXVECTOR3* screen);
extern IDirect3DDevice9* g_pDevice;
namespace EQ {
	class Random {

	public:

		template<typename T>
		T EQClamp(const T& value, const T& lower, const T& upper)
		{
			return std::max(lower, std::min(value, upper));
		}

		// AKA old MakeRandomInt
		int Int(int low, int high)
		{
			if (low > high)
				std::swap(low, high);
			return int_dist(m_gen, int_param_t(low, high)); // [low, high]
		}

		// AKA old MakeRandomFloat
		double Real(double low, double high)
		{
			if (low > high)
				std::swap(low, high);
			return real_dist(m_gen, real_param_t(low, high)); // [low, high)
		}

		// example Roll(50) would have a 50% success rate
		// Roll(100) 100%, etc
		// valid values 0-100 (well, higher works too but ...)
		bool Roll(const int required)
		{
			return Int(0, 99) < required;
		}

		// valid values 0.0 - 1.0
		bool Roll(const double required)
		{
			return Real(0.0, 1.0) <= required;
		}

		// same range as client's roll0
		// This is their main high level RNG function
		int Roll0(int max)
		{
			if (max - 1 > 0)
				return Int(0, max - 1);
			return 0;
		}

		// std::shuffle requires a RNG engine passed to it, so lets provide a wrapper to use our engine
		template<typename RandomAccessIterator>
		void Shuffle(RandomAccessIterator first, RandomAccessIterator last)
		{
			static_assert(std::is_same<std::random_access_iterator_tag,
				typename std::iterator_traits<RandomAccessIterator>::iterator_category>::value,
				"EQ::Random::Shuffle requires random access iterators");
			std::shuffle(first, last, m_gen);
		}

		template<typename Iter, typename RandomGenerator>
		Iter select_randomly(Iter start, Iter end, RandomGenerator& g) {
			std::uniform_int_distribution<> dis(0, std::distance(start, end) - 1);
			std::advance(start, dis(g));
			return start;
		}

		template<typename Iter>
		Iter select_randomly(Iter start, Iter end) {
			static std::random_device rd;
			static std::mt19937 gen(rd());
			return select_randomly(start, end, gen);
		}

		void Reseed()
		{
			// We could do the seed_seq thing here too if we need better seeding
			// but that is mostly overkill for us, so just seed once
			std::random_device rd;
			m_gen.seed(rd());
		}

		Random()
		{
			Reseed();
		}

	private:
		typedef std::uniform_int_distribution<int>::param_type int_param_t;
		typedef std::uniform_real_distribution<double>::param_type real_param_t;
		std::mt19937 m_gen;
		std::uniform_int_distribution<int> int_dist;
		std::uniform_real_distribution<double> real_dist;
	};
}

class DamageText
{
public:
	DamageText()
	{
		SpellID = -1;
		LastTick = 0;
		Damage = 0;
		hitType = 0;
		InitialActorLocation = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
		Display = true;
		m_Text = new Text();
		Icon = nullptr;
		fontSizePct = 1.0f;
		fontColor = D3DXCOLOR(0.0f, 0.0f, 0.0f, 1.0f);
	};

	~DamageText() 
	{
		if (m_Text)
		{
			delete m_Text;
			m_Text = nullptr;
		}
	};

	int SpellID;
	unsigned __int64 LastTick;
	int Damage;
	uint8_t hitType;
	D3DXCOLOR fontColor;
	float fontSizePct;
	tweeny::tween<int> LocationTween;
	tweeny::tween<float> OpacityTween;
	D3DXVECTOR3 InitialActorLocation;
	Text* m_Text;
	Sprite* Icon;

	bool Display;
};


class FloatingTextManager
{
public:
	FloatingTextManager();
	~FloatingTextManager();

	void Initialize();

	void Cleanup();

	void AddDamageText(PSPAWNINFO actor, int damage, int spellId, uint8_t hitType);

	D3DXCOLOR GetFontColorFromHitType(uint8_t nHitType);

	float GetFontSizePctFromHitType(uint8_t nHitType);

	EFonts GetFontTypeFromHitType(uint8_t nHitType);

	void Render();


private:

	Sprite* LoadSpellImage(int id);
	std::list<DamageText*> HudObjects;
	std::list<DamageText*> DeadHudObjects;
	std::map<EFonts, ID3DXFont*> fontMap;
	std::map<int, Sprite*> spellTextures;

};

