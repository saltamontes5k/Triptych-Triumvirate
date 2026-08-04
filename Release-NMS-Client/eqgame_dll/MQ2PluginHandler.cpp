#include "MQ2Main.h"

CRITICAL_SECTION gPluginCS;
BOOL bPluginCS = 0;

VOID WriteChatColor(PCHAR Line, DWORD Color, DWORD Filter)
{
   //if (gFilterMQ) return;
   //CHAR PlainText[MAX_STRING] = {0};
   //StripMQChat(Line, PlainText);
   //CheckChatForEvent(PlainText);
   dsp_chat_no_events(Line, Color, false);
}
