#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# +++++
# Optional wrapper to avoid initializing twice.
ifndef ${SegUN}.Initialized
${SegUN}.Initialized := 1
# -----

_macro := ${SegUN}.init
$.define _help
${_macro}
  Run the initialization for the segment. This is designed to be called some time after the segment has been loaded. This is useful when this segment uses variables from other segments which haven't been loaded.
$.endef
$.define ${_macro}
$(call Enter-Macro,$(0),Seg=$(1))
$(call Info,Initializing $(1).)
$(call Exit-Macro)
$.endef

$$(call Info,New segment: Add variables, macros, goals, and recipes here.)

<segment body here>

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
Make segment: ${Seg}.mk

<make segment help messages>

Command line goals:
  help-${SegUN}   Display this help.
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # Seg exists
$(call Info: ${SegUN} already initialized.)
endif # SegUN
# -----
