#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------

$(eval __ExpectedUN := ${__TestSeg}.d3.td3)
$(call Mark-Step,Verify entry into ${__ExpectedUN})

$(call Info,${SegUN}:Path:$(call Last-Segment-Path))
$(call __Verify-Seg-Context,${__ExpectedUN})

$(call Test-Info,Using seg in same directory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,tm3,,Included as a test seg.)
$(call Verify-No-Error)
$(call Verify-No-Warning)

$(call Test-Info,\
  Using seg having same name as previously loaded from another directory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,tm2,,Included as a test.)
$(call Verify-No-Error)
$(call Verify-No-Warning)

$(call Test-Info,Using seg in subdirectory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,sd3/tsd3,,Included as a test.)
$(call Verify-No-Error)
$(call Verify-No-Warning)

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
