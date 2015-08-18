# Common build system definitions.  Mostly helpful shortcuts or
# functions, since we don't actually compile code here.

###########################################################
## Returns true if $(1) and $(2) are equal.  Returns
## the empty string if they are not equal.
###########################################################

define streq
$(strip $(if $(strip $(1)),\
  $(if $(strip $(2)),\
    $(if $(filter-out __,_$(subst $(strip $(1)),,$(strip $(2)))$(subst $(strip $(2)),,$(strip $(1)))_),,true), \
    ),\
  $(if $(strip $(2)),\
    ,\
    true)\
 ))
endef

###########################################################
## Returns true if $(1) ends with $(2).  Returns the empty
## string if they are not equal.
###########################################################

define strendswith
$(strip $(shell [[ "$(1)" == *$(2) ]] && echo true))
endef

###########################################################
## Function we can evaluate to introduce a dynamic dependency
###########################################################

define add-dependency
$(1): $(2)
endef
