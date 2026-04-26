#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------

$(eval __ExpectedUN := ${__TestSeg}.tsd2)
$(call Mark-Step,Verify entry into ${__ExpectedUN})

$(call Info,${SegUN}:Path:$(call Last-Segment-Path))
$(call __Verify-Seg-Context,${__ExpectedUN})

# +++++
# Postamble
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

This segment is in the helpers directory and is intended for test only.

Command line goals:
  help-${SegUN}   Display this help.
endef
${__h} := ${__help}
endif
