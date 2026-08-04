#include "StdAfx.h"

#define GREEN 2
#define RED 4
#define DARKGREY 8
#define LIGHTCYAN 11
#define YELLOW 14
#define WHITE 15

bool isLogging = false;

void setColor(unsigned int color)
{
   HANDLE screen = GetStdHandle(STD_OUTPUT_HANDLE);
   SetConsoleTextAttribute(screen, color);
}

void Log_Clear()
{
	FILE *file; 
	file = fopen("hook.log", "w");
	fprintf(file, "\0");
}

void Logger(unsigned int lvl, char* caller, char* logline, ...)
{
	while(isLogging) Sleep(10);
	isLogging = true;
	FILE *file; 
	file = fopen("hook.log","a+");
	char timeStr[9];
	char logOut[1024];
	_strtime( timeStr );
	setColor(DARKGREY);
	printf("[%s] ", timeStr);
	fprintf(file, "[%s] ", timeStr);
	setColor(LIGHTCYAN);
	printf("%s: ", caller);
	fprintf(file, "%s: ", caller);
	if ( lvl == lINFO ) setColor(WHITE);
	else if ( lvl == lWARN ) setColor(YELLOW);
	else if ( lvl == lERROR ) setColor(RED);
	else if ( lvl == lDEBUG ) setColor(GREEN);
	va_list argList;
	va_start(argList, logline);
	vsnprintf(logOut, 1024, logline, argList);
	va_end(argList);
	printf("%s\n", logOut);
	fprintf(file, "%s\n", logOut);
	fclose(file);
	isLogging = false;
}