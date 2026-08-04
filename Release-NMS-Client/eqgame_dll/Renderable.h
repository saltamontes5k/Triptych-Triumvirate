#pragma once

#include "RECTF.h"

class Renderable {
public:
	virtual void Render(D3DXVECTOR3 position, D3DXVECTOR3 scale, D3DXCOLOR color, int outlineOffset) = 0;
	virtual void GetRect(RECTF* rect, float scale) = 0;
};