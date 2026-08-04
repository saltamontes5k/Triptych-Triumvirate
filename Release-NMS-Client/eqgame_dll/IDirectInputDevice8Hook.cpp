#include <dinput.h>
#include "IDirectInputDevice8Hook.h"

static bool mSpaceKeyState = false;
static bool mLastSpaceKeyState = false;

// TODO Add your own known gamepad GUIDs here!

IDirectInputDevice8Hook::IDirectInputDevice8Hook(IDirectInput8 * dinput, IDirectInputDevice8 * dinputdevice, REFGUID guid)
{
	m_pDI = dinput;
	m_pDIDevice = dinputdevice;
	m_GUID = guid;
}

/*** IUnknown methods ***/
HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::QueryInterface(REFIID riid, LPVOID * ppvObj)
{
	return m_pDIDevice->QueryInterface(riid, ppvObj);
}

ULONG STDMETHODCALLTYPE IDirectInputDevice8Hook::AddRef()
{
	return m_pDIDevice->AddRef();
}

ULONG STDMETHODCALLTYPE IDirectInputDevice8Hook::Release()
{
	ULONG uRet = m_pDIDevice->Release();

	if (uRet == 0)
		// If the reference count is 0 delete ourselves
		delete this;

	return uRet;
}

/*** IDirectInputDevice8A methods ***/
HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetCapabilities(LPDIDEVCAPS p0)
{
	return m_pDIDevice->GetCapabilities(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::EnumObjects(LPDIENUMDEVICEOBJECTSCALLBACKA p0, LPVOID p1, DWORD p2)
{
	return m_pDIDevice->EnumObjects(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetProperty(REFGUID rguid, LPDIPROPHEADER p1)
{
	return m_pDIDevice->GetProperty(rguid, p1);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SetProperty(REFGUID rguid, LPCDIPROPHEADER p1)
{
	return m_pDIDevice->SetProperty(rguid, p1);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::Acquire()
{
	return m_pDIDevice->Acquire();
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::Unacquire()
{
	return m_pDIDevice->Unacquire();
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetDeviceState(DWORD p0, LPVOID p1)
{
	// Forward call
	HRESULT hResult = m_pDIDevice->GetDeviceState(p0, p1);
	return hResult;
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetDeviceData(DWORD p0, LPDIDEVICEOBJECTDATA p1, LPDWORD p2, DWORD p3)
{
	// Forward call
	HRESULT hResult = m_pDIDevice->GetDeviceData(p0, p1, p2, p3);
	// Return result
	return hResult;
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SetDataFormat(LPCDIDATAFORMAT p0)
{
	return m_pDIDevice->SetDataFormat(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SetEventNotification(HANDLE p0)
{
	return m_pDIDevice->SetEventNotification(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SetCooperativeLevel(HWND p0, DWORD p1)
{
	return m_pDIDevice->SetCooperativeLevel(p0, p1);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetObjectInfo(LPDIDEVICEOBJECTINSTANCE p0, DWORD p1, DWORD p2)
{
	return m_pDIDevice->GetObjectInfo(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetDeviceInfo(LPDIDEVICEINSTANCE p0)
{
	return m_pDIDevice->GetDeviceInfo(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::RunControlPanel(HWND p0, DWORD p1)
{
	return m_pDIDevice->RunControlPanel(p0, p1);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::Initialize(HINSTANCE p0, DWORD p1, REFGUID rguid)
{
	return m_pDIDevice->Initialize(p0, p1, rguid);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::CreateEffect(REFGUID rguid, LPCDIEFFECT p1, LPDIRECTINPUTEFFECT * p2, LPUNKNOWN p3)
{
	return m_pDIDevice->CreateEffect(rguid, p1, p2, p3);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::EnumEffects(LPDIENUMEFFECTSCALLBACK p0, LPVOID p1, DWORD p2)
{
	return m_pDIDevice->EnumEffects(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetEffectInfo(LPDIEFFECTINFO p0, REFGUID rguid)
{
	return m_pDIDevice->GetEffectInfo(p0, rguid);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetForceFeedbackState(LPDWORD p0)
{
	return m_pDIDevice->GetForceFeedbackState(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SendForceFeedbackCommand(DWORD p0)
{
	return m_pDIDevice->SendForceFeedbackCommand(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::EnumCreatedEffectObjects(LPDIENUMCREATEDEFFECTOBJECTSCALLBACK p0, LPVOID p1, DWORD p2)
{
	return m_pDIDevice->EnumCreatedEffectObjects(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::Escape(LPDIEFFESCAPE p0)
{
	return m_pDIDevice->Escape(p0);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::Poll()
{
	return m_pDIDevice->Poll();
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SendDeviceData(DWORD p0, LPCDIDEVICEOBJECTDATA p1, LPDWORD p2, DWORD p3)
{
	return m_pDIDevice->SendDeviceData(p0, p1, p2, p3);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::EnumEffectsInFile(LPCSTR p0, LPDIENUMEFFECTSINFILECALLBACK p1, LPVOID p2, DWORD p3)
{
	return m_pDIDevice->EnumEffectsInFile(p0, p1, p2, p3);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::WriteEffectToFile(LPCSTR p0, DWORD p2, LPDIFILEEFFECT p3, DWORD p4)
{
	return m_pDIDevice->WriteEffectToFile(p0, p2, p3, p4);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::BuildActionMap(LPDIACTIONFORMAT p0, LPCSTR p1, DWORD p2)
{
	return m_pDIDevice->BuildActionMap(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::SetActionMap(LPDIACTIONFORMAT p0, LPCSTR p1, DWORD p2)
{
	return m_pDIDevice->SetActionMap(p0, p1, p2);
}

HRESULT STDMETHODCALLTYPE IDirectInputDevice8Hook::GetImageInfo(LPDIDEVICEIMAGEINFOHEADER p0)
{
	return m_pDIDevice->GetImageInfo(p0);
}
