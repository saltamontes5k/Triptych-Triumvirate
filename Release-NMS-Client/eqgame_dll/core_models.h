#pragma once

#include "MQ2Main.h"

struct NPCEntry {
    explicit NPCEntry(int raceID, int genderID, const char* modelName, int raceMask, int dbStrID) : raceID(raceID), genderID(genderID), modelName(modelName), raceMask(raceMask), dbStrID(dbStrID) {};
    int raceID;
    int genderID;
    const char* modelName;			
    int raceMask;
    int dbStrID;
};

struct ZoneEntry {
    explicit ZoneEntry(int zoneType, int zoneID, char* zoneShortName, char* zoneLongName, int eqStrID, int zoneFlags2, int x, int y, int z) : zoneType(zoneType), zoneID(zoneID), zoneShortName(zoneShortName), zoneLongName(zoneLongName), eqStrID(eqStrID), zoneFlags2(zoneFlags2), x(x), y(y), z(z) {};
    int zoneType;
    int zoneID;
    char* zoneShortName;
    char* zoneLongName;
    int eqStrID;
    int zoneFlags2;
    int x;
    int y;
    int z;
};

struct AnimationEntry {
    explicit AnimationEntry(char* originalName, char* replacementName) : originalName(originalName), replacementName(replacementName) {};
    char* originalName;
    char* replacementName;
};