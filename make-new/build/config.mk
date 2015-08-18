# ---------------------------------------------------------------
# Utility variables

empty :=
space := $(empty) $(empty)
comma := ,

# Note: make removes the newline immediately prior to `endef`
define newline


endef

backslash := \a
backslash := $(patsubst %a,%,$(backslash))

# ---------------------------------------------------------------
# Set up configuration for the host machine.
UNAME := $(shell uname -sm)

ifneq (,$(findstring Linux,$(UNAME)))
  HOST_OS := linux
endif
ifneq (,$(findstring Darwin,$(UNAME)))
  HOST_OS := darwin
endif
ifneq (,$(findstring Macintosh,$(UNAME)))
  HOST_OS := darwin
endif
ifneq (,$(findstring CYGWIN,$(UNAME)))
  HOST_OS := windows
endif

ifeq ($(HOST_OS),)
$(error Unable to determine HOST_OS from uname -sm: $(UNAME)!)
endif

ifneq (,$(findstring x86_64,$(UNAME)))
  HOST_ARCH := x86_64
else
ifneq (,$(findstring x86,$(UNAME)))
$(error Building on a 32-bit x86 host is not supported: $(UNAME)!)
endif
endif

ifeq ($(HOST_ARCH),)
$(error Unable to determine HOST_ARCH from uname -sm: $(UNAME)!)
endif


# ---------------------------------------------------------------
# Figure out the output directory
ifeq (,$(strip $(OUT_DIR)))
OUT_DIR := $(PWD)/out
endif

# ---------------------------------------------------------------
# Set up cross compilers.

ifeq "$(PLATFORM)" "linux"
	ifeq "$(ARCH)" "x86"
		CROSS_PREFIX := $(error Currently, static x86 is not supported)
	else ifeq "$(ARCH)" "amd64"
		CROSS_PREFIX := x86_64-linux-musl
	else
		CROSS_PREFIX := $(error No valid architecture provided: $(ARCH))
	endif
else ifeq "$(PLATFORM)" "android"
	CROSS_PREFIX := arm-linux-musleabihf
else ifeq "$(PLATFORM)" "darwin"
	CROSS_PREFIX := x86_64-apple-darwin$(DARWIN_VERSION)
else ifeq "$(PLATFORM)" "windows"
	CROSS_PREFIX := $(error Currently, cross-compiling to Windows is not supported)
else
	CROSS_PREFIX := $(error No valid platform provided: $(PLATFORM))
endif

# Compiler configuration
AR           := $(CROSS_PREFIX)-ar
CC           := $(CROSS_PREFIX)-gcc
CXX          := $(CROSS_PREFIX)-g++
LD           := $(CROSS_PREFIX)-ld
RANLIB       := $(CROSS_PREFIX)-ranlib
STRIP        := $(CROSS_PREFIX)-strip

# Special override for Darwin/osxcross - use clang
ifeq "$(PLATFORM)" "darwin"
	CC  := $(CROSS_PREFIX)-clang
	CXX := $(CROSS_PREFIX)-clang++

	# Disable irritating warning.
	export OSXCROSS_NO_INCLUDE_PATH_WARNINGS := 1
endif

# Flag for compiling statically - not true on Darwin
ifeq "$(PLATFORM)" "darwin"
	STATIC_FLAG := -flto -O3 -mmacosx-version-min=10.6
else
	STATIC_FLAG := -static
endif
