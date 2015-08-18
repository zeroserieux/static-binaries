# Pull in build system
include build/main.mk

# Configuration
LIBRARIES := pcre zlib
BINARIES  := pv

# Finally, include sub-makefiles.
include $(patsubst %, $(TOPDIR)%/module.mk, $(LIBRARIES))
include $(patsubst %, $(TOPDIR)%/module.mk, $(BINARIES))

# Finally, clear all variables.
include $(BUILD_SYSTEM)/clear_vars.mk
