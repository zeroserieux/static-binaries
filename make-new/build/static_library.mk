# Common rules for sanity checks, fetching, extracting, etc.
include $(BUILD_SYSTEM)/common.mk

ifeq ($(LOCAL_INCLUDE_DIRS),)
$(error No value given for LOCAL_INCLUDE_DIRS)
endif

ifeq ($(LOCAL_LIB_DIRS),)
$(error No value given for LOCAL_LIB_DIRS)
endif

$(pf)_configure_flags := $(LOCAL_CONFIGURE_FLAGS)

ifeq ($(LOCAL_CONFIGURE_COMMAND),)
LOCAL_CONFIGURE_COMMAND := \
	AR=$(AR) \
	CC=$(CC) \
	CXX=$(CXX) \
	LD=$(LD) \
	RANLIB=$(RANLIB) \
	STRIP=$(STRIP) \
	CPPFLAGS="$(foreach dep,$(LOCAL_DEPENDENCIES),$(LIBRARY_$(dep)_INCLUDES))" \
	LDFLAGS="$(foreach dep,$(LOCAL_DEPENDENCIES),$(LIBRARY_$(dep)_LIBDIRS))" \
	CFLAGS="$(STATIC_FLAG)" \
	CXXFLAGS="$(STATIC_FLAG)" \
	./configure \
		--host=$(CROSS_PREFIX)	\
		--build=i686
endif
$(pf)_configure_command := $(LOCAL_CONFIGURE_COMMAND)

ifeq ($(LOCAL_BUILD_COMMAND),)
LOCAL_BUILD_COMMAND := make
endif
$(pf)_build_command := $(LOCAL_BUILD_COMMAND)

ifeq ($(LOCAL_LINK_FLAG),)
LOCAL_LINK_FLAG := -l$(LOCAL_NAME)
endif
$(pf)_link_flag := $(LOCAL_LINK_FLAG)

# ---------------------------------------------------------------
# Define Makefile rules

# Run configure
$($(pf)_build_dir)/stamp-configure: $($(pf)_build_dir)/stamp-unpack $(foreach dep,$(LOCAL_DEPENDENCIES),LIBRARY_$(dep)) | $($(pf)_build_dir)
	$(Q)cd $($(pf)_build_dir)/$($(pf)_dir_name) && $($(pf)_configure_command) $($(pf)_configure_flags)
	$(Q)touch $@

# Run build
$($(pf)_build_dir)/stamp-build: $($(pf)_build_dir)/stamp-configure | $($(pf)_build_dir)
	$(Q)cd $($(pf)_build_dir)/$($(pf)_dir_name) && $($(pf)_build_command)
	$(Q)touch $@

# The final build target and clean command
.PHONY: LIBRARY_$(LOCAL_NAME)
LIBRARY_$(LOCAL_NAME): $($(pf)_build_dir)/stamp-build

.PHONY: CLEAN_$(LOCAL_NAME)
CLEAN_$(LOCAL_NAME):
	$(Q)$(RM) -r $($(pf)_build_dir)

clean: CLEAN_$(LOCAL_NAME)

# Create variables that contain the include and library path(s)
LIBRARY_$(LOCAL_NAME)_INCLUDES := $(foreach dd,$(LOCAL_INCLUDE_DIRS),-I$($(pf)_build_dir)/$($(pf)_dir_name)/$(dd))
LIBRARY_$(LOCAL_NAME)_LIBDIRS := $(foreach dd,$(LOCAL_LIB_DIRS),-L$($(pf)_build_dir)/$($(pf)_dir_name)/$(dd))
LIBRARY_$(LOCAL_NAME)_LINK := $(LOCAL_LINK_FLAG)
