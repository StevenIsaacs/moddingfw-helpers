#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,For test only.)
# -----

$(call Test-Info,Path:$(call Last-Segment-Path))
$(call Verify-Seg-Context,d3.td3)

$(call Test-Info,Using seg in same directory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,tm3)
$(call Verify-No-Error)
$(call Verify-No-Warning)

$(call Test-Info,\
  Using seg having same name as previously loaded from another directory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,tm2)
$(call Verify-No-Error)
$(call Verify-No-Warning)

$(call Test-Info,Using seg in subdirectory.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,sd3/tsd3)
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
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegID
# -----
