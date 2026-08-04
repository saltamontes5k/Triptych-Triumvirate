#include "Text.h"
#include "MQ2Main.h"



Text::Text()
{
	_font = nullptr;
	_uiSprite = nullptr;
	_rect = RECT();
}


Text::~Text()
{
	_uiSprite->Release();
	_uiSprite = nullptr;
}

bool Text::Initialize(ID3DXFont* fontPtr, std::string text)
{

	if (!SUCCEEDED(D3DXCreateSprite(g_pDevice, &_uiSprite)))
	{
		return false;
	}

	SetRect(&_rect, 0, 0, 500, 60);
	_text = text;
	_font = fontPtr;
	return true;
}

void Text::Render(D3DXVECTOR3 position, D3DXVECTOR3 scale, D3DXCOLOR color, int outlineOffset)
{

	if (!_uiSprite || !_font)
		return;

	::D3DXMATRIX scaling_matrix;
	::D3DXMATRIX rotation_matrix;
	::D3DXMATRIX move_matrix;
	::D3DXMATRIX intermediate_matrix;
	::D3DXMATRIX final_matrix;
	D3DXMatrixIdentity(&scaling_matrix);
	D3DXMatrixIdentity(&rotation_matrix);
	D3DXMatrixIdentity(&move_matrix);
	D3DXMatrixIdentity(&intermediate_matrix);
	D3DXMatrixIdentity(&final_matrix);
	::D3DXMatrixScaling(&scaling_matrix, scale.x, scale.y, 1.0f);
	::D3DXMatrixRotationZ(&rotation_matrix, 0);
	::D3DXMatrixTranslation(&move_matrix, position.x, position.y, 0.0f);
	::D3DXMatrixMultiply(&intermediate_matrix, &scaling_matrix, &rotation_matrix);
	::D3DXMatrixMultiply(&final_matrix, &intermediate_matrix, &move_matrix);

	auto pos = D3DXVECTOR3(0, 0, 0);

	auto hr = _uiSprite->Begin(D3DXSPRITE_ALPHABLEND);

	hr = _uiSprite->SetTransform(&final_matrix);


	if (outlineOffset > 0)
	{
		RECT tmp;
		tmp = _rect;
		tmp.left = _rect.left - outlineOffset;
		tmp.top = _rect.top - outlineOffset;
		tmp.bottom = position.y + _rect.bottom + 100;
		tmp.right = position.x + _rect.right + 100;
		hr = _font->DrawTextA(_uiSprite, _text.c_str(), -1, &tmp, DT_LEFT | DT_NOCLIP, D3DXCOLOR(0, 0, 0, color.a));
		tmp = _rect;
		tmp.left = _rect.left + outlineOffset;
		tmp.top = _rect.top - outlineOffset;
		tmp.bottom = position.y + _rect.bottom + 100;
		tmp.right = position.x + _rect.right + 100;
		hr = _font->DrawTextA(_uiSprite, _text.c_str(), -1, &tmp, DT_LEFT | DT_NOCLIP, D3DXCOLOR(0, 0, 0, color.a));
		tmp = _rect;
		tmp.left = _rect.left + outlineOffset;
		tmp.top = _rect.top + outlineOffset;
		tmp.bottom = position.y + _rect.bottom + 100;
		tmp.right = position.x + _rect.right + 100;
		hr = _font->DrawTextA(_uiSprite, _text.c_str(), -1, &tmp, DT_LEFT | DT_NOCLIP, D3DXCOLOR(0, 0, 0, color.a));
		tmp = _rect;
		tmp.left = _rect.left - outlineOffset;
		tmp.top = _rect.top + outlineOffset;
		tmp.bottom = position.y + _rect.bottom + 100;
		tmp.right = position.x + _rect.right + 100;
		hr = _font->DrawTextA(_uiSprite, _text.c_str(), -1, &tmp, DT_LEFT | DT_NOCLIP, D3DXCOLOR(0, 0, 0, color.a));
	}

	hr = _font->DrawTextA(_uiSprite, _text.c_str(), -1, &_rect, DT_LEFT | DT_NOCLIP, color);

	hr = _uiSprite->End();
}

void Text::GetRect(RECTF* rect, float scale)
{
	if (!_font)
		return;
	_font->DrawTextA(0, _text.c_str(), -1, &_rect, DT_LEFT | DT_CALCRECT, 0x0);
	*rect = {0, 0, _rect.right * scale, _rect.bottom * scale};
}
