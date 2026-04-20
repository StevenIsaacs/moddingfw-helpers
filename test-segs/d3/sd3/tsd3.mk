#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# For test only.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,For test only.)
# -----

$(call Test-Info,Path:$(call Last-Segment-Path))
$(call Verify-Seg-Context,sd3.tsd3)

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
