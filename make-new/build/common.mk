# ---------------------------------------------------------------
# Sanity checks

ifeq ($(LOCAL_NAME),)
$(error No name provided)
endif

ifeq ($(LOCAL_VERSION),)
$(error No version provided for: $(LOCAL_NAME))
endif

ifeq ($(LOCAL_SOURCE),)
$(error No source URL was provided for: $(LOCAL_NAME))
endif

# To get around the whole immediate/deferred expansion, we generate variables
# with this prefix.
pf := $(LOCAL_NAME)

# ---------------------------------------------------------------
# Set up output files

$(pf)_build_dir := $(OUT_DIR)/$(LOCAL_NAME)

# Try and discover the archive format from the source URL.
ifeq ($(LOCAL_SOURCE_FORMAT),)
$(pf)_source_name := $(shell basename "$(LOCAL_SOURCE)")

ifeq ($(call strendswith,$($(pf)_source_name),.tar.gz),true)
LOCAL_SOURCE_FORMAT := tar.gz
endif
ifeq ($(call strendswith,$($(pf)_source_name),.tgz),true)
LOCAL_SOURCE_FORMAT := tar.gz
endif
ifeq ($(call strendswith,$($(pf)_source_name),.tar.bz2),true)
LOCAL_SOURCE_FORMAT := tar.bz2
endif
ifeq ($(call strendswith,$($(pf)_source_name),.tar.xz),true)
LOCAL_SOURCE_FORMAT := tar.xz
endif
ifeq ($(call strendswith,$($(pf)_source_name),.zip),true)
LOCAL_SOURCE_FORMAT := zip
endif
ifeq ($(call strendswith,$($(pf)_source_name),.git),true)
LOCAL_SOURCE_FORMAT := git

# We also have some additional options!
ifeq ($(LOCAL_GIT_BRANCH),)
LOCAL_GIT_BRANCH := master
endif

endif
endif

# Generate an output file name for the source URL.
$(pf)_file_name := $(LOCAL_NAME)-$(LOCAL_VERSION).$(LOCAL_SOURCE_FORMAT)
$(pf)_fetched_file := $($(pf)_build_dir)/$($(pf)_file_name)

# Allow overriding the name inside the archive.
ifeq ($(LOCAL_EXTRACTED_NAME),)
$(pf)_dir_name := $(LOCAL_NAME)-$(LOCAL_VERSION)
else
$(pf)_dir_name := $(LOCAL_EXTRACTED_NAME)
endif

# Determine what program we use to fetch and extract the downloaded file.  We
# define a command that takes the input file as $(1) and extracts it inside
# the directory given in $(2).
$(pf)_fetch_command   := curl -sL -o $($(pf)_build_dir)/$($(pf)_file_name) $(LOCAL_SOURCE)
$(pf)_extract_command := false

ifeq ($(LOCAL_SOURCE_FORMAT),tar.gz)
#$(pf)_fetch_command := <default>
$(pf)_extract_command := tar -C $($(pf)_build_dir) -x -z -f $($(pf)_fetched_file)
else ifeq ($(LOCAL_SOURCE_FORMAT),tar.bz2)
#$(pf)_fetch_command := <default>
$(pf)_extract_command := tar -C $($(pf)_build_dir) -x -j -f $($(pf)_fetched_file)
else ifeq ($(LOCAL_SOURCE_FORMAT),tar.xz)
#$(pf)_fetch_command := <default>
$(pf)_extract_command := xz -dc $($(pf)_fetched_file) | tar -C $(2) xf -
else ifeq ($(LOCAL_SOURCE_FORMAT),zip)
#$(pf)_fetch_command := <default>
$(pf)_extract_command := unzip -d $($(pf)_build_dir) $($(pf)_fetched_file)
else ifeq ($(LOCAL_SOURCE_FORMAT),git)
$(pf)_fetch_command := cd $($(pf)_build_dir) && git clone -b $(LOCAL_GIT_BRANCH) $(LOCAL_SOURCE) $($(pf)_dir_name)
$(pf)_extract_command := true
else
$(error Unknown source format for: $(LOCAL_NAME))
endif

# Rule to create the build directory.
$($(pf)_build_dir):
	$(Q)mkdir -p $@

# Define rules that fetch this module and extracts it.
define my_fetch_template :=
$($(1)_build_dir)/$$($(1)_file_name): | $$($(1)_build_dir)
	$$(Q)$$(call $(1)_fetch_command)
endef
$(eval $(call my_fetch_template,$(pf)))

define my_extract_template :=
$$($(1)_build_dir)/stamp-unpack: $$($(1)_build_dir)/$$($(1)_file_name) | $$($(1)_build_dir)
	$$(Q)$$(call $(1)_extract_command)
	$$(Q)if [ ! -d "$$($(1)_build_dir)/$$($(1)_dir_name)" ]; then \
			echo "Extract command did not create the expected directory: $$($(1)_build_dir)/$$($(1)_dir_name) - consider setting the LOCAL_EXTRACTED_NAME variable" ; \
			exit 1; \
		fi
	$$(Q)touch $$@
endef
$(eval $(call my_extract_template,$(pf)))
