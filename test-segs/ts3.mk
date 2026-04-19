#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,For test only.)
# -----

$(call Info,${SegUN}:Path:$(call Last-Segment-Path))
$(call Verify-Seg-Attributes,test-segs.ts3)

$(call Test-Info,Recursive call to Use-Segment.)
$(call Expect-Message,Recursive call to macro Use-Segment detected.)
$(call Expect-No-Warning)
$(call Expect-No-Error)
$(call Use-Segment,ts4,)
$(call Verify-No-Error)
$(call Verify-No-Warning)
$(call Verify-Message)

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
