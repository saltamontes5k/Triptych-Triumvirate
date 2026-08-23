# =============================================================================
#  NMS-Server - convenience build wrapper for Linux / macOS (GNU make)
# =============================================================================
#
#  WHY THIS FILE EXISTS
#  --------------------
#  CMake does not build in place. It GENERATES a build system into a separate
#  directory first, and only then can you compile. A fresh clone therefore has
#  no makefile anywhere, so running `gmake clean` (or `gmake build`) from the
#  source root fails with the very unhelpful:
#
#      gmake: *** No rule to make target 'clean'.  Stop.
#
#  ...and deleting the build directory puts you right back into that state.
#  Every target below configures the build directory first when it is missing,
#  so `gmake`, `gmake build` and `gmake clean` all work from a clean checkout
#  with no manual CMake invocation and nothing to memorise.
#
#  WHY IT IS NAMED GNUmakefile AND NOT Makefile
#  --------------------------------------------
#   1. `Makefile` is listed in .gitignore (it is a CMake-generated artifact),
#      so a root Makefile would be silently ignored and never ship to anyone.
#   2. GNU make reads GNUmakefile BEFORE Makefile, so an accidental in-source
#      `cmake .` (which writes ./Makefile) cannot clobber or shadow this file.
#
#  WINDOWS
#  -------
#  Windows builds use build/EQEmu.sln with Visual Studio - see BUILD.md. This
#  wrapper refuses to run there on purpose: Windows filesystems are
#  case-insensitive, so `build/` and an existing `Build/` are the SAME folder,
#  and configuring over a Visual Studio cache would corrupt that setup.
#
#  USAGE
#  -----
#      gmake              # configure if needed, then build   (same as: gmake build)
#      gmake clean        # delete build outputs, KEEP the configuration
#      gmake distclean    # delete the whole build directory
#      gmake rebuild      # distclean + configure + build
#      gmake configure    # (re)generate the build system only
#      gmake submodules   # fetch/update the required git submodules
#      gmake help         # list targets and show the detected settings
#
#  OVERRIDES (all optional)
#  ------------------------
#      gmake BUILD_TYPE=Debug
#      gmake BUILD_DIR=build-debug
#      gmake CC=clang CXX=clang++
#      gmake JOBS=4
#      gmake GENERATOR="Unix Makefiles"
#      gmake EXTRA_CMAKE_ARGS="-DEQEMU_BUILD_TESTS=ON"
# =============================================================================

# --- Refuse to run on Windows (see header) -----------------------------------
ifeq ($(OS),Windows_NT)
$(error This wrapper is for Linux/macOS only. On Windows open build/EQEmu.sln in Visual Studio - see BUILD.md)
endif

# --- Settings ----------------------------------------------------------------
BUILD_DIR  ?= build
BUILD_TYPE ?= Release

# Compiler selection: DELIBERATELY NOT FORCED.
#
# By default this wrapper pins nothing and lets CMake choose. That is what makes
# it work on every toolchain - any gcc, any clang version, or a box that only
# has one of them - instead of hard-failing with "compiler not found" whenever
# a hard-coded name is missing.
#
# CMake's own search order already does the sensible thing: for C it tries
# cc, gcc, ... clang; for C++ it tries c++, g++, ... clang++. On Debian-family
# images cc/c++ normally point at gcc, so gcc wins automatically when present
# and clang is used when it does not.
#
# To force a specific toolchain, pass it explicitly - both are honoured:
#     gmake CC=gcc CXX=g++
#     gmake CC=clang-15 CXX=clang++-15
#
# Detection below is for the `help` banner and diagnostics only; it never
# overrides anything.
GCC_FOUND   := $(shell command -v gcc   >/dev/null 2>&1 && echo yes)
CLANG_FOUND := $(shell command -v clang >/dev/null 2>&1 && echo yes)
CC_VERSION  := $(shell $(if $(filter default,$(origin CC)),cc,$(CC))   --version 2>/dev/null | head -1)
CXX_VERSION := $(shell $(if $(filter default,$(origin CXX)),c++,$(CXX)) --version 2>/dev/null | head -1)

# Only pass -DCMAKE_*_COMPILER when the user explicitly set CC/CXX. `origin`
# distinguishes a real user value from make's own built-in default (CC=cc),
# which must never be forwarded as if it were a choice.
COMPILER_ARGS :=
ifneq ($(filter-out default undefined,$(origin CC)),)
COMPILER_ARGS += -DCMAKE_C_COMPILER=$(CC)
endif
ifneq ($(filter-out default undefined,$(origin CXX)),)
COMPILER_ARGS += -DCMAKE_CXX_COMPILER=$(CXX)
endif

# Parallelism: nproc (Linux), sysctl (macOS), else a safe fallback.
JOBS ?= $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Prefer Ninja when present (far faster incremental builds, especially with
# ccache); fall back to Unix Makefiles so this works on a bare box too.
ifeq ($(shell command -v ninja >/dev/null 2>&1 && echo yes),yes)
GENERATOR ?= Ninja
else
GENERATOR ?= Unix Makefiles
endif

# Use ccache only if it is actually installed.
ifeq ($(shell command -v ccache >/dev/null 2>&1 && echo yes),yes)
LAUNCHER := -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
endif

# CMakeCache.txt is the marker that the build directory is configured. Making it
# a real file prerequisite is what lets every target auto-configure exactly once.
CACHE := $(BUILD_DIR)/CMakeCache.txt

CMAKE_ARGS := -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
              $(COMPILER_ARGS) \
              -DEQEMU_BUILD_LOGIN=ON \
              $(LAUNCHER) \
              $(EXTRA_CMAKE_ARGS)

.PHONY: all build configure clean distclean rebuild submodules help
.DEFAULT_GOAL := build

all: build

# --- Configure ---------------------------------------------------------------
# Submodules: a plain `git clone` (without --recursive) leaves fmt/glm/libuv/
# cereal/websocketpp/recastnavigation empty, and the build then fails with
# confusing missing-header errors rather than anything obvious. So fetch them -
# but ONLY when this tree actually is a git checkout. Source that arrived as a
# zip/copy has no .git (git exits 128: "not a git repository"), so there we
# just verify the submodule sources are already present and continue.
$(CACHE):
	@echo "==> Configuring: $(GENERATOR) | $(BUILD_TYPE)"
	@echo "==> Compiler:   $(if $(CXX_VERSION),$(CXX_VERSION),chosen by cmake)"
	@fetched=no; \
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
		if git submodule update --init --recursive 2>/dev/null; then fetched=yes; fi; \
	fi; \
	if [ "$$fetched" = yes ]; then \
		:; \
	elif [ -f submodules/fmt/CMakeLists.txt ] && [ -f submodules/glm/CMakeLists.txt ]; then \
		echo "==> Submodule sources present - continuing"; \
	else \
		echo ""; \
		echo "ERROR: submodules/ is empty and this is not a git checkout, so it cannot"; \
		echo "       be fetched automatically. GitHub zip downloads do NOT include"; \
		echo "       submodules. Either clone properly:"; \
		echo "           git clone --recursive <repo-url>"; \
		echo "       or copy the submodules/ folder from a machine that has it."; \
		echo ""; \
		exit 1; \
	fi
	@mkdir -p "$(BUILD_DIR)"
	@cd "$(BUILD_DIR)" && cmake -G "$(GENERATOR)" $(CMAKE_ARGS) ..
	@echo "==> Configured in $(BUILD_DIR)/"

configure: $(CACHE)

# --- Build -------------------------------------------------------------------
# `cmake --build` is generator-agnostic: it drives Ninja or Make transparently,
# so this target keeps working if GENERATOR changes.
build: $(CACHE)
	@echo "==> Building with $(JOBS) jobs"
	@cmake --build "$(BUILD_DIR)" --config $(BUILD_TYPE) -j $(JOBS)
	@echo "==> Build complete -> $(BUILD_DIR)/bin"

# --- Clean -------------------------------------------------------------------
# Must NEVER fail when the build directory is absent - that failure mode is the
# whole reason this file exists.
clean:
	@if [ -f "$(CACHE)" ]; then \
		echo "==> Cleaning build outputs in $(BUILD_DIR)/"; \
		cmake --build "$(BUILD_DIR)" --target clean; \
	else \
		echo "==> Nothing to clean ($(BUILD_DIR)/ is not configured)"; \
	fi

distclean:
	@rm -rf "$(BUILD_DIR)"
	@echo "==> Removed $(BUILD_DIR)/ (next build will reconfigure)"

# Sequential on purpose: distclean and build must not run concurrently under -j.
rebuild:
	@$(MAKE) distclean
	@$(MAKE) build

submodules:
	@git submodule update --init --recursive

help:
	@echo ""
	@echo "NMS-Server build wrapper (Linux/macOS)"
	@echo ""
	@echo "  gmake              configure if needed, then build"
	@echo "  gmake clean        delete build outputs, keep configuration"
	@echo "  gmake distclean    delete the whole build directory"
	@echo "  gmake rebuild      distclean + configure + build"
	@echo "  gmake configure    (re)generate the build system only"
	@echo "  gmake submodules   fetch/update git submodules"
	@echo ""
	@echo "Detected settings:"
	@echo "  BUILD_DIR   = $(BUILD_DIR)"
	@echo "  BUILD_TYPE  = $(BUILD_TYPE)"
	@echo "  GENERATOR   = $(GENERATOR)"
	@echo "  compiler    = $(if $(COMPILER_ARGS),$(CXX) (forced),auto-selected by cmake)"
	@echo "  C compiler  = $(if $(CC_VERSION),$(CC_VERSION),not detected)"
	@echo "  C++ compiler= $(if $(CXX_VERSION),$(CXX_VERSION),not detected)"
	@echo "  gcc present = $(if $(GCC_FOUND),yes,no)"
	@echo "  clang presnt= $(if $(CLANG_FOUND),yes,no)"
	@echo "  JOBS        = $(JOBS)"
	@echo "  ccache      = $(if $(LAUNCHER),yes,no)"
	@echo ""
	@echo "Override any of them, e.g.:  gmake BUILD_TYPE=Debug JOBS=4"
	@echo ""
