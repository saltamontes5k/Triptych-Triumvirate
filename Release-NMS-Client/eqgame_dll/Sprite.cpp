#include "Sprite.h"
#include "MQ2Main.h"

Sprite::Sprite()
{

	initialized = false;
	sprite = nullptr;
	tex = nullptr;
}

bool Sprite::Initialize(LPDIRECT3DDEVICE9 device, std::string file, int width, int height)
{
	//Same functionality as D3DXCreateTextureFromFile EXCEPT width and height are manually entered
	if (!SUCCEEDED(D3DXCreateTextureFromFileEx(device, file.c_str(),
		width, height, D3DX_DEFAULT, 0, D3DFMT_UNKNOWN, D3DPOOL_MANAGED, D3DX_DEFAULT,
		D3DX_DEFAULT, 0, NULL, NULL, &tex)))
	{
		return false;
	}
	LPDIRECT3DDEVICE9 device2;
	tex->GetDevice(&device2);

	//Attempt to create the sprite
	if (!SUCCEEDED(D3DXCreateSprite(device, &sprite)))
	{
		return false;
	}

	initialized = true;

	return true;
}

bool Sprite::IsInitialized()
{
	//Are we initialized (have a texture and sprite)
	return initialized;
}

void Sprite::Render(D3DXVECTOR3 position, D3DXVECTOR3 scale, D3DXCOLOR color, int outlineOffset)
{
	if (sprite && tex)
	{
		D3DXMATRIX Before;
		sprite->Begin(D3DXSPRITE_ALPHABLEND);

		::D3DXMATRIX scaling_matrix;
		::D3DXMATRIX rotation_matrix;
		::D3DXMATRIX move_matrix;
		::D3DXMATRIX intermediate_matrix;
		::D3DXMATRIX final_matrix;

		::D3DXMatrixScaling(&scaling_matrix, scale.x, scale.y, 1.0f);
		::D3DXMatrixRotationZ(&rotation_matrix, 0);
		::D3DXMatrixTranslation(&move_matrix, position.x, position.y, 0.0f);
		::D3DXMatrixMultiply(&intermediate_matrix, &scaling_matrix, &rotation_matrix);
		::D3DXMatrixMultiply(&final_matrix, &intermediate_matrix, &move_matrix);
		auto pos = D3DXVECTOR3(0, 0, 0);
		sprite->SetTransform(&final_matrix);
		sprite->Draw(tex, NULL, NULL, &pos, color);

		sprite->End();
	}
}

void Sprite::GetRect(RECTF* rect, float scale)
{

	D3DSURFACE_DESC desc;
	tex->GetLevelDesc(0, &desc);

	*rect = { 0, 0, desc.Width * scale, desc.Height * scale };
}

Sprite::~Sprite()
{
	if (sprite)
	{
		sprite->Release();
		sprite = 0;
	}

	if (tex)
	{
		tex->Release();
		tex = 0;
	}
}
