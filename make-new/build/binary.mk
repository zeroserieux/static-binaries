# Common rules for sanity checks, fetching, extracting, etc.
include $(BUILD_SYSTEM)/common.mk

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

ifneq ($(LOCAL_OUTPUT_FILE),)
$(pf)_output_file := $($(pf)_build_dir)/$($(pf)_dir_name)/$(LOCAL_OUTPUT_FILE)
else
$(error No output file specified!)
endif

# ---------------------------------------------------------------
# Define Makefile rules

$($(pf)_build_dir):
	$(Q)mkdir -p $@

# Fetch source
$($(pf)_build_dir)/$($(pf)_file_name): | $($(pf)_build_dir)
	$(Q)$(call fetch_command)

# Unpack
$($(pf)_build_dir)/stamp-unpack: $($(pf)_build_dir)/$($(pf)_file_name) | $($(pf)_build_dir)
	$(Q)$(call extract_command)
	$(Q)if [ ! -d "$($(pf)_build_dir)/$($(pf)_dir_name)" ]; then \
			echo "Extract command did not create the expected directory: $($(pf)_build_dir)/$($(pf)_dir_name) - consider setting the LOCAL_EXTRACTED_NAME variable" ; \
			exit 1; \
		fi
	$(Q)touch $@

# Run configure
$($(pf)_build_dir)/stamp-configure: $($(pf)_build_dir)/stamp-unpack $(foreach dep,$(LOCAL_DEPENDENCIES),LIBRARY_$(dep)) | $($(pf)_build_dir)
	$(Q)cd $($(pf)_build_dir)/$($(pf)_dir_name) && $($(pf)_configure_command) $($(pf)_configure_flags)
	$(Q)touch $@

# Run build
$($(pf)_build_dir)/stamp-build: $($(pf)_build_dir)/stamp-configure | $($(pf)_build_dir)
	$(Q)cd $($(pf)_build_dir)/$($(pf)_dir_name) && $($(pf)_build_command)
	$(Q)if [ ! -f "$($(pf)_output_file)" ]; then \
			echo "Build command did not create the expected output file: $($(pf)_output_file) - please look at the value of LOCAL_OUTPUT_FILE" ; \
			exit 1; \
		fi
	$(Q)touch $@

# Strip the output
$($(pf)_build_dir)/stamp-strip: $($(pf)_build_dir)/stamp-build | $($(pf)_build_dir)
	$(Q)$(STRIP) $($(pf)_output_file)
	$(Q)touch $@

# The final build target and clean commands
.PHONY: BINARY_$(LOCAL_NAME)
BINARY_$(LOCAL_NAME): $($(pf)_build_dir)/stamp-strip

.PHONY: CLEAN_$(LOCAL_NAME)
CLEAN_$(LOCAL_NAME):
	$(Q)$(RM) -r $($(pf)_build_dir)

clean: CLEAN_$(LOCAL_NAME)
