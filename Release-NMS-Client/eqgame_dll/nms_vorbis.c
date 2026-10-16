// nms_vorbis.c -- implementation translation unit for the bundled stb_vorbis.
//
// Built as C (CompileAs=CompileAsC in eqgame_dll.vcxproj): stb_vorbis is C and its
// prototypes are extern "C", so compiling it as C++ would leave the definitions with
// C++ linkage and fail to link.
#include "nms_vorbis.h"   // the STB_VORBIS_* switches, then the header half
#include "stb_vorbis.c"   // the implementation (STB_VORBIS_HEADER_ONLY is undefined)
