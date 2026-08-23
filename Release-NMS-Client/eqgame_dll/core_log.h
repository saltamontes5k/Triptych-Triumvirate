#pragma once

// Diagnostic file logging is removed for release builds. SimpleLog is kept as a
// no-op so existing call sites compile; nothing is ever written to disk.
inline void SimpleLog(const char*, ...) {}
