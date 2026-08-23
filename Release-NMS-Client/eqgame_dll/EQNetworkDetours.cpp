#include "EQUtils.h"
#include "EQDetours.h"
#include "MQ2Main.h"

 int __fastcall DetourPetWnd(CXWnd* thisptr)
 {
	 if((DWORD*)thisptr->pvfTable == (DWORD*)0x0065A0A8)
	 {
		 thisptr->Show(0,1);
		 return 0;
	 }
	
	 thisptr->Show(1,1);
	 return 0;
 }