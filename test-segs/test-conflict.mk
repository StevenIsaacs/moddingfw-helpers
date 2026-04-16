#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test detection of segment name conflict.
#----------------------------------------------------------------------------
$(call Info,+++++ $(call Last-Segment-Basename) entry. +++++)
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Test detection of segment name conflict.)
# -----

#<segment body here>

# +++++
# Postamble
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
This make segment is designed to test detection of a prefix conflict between two or more files. Displaying this help should not be possible because this file uses the same prefix as test-macros.mk.
endef
${__h} := ${__help}
endif

$(call Exit-Segment)

else # tmSegID already defined.
$(call next-test,ID conflict context.)
$(call report-seg-context)
$(call Expect-Error,Prefix conflict with test-helpers in)
$(call Check-Segment-Conflicts)
$(call Verify-Error-Occurred,yes)

endif
# -----
$(call Info,----- $(call Last-Segment-Basename) exit. -----)
