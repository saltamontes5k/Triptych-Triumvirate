/*****************************************************************************
MQ2Main.dll: MacroQuest2's extension DLL for EverQuest
Copyright (C) 2002-2003 Plazmic, 2003-2005 Lax

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License, version 2, as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
******************************************************************************/

#if !defined(CINTERFACE)
#endif
#ifndef ISXEQ

#define DBG_SPEW

#ifdef ISXEQ_LEGACY
#include "../ISXEQLegacy/ISXEQLegacy.h"
#else
#include "MQ2Main.h"
#endif

/* VAR SYSTEM INDEPENDENT */
// in-place cleanup of tabs, leading/trailing space
VOID CleanMacroLine(PCHAR szLine)
{
    if (!szLine || szLine[0]==0)
        return;
    PCHAR pChar=szLine;
    while(pChar[0])
    {
        if (pChar[0]=='\t' || pChar[0]==0x0a || pChar[0]==0x0d)
            pChar[0]=' ';
        ++pChar;
    }
    // find beginning and end
    PCHAR pStart=szLine;
    unsigned long Length=strlen(szLine);
    PCHAR pEnd=&szLine[Length-1];

    while(*pStart==' ')
        ++pStart;
    while(*pEnd==' ')
        --pEnd;
    if (!*pStart || !*pEnd)
    {
        szLine[0]=0;
        return;
    }
    // keep only this part.
    unsigned long NewLength=1+pEnd-pStart;
    if (NewLength==Length)
        return;//nothing to do
    memmove(szLine,pStart,NewLength);
    szLine[NewLength]=0;
}

// ***************************************************************************
// Function:    Include
// Description: Includes another macro file
// Usage:       #include <filename>
// ***************************************************************************
DWORD Include(PCHAR szFile)
{
	return 0;
}

// ***************************************************************************
// Function:    AddMacroLine
// Description: Add a line to the MacroBlock
// ***************************************************************************
PMACROBLOCK AddMacroLine(PCHAR szLine)
{
	return NULL;
}


// ***************************************************************************
// Function:    Macro
// Description: Our '/macro' command
// Usage:       /macro <filename>
// ***************************************************************************
VOID Macro(PSPAWNINFO pChar, PCHAR szLine)
{
   
}

// ***************************************************************************
// Function:    Cleanup
// Description: Our '/cleanup' command
//              Sends i, esc, esc, esc, esc, i
// Usage:       /cleanup
// ***************************************************************************
VOID Cleanup(PSPAWNINFO pChar, PCHAR szLine)
{
}

// ***************************************************************************
// Function:    Delay
// Description: Our '/delay' command
// Usage:       /delay <time> [condition to end early]
// ***************************************************************************
VOID Delay(PSPAWNINFO pChar, PCHAR szLine)
{
    CHAR szVal[MAX_STRING] = {0};
    LONG VarValue;

    if (szLine[0]==0) {
        SyntaxError("Usage: /delay <time> [condition to end early]");
        return;
    }
    GetArg(szVal,szLine,1);
    ParseMacroParameter(GetCharInfo()->pSpawn,szVal);
    strcpy(gDelayCondition,GetNextArg(szLine));
    VarValue = atol(szVal);
    switch (szVal[strlen(szVal)-1]) {
        case 'm':
        case 'M':
            VarValue *= 60;
        case 's':
        case 'S':
            VarValue *= 10;
    }
    gDelay = VarValue;
    bRunNextCommand=false;
    //    DebugSpewNoFile("Delay - %d",gDelay);
}

/* MQ2DataVars */
VOID Goto(PSPAWNINFO pChar, PCHAR szLine)
{
    CHAR szTemp[MAX_STRING] = {0};
    PMACROBLOCK pFromLine = gMacroBlock;
    bRunNextCommand = TRUE;
    if (!gMacroBlock) {
        MacroError("Cannot goto when a macro isn't running.");
        return;
    }
    while (gMacroBlock->pPrev) 
    {
        gMacroBlock=gMacroBlock->pPrev;
        if (!strnicmp(gMacroBlock->Line,"Sub ",4)) break;
    }

    while (gMacroBlock->pNext) 
    {
        gMacroBlock=gMacroBlock->pNext;
        if (!strnicmp(gMacroBlock->Line,"Sub ",4)) 
        {
            gMacroBlock=pFromLine;
            FatalError("Couldn't find label %s",szLine);
            return;
        }
        if (!stricmp(szLine,gMacroBlock->Line)) 
        {
            //            DebugSpewNoFile("Goto - went to label %s",szLine);
            return;
        }
    }

    if (!stricmp(szLine,gMacroBlock->Line)) 
    {
        //        DebugSpewNoFile("Goto - went to label %s",szLine);
        return;
    }
    gMacroBlock=pFromLine;
    FatalError("Couldn't find label %s",szLine);
}



VOID DumpStack(PSPAWNINFO pChar, PCHAR szLine)
{
    CHAR szTemp[MAX_STRING] = {0};
    CHAR szSub[MAX_STRING] = {0};
    PMACROSTACK pMS = gMacroStack;
    while (pMS!=NULL) {
        sprintf(szTemp,"%s@%d (%s): %s",pMS->Location->SourceFile,pMS->Location->LineNumber, GetSubFromLine(pMS->Location,szSub), pMS->Location->Line);
        WriteChatColor(szTemp,USERCOLOR_DEFAULT);
        if (bAllErrorsLog) MacroLog(NULL, szTemp);
        pMS=pMS->pNext;
    }
}

// ***************************************************************************
// Function:    EndMacro
// Description: Our '/endmacro' command
// Usage:       /endmacro
// ***************************************************************************
VOID EndMacro(PSPAWNINFO pChar, PCHAR szLine)
{
}


// ***************************************************************************
// Function:    Call
// Description: Our '/call' command
// Usage:       /call <Subroutine>
// ***************************************************************************
VOID Call(PSPAWNINFO pChar, PCHAR szLine)
{
 
} 

/*
VOID Call(PSPAWNINFO pChar, PCHAR szLine)
{
    PMACROSTACK pStack;
    PMACROBLOCK pCallingPoint = gMacroBlock;
    CHAR SubName[MAX_STRING] = {0};
    PCHAR SubParam = NULL;
    CHAR SubLine[MAX_STRING] = {0};
    CHAR SubLineP[MAX_STRING] = {0};
    DWORD StackNum = 0;
    bRunNextCommand = TRUE;
    if (szLine[0]==0) {
        SyntaxError("Usage: /call <subroutine> [param [param...]]");
        return;
    }
    if (!gMacroBlock) {
        MacroError("Cannot call when a macro isn't running.");
        return;
    }
    while (gMacroBlock->pPrev) gMacroBlock = gMacroBlock->pPrev;

    GetArg(SubName,szLine,1);
    SubParam = GetNextArg(szLine);

    sprintf(SubLine,"sub %s",SubName);
    sprintf(SubLineP,"sub %s(",SubName);
    while (gMacroBlock->pNext) {
        if (!stricmp(gMacroBlock->Line,SubLine) || !strnicmp(gMacroBlock->Line,SubLineP,strlen(SubLineP))) {
            DebugSpewNoFile("Call - Calling subroutine %s with params %s",SubName,SubParam);
            pStack = (PMACROSTACK)malloc(sizeof(MACROSTACK));
            pStack->Location = gMacroBlock;
            pStack->Return[0] = 0;
            pStack->Parameters = NULL;
            pStack->LocalVariables = NULL;
            pStack->pNext = gMacroStack;
            gMacroStack = pStack;
            if (SubParam) 
            {
                StackNum = 0;
                while (SubParam[0]!=0) 
                {
                    CHAR szParamName[MAX_STRING] = {0};
                    CHAR szParamType[MAX_STRING] = {0};
                    CHAR szNewValue[MAX_STRING]={0};
                    GetArg(szNewValue,SubParam,1);


                    GetFuncParam(gMacroBlock->Line,StackNum,szParamName,szParamType);
                    MQ2Type *pType = FindMQ2DataType(szParamType);
                    if (!pType)
                        pType=pStringType;

                    AddMQ2DataVariable(szParamName,"",pType,&gMacroStack->Parameters,szNewValue);
                    SubParam = GetNextArg(SubParam);
                    StackNum++;
                }
            }
            return;
        }
        gMacroBlock = gMacroBlock->pNext;
    }
    gMacroBlock=pCallingPoint;
    FatalError("Subroutine %s wasn't found",SubName);
}
/**/

VOID FailIf(PSPAWNINFO pChar, PCHAR szCommand, PMACROBLOCK pStartLine, BOOL All)
{
 
}

VOID NewIf(PSPAWNINFO pChar, PCHAR szLine)
{
}




// ***************************************************************************
// Function:    DoEvents
// Description: Our '/doevents' command
// Usage:       /doevents [flush] [custom event]
// ***************************************************************************
VOID DoEvents(PSPAWNINFO pChar, PCHAR szLine)
{
   
}


// ***************************************************************************
// Function:    Return
// Description: Our '/return' command
// Usage:       /return [value]
// ***************************************************************************
VOID Return(PSPAWNINFO pChar, PCHAR szLine)
{
   

}





// ***************************************************************************
// Function:    For
// Description: Our '/for' command
// Usage:       /for v# <start> <to|downto> <end>
// ***************************************************************************
VOID For(PSPAWNINFO pChar, PCHAR szLine)
{
  

}

// ***************************************************************************
// Function:    Next
// Description: Our '/next' command
// Usage:       /next v#
// ***************************************************************************
VOID Next(PSPAWNINFO pChar, PCHAR szLine)
{
  
}


PCHAR GetFuncParam(PCHAR szMacroLine, DWORD ParamNum, PCHAR szParamName, PCHAR szParamType)
{
	return nullptr;
}

#endif
