// nms_vorbis.h -- declarations for the bundled stb_vorbis (public domain, v1.22).
//
// The LoN client ships its soundtrack as Ogg Vorbis inside sounds.rcc, and Windows has
// no Ogg codec. stb_vorbis is a single public-domain source file, so shipping the
// decoder costs us nothing while the music itself stays where it belongs -- in the
// player's own client.
//
// nms_lon_audio.cpp includes this for the declarations; nms_vorbis.c compiles the
// implementation as C (the project forces C++ everywhere else, which would give the
// definitions C++ linkage and break the extern "C" prototypes below).
#pragma once

// We only use the in-memory pull API; drop the stdio and pushdata halves.
#ifndef STB_VORBIS_NO_STDIO
#define STB_VORBIS_NO_STDIO
#endif
#ifndef STB_VORBIS_NO_PUSHDATA_API
#define STB_VORBIS_NO_PUSHDATA_API
#endif

#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"
#undef STB_VORBIS_HEADER_ONLY
