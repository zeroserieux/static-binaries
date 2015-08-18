# Always use bash, not whatever is installed as /bin/sh
SHELL := /bin/bash

# Disable built-in suffix rules.
.SUFFIXES:

# Turn off the RCS / SCCS implicit rules of GNU Make
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%

# If a rule fails, delete $@.
.DELETE_ON_ERROR:

# Absolute path of the present working direcotry.
# This overrides the shell variable $PWD, which does not necessarily point to
# the top of the source tree, for example when "make -C" is used.
PWD := $(shell pwd)

# This is the default target.  It must be the first declared target.
.PHONY: all
DEFAULT_GOAL := all
$(DEFAULT_GOAL):

# The path to the directory containing our build system's Makefiles.
BUILD_SYSTEM := $(PWD)/build

# Allow showing commands
Q ?= @

# Helper rule to print variables.
%. :
	@echo '$($*)'

# Configuration
include $(BUILD_SYSTEM)/config.mk
include $(BUILD_SYSTEM)/util.mk
