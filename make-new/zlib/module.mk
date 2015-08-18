include $(BUILD_SYSTEM)/clear_vars.mk

LOCAL_NAME         := zlib
LOCAL_VERSION      := 1.2.8
LOCAL_SOURCE       := http://zlib.net/zlib-$(LOCAL_VERSION).tar.gz
LOCAL_INCLUDE_DIRS := .
LOCAL_LIB_DIRS     := .
LOCAL_LINK_FLAG    := -lz

# Zlib has a very basic build system - we override it manually.
LOCAL_CONFIGURE_COMMAND := 		\
	CHOST=$(CROSS_PREFIX)		\
	CC='$(CC) $(STATIC_FLAG)'	\
	CFLAGS='-fPIC' 				\
	./configure 				\
		--static

include $(BUILD_SYSTEM)/static_library.mk
