#include "EQUtils.h"

void PatchBytes( void * lpAddress, const char * szBytes, int nLen )
{
	// Needed by VirtualProtect.
	DWORD dwBack = 0;
	VirtualProtect( lpAddress, nLen, PAGE_READWRITE, &dwBack );

	// Write Byte-After-Byte.
	for( int i = 0; i < nLen; i++ )
		*( BYTE * )( ( DWORD )lpAddress + i ) = szBytes[ i ];

	// Restore old protection.
	VirtualProtect( lpAddress, nLen, dwBack, &dwBack );
}
