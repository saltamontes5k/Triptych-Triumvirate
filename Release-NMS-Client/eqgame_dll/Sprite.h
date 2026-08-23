#pragma once
#include <string>
#include <d3d9.h>
#include <d3dx9math.h>
#include "Renderable.h"

class Sprite : Renderable
{
public:
	//Constructors and Destructor
	Sprite();
	~Sprite();

	//Sprite Functions
	bool Initialize(LPDIRECT3DDEVICE9 device, std::string file, int width, int height);
	bool IsInitialized();

	virtual void Render(D3DXVECTOR3 position, D3DXVECTOR3 scale, D3DXCOLOR color, int outlineOffset) override;

	//Pointers
	LPDIRECT3DTEXTURE9 tex;
	LPD3DXSPRITE sprite;

	virtual void GetRect(RECTF* rect, float scale) override;

private:
	bool initialized;
};
