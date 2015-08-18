include $(BUILD_SYSTEM)/clear_vars.mk

LOCAL_NAME    :=      pcre
LOCAL_VERSION :=      8.37
LOCAL_SOURCE  :=      ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$(LOCAL_VERSION).tar.gz
LOCAL_INCLUDE_DIRS := .
LOCAL_LIB_DIRS :=     .libs

include $(BUILD_SYSTEM)/static_library.mk
