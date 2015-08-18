include $(BUILD_SYSTEM)/clear_vars.mk

LOCAL_NAME    :=     pv
LOCAL_VERSION :=     1.6.0
LOCAL_SOURCE  :=     https://www.ivarch.com/programs/sources/pv-$(LOCAL_VERSION).tar.bz2
LOCAL_OUTPUT_FILE := pv

include $(BUILD_SYSTEM)/binary.mk

# Add an additional dependency for the build.
$(my_build_dir)/stamp-build: $(my_build_dir)/stamp-patch | $(my_build_dir)

# Add the patch command.
$(my_build_dir)/stamp-patch: $(my_build_dir)/stamp-configure | $(my_build_dir)
	$(Q)cd $(my_build_dir)/$(my_dir_name) && sed -i '/^CC =/a LD = arm-linux-musleabihf-ld' Makefile
	$(Q)touch $@
