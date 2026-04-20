#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this test suite segment>
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Test segment related macros.)
# -----

define _help
Make test suite: ${Seg}.mk

Test suite to test use of segments.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,SegTestHelpers,Segment testing helpers.)

_macro := Save-Seg-Lists
define _help
${_macro}
  Save segment related lists so that tests which modify these lists will not affect other tests. The helper variables SegPaths and SegUNs are reset so that prior tests will not affect the segment tests.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval Save.SegPaths := ${SegPaths})
  $(eval SegPaths := )
  $(eval Save.SegUNs := ${SegUNs})
  $(eval SegUns := )
  $(call Exit-Macro)
endef

_macro := Reset-Seg-Lists
define _help
${_macro}
  The helper variables SegPaths and SegUNs are reset so that prior tests will not affect the segment tests. NOTE: This macro should be used only after the lists have been saved using Save-Seg-Lists.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval SegPaths := )
  $(eval SegUns := )
  $(call Exit-Macro)
endef

_macro := Restore-Seg-Lists
define _help
${_macro}
  Restore previously saved segment related lists so that tests which modify these lists will not affect other tests. The segments used by the test are also undefined.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(if ${SegUNs},
    $(call Test-Info,Undefining segments:${SegUNs})
    $(foreach __un,${SegUNs},
      $(if $(filter ${__un},${Save.SegUNs}),
        $(call Warn,Segment ${__un} is in saved list -- not undefining.)
      ,
        $(foreach __att,${SegAttributes},
          $(eval undefine ${__un}.${__att})
        )
      )
    )
  ,
    $(call Test-Info,No additional segments were used.)
  )
  $(eval SegPaths := ${Save.SegPaths})
  $(eval SegUNs := ${Save.SegUNs})
  $(call Exit-Macro)
endef

_macro := Verify-Seg-Context
define _help
${_macro}
  Verify the segment context immediately after the segment context has been set.
  Parameters:
    1 = The expected SegUN for the segment.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),SegUN=$(1))
  $(call Test-Info,Verifying context for $(1).)
  $(call Expect-Vars,\
    LastSegUN:$(1) \
    SegUN:${LastSegUN} \
    ${SegUN}.SegUN:${SegUN} \
    SegID:$(words ${MAKEFILE_LIST}) \
    ${SegUN}.SegID:${SegID} \
    ${SegUN}.Seg:${Seg} \
    ${SegUN}.SegV:${SegV} \
    ${SegUN}.SegP:${SegP} \
    ${SegUN}.SegD:${SegD} \
    ${SegUN}.SegF:${SegF} \
  )
  $(call Exit-Macro)
endef

_macro := Save-Current-Context
define _help
${_macro}
  Save segment context so that changes can be detected.
  Parameters:
    1 = The name of the context to save to.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Context=$(1))
  $(foreach __a,${SegAttributes},
    $(eval $(1).${__a} := ${__a})
  )
  $(call Exit-Macro)
endef

_macro := Verify-Current-Context
define _help
${_macro}
  Check segment context to verify the context as not changed since it was saved.
  Parameters:
    1 = The name of the previously saved context.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Context=$(1))
  $(eval __ch := )
  $(foreach __a,${SegAttributes},
    $(if $(filter ${$(1).${__a}},${__a}),
    ,
      $(call Test-Info,Attribute ${__a} has changed!)
      $(eval __ch := 1)
    )
  )
  $(if ${__ch},
    $(call FAIL,Segment context has changed.)
  ,
    $(call PASS,Segment context is unchanged.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,TestList,Test list.)

$(call Declare-Suite,${Seg},Test using segments.)

${.SuiteN}.Prereqs :=

# Define the tests in the order in which they should be run.

$(call Declare-Test,Path-To-UN)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval __tp := test1/test2/test3.mk)
  $(call Expect-No-Error)
  $(call Path-To-UN,${__tp},__un)
  $(call Verify-No-Error)
  $(call Expect-Vars,__un=test2.test3)

  $(eval __tp := d1/td1.mk)
  $(call Expect-No-Error)
  $(call Path-To-UN,${__tp},__un)
  $(call Verify-No-Error)
  $(call Expect-Vars,__un=d1.td1)

  $(eval __tp := test-segs/d1)
  $(call Expect-No-Error)
  $(call Path-To-UN,${__tp},__un)
  $(call Verify-No-Error)
  $(call Expect-Vars,__un=test-segs.d1)

  $(eval __tp := test-segs/d1/td1.mk)
  $(call Expect-No-Error)
  $(call Path-To-UN,${__tp},__un)
  $(call Verify-No-Error)
  $(call Expect-Vars,__un=d1.td1)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Add-Segment-Path)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,SegID:${SegID} SegID_Stack:${SegID_Stack})
  $(call Save-Seg-Lists)

  $(call Test-Info,Testing single paths.)
  $(eval __tp := nothing)
  $(call Expect-Error,Segment path ${__tp} does not exist.)
  $(call Add-Segment-Path,${__tp})
  $(call Verify-Error)

  $(if $(filter ${__tp},${SegPaths}),
    $(call FAIL,The segment path should not have been added.)
  ,
    $(call PASS,The segment path was NOT added.)
  )

  $(eval __tp := test-segs)
  $(call Expect-No-Error)
  $(call Add-Segment-Path,${__tp})
  $(call Verify-No-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-Vars,SegPaths=${__tp})
  $(if $(filter ${__tp},${SegPaths}),
    $(call PASS,The segment path was added.)
  ,
    $(call FAIL,The segment path was NOT added.)
  )

  $(call Expect-Warning,Segment path ${__tp} was already added.)
  $(call Add-Segment-Path,${__tp})
  $(call Verify-Warning)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-Vars,SegPaths=${__tp})
  $(if $(filter ${__tp},${SegPaths}),
    $(call PASS,The segment path was added.)
  ,
    $(call FAIL,The segment path was NOT added.)
  )

  $(eval undefine __tp)

  $(call Test-Info,Testing multiple paths.)
  $(call Reset-Seg-Lists)

  $(eval __tp1 := test-segs)
  $(eval __tp2 := test-segs/d1)
  $(call Expect-No-Error)
  $(call Add-Segment-Path,${__tp1} ${__tp2})
  $(call Verify-No-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-List,${SegPaths},${__tp1} ${__tp2})
  $(foreach _p,__tp1 __tp2,
    $(call Test-Info,Checking path:${${_p}})
    $(if $(filter ${${_p}},${SegPaths}),
      $(call PASS,The segment path ${${_p}} was added.)
    ,
      $(call FAIL,The segment path ${${_p}} was NOT added.)
    )
  )
  $(call Reset-Seg-Lists)

  $(eval __tp1 := test-segs)
  $(eval __tp2 := xxx)
  $(call Expect-Error,Segment path ${__tp2} does not exist.)
  $(call Add-Segment-Path,${__tp1} ${__tp2})
  $(call Verify-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(if $(filter ${__tp1},${SegPaths}),
    $(call PASS,The segment path ${__tp1} was added.)
  ,
    $(call FAIL,The segment path ${__tp1} was NOT added.)
  )
  $(if $(filter ${__tp2},${SegPaths}),
    $(call FAIL,The segment path ${__tp2} was added.)
  ,
    $(call PASS,The segment path ${__tp2} was NOT added.)
  )

  $(eval undefine __tp1)
  $(eval undefine __tp2)
  $(call Restore-Seg-Lists)
  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Find-Segment)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Path-To-UN ${.SuiteN}.Add-Segment-Path
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))
  $(call Test-Info,SegID:${SegID} SegID_Stack:${SegID_Stack})

  $(call Save-Seg-Lists)

  $(call Test-Info,Attempt to use segment not in the search paths.)
  $(call Expect-No-Error)
  $(call Expect-Warning,Segment ts1 not found.)
  $(call Find-Segment,ts1,__seg_f)
  $(call Verify-Warning)
  $(call Verify-No-Error)
  $(if ${__seg_f},
    $(call FAIL,Find-Segment returned a segment file name.)
  ,
    $(call PASS,Find-Segment did not return a segment file name.)
  )

  $(call Test-Info,Attempt to use segment in search paths.)
  $(call Add-Segment-Path,test-segs)
  $(call Expect-No-Error)
  $(call Expect-No-Warning)
  $(call Find-Segment,ts1,__seg_f)
  $(call Verify-No-Warning)
  $(call Verify-No-Error)
  $(if ${__seg_f},
    $(call PASS,Find-Segment returned a segment file name.)
  ,
    $(call FAIL,Find-Segment did not return a segment file name.)
  )
  $(call Expect-Vars,__seg_f=test-segs/ts1.mk)

  $(call Test-Info,Using partial path relative to a segment path,)
  $(call Expect-No-Error)
  $(call Expect-No-Warning)
  $(call Find-Segment,d1/td1,__seg_f)
  $(call Verify-No-Warning)
  $(call Verify-No-Error)
  $(if ${__seg_f},
    $(call PASS,Find-Segment returned a segment file name.)
  ,
    $(call FAIL,Find-Segment did not return a segment file name.)
  )
  $(call Expect-Vars,__seg_f=test-segs/d1/td1.mk)

  $(call Restore-Seg-Lists)
  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Push-Pop-SegID)
define _help
${.TestUN}
  Verify the macros for managing the SegID stack.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,SegID:${SegID} SegID_Stack:${SegID_Stack})

  $(eval __SegID := ${SegID})
  $(eval __SegID_Stack := ${SegID_Stack})
  $(eval SegID_Stack := )

  $(eval SegID := 1)
  $(call __Push-SegID)
  $(call Expect-List,1,${SegID_Stack})

  $(eval SegID := 2)
  $(call __Push-SegID)
  $(call Expect-List,1 2,${SegID_Stack})
  $(eval SegID := 3)
  $(call __Pop-SegID)
  $(call Expect-Vars,SegID=2)
  $(call Expect-List,1,${SegID_Stack})

  $(eval SegID := 2)
  $(call __Push-SegID)
  $(call Expect-List,1 2,${SegID_Stack})
  $(eval SegID := 3)
  $(call __Push-SegID)
  $(call Expect-List,1 2 3,${SegID_Stack})
  $(call __Pop-SegID)
  $(call Expect-List,1 2,${SegID_Stack})
  $(call Expect-Vars,SegID=3)
  $(call __Pop-SegID)
  $(call Expect-List,1,${SegID_Stack})
  $(call Expect-Vars,SegID=2)
  $(call __Pop-SegID)
  $(if ${SegID_Stack},
    $(call FAIL,SegID_Stack should be empty but contains:${SegID_Stack})
  ,
    $(call PASS,SegID_Stack is empty.)
  )
  $(call Expect-Vars,SegID=1)

  $(call Expect-Error,SegID stack is empty.)
  $(call __Pop-SegID)
  $(call Verify-Error)
  $(call Expect-Vars,SegID=1)

  $(eval SegID := 1)
  $(call __Push-SegID)
  $(call Expect-List,1,${SegID_Stack})
  $(call Expect-Error,Recursive entry to segment 1 detected.)
  $(call __Push-SegID)
  $(call Verify-Error)
  $(call Expect-List,1 1,${SegID_Stack})
  $(eval SegID := 2)
  $(call __Push-SegID)
  $(call Expect-List,1 1 2,${SegID_Stack})
  $(eval SegID := 3)
  $(call __Push-SegID)
  $(call Expect-List,1 1 2 3,${SegID_Stack})
  $(eval SegID := 2)
  $(call Expect-Error,Recursive entry to segment 2 detected.)
  $(call __Push-SegID)
  $(call Verify-Error)

  $(call Expect-List,1 1 2 3 2,${SegID_Stack})
  $(call __Pop-SegID)
  $(call Expect-List,1 1 2 3,${SegID_Stack})
  $(call Expect-Vars,SegID=2)
  $(call __Pop-SegID)
  $(call Expect-List,1 1 2,${SegID_Stack})
  $(call Expect-Vars,SegID=3)
  $(call __Pop-SegID)
  $(call Expect-List,1 1,${SegID_Stack})
  $(call Expect-Vars,SegID=2)
  $(call __Pop-SegID)
  $(call Expect-List,1,${SegID_Stack})
  $(call Expect-Vars,SegID=1)
  $(call __Pop-SegID)
  $(if ${SegID_Stack},
    $(call FAIL,SegID_Stack should be empty but contains:${SegID_Stack})
  ,
    $(call PASS,SegID_Stack is empty.)
  )
  $(call Expect-Vars,SegID=1)

  $(eval SegID_Stack := ${__SegID_Stack})
  $(eval SegID := ${__SegID})
  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Push-Pop-Macro)
define _help
${.TestUN}
  Verify the macros for managing the macro call stack.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,SegID:${SegID} Macro_Stack:${Macro_Stack})

  $(eval __Caller := ${Caller})
  $(eval __Macro_Stack := ${Macro_Stack})
  $(eval Macro_Stack := )

  $(call __Push-Macro,1)
  $(call Expect-List,1,${Macro_Stack})
  $(if ${Caller},
    $(call FAIL,Caller should be empty. Actual:${Caller})
  ,
    $(call PASS,Caller is empty.)
  )

  $(call __Push-Macro,2)
  $(call Expect-List,1 2,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Pop-Macro)
  $(call Expect-List,1,${Macro_Stack})
  $(if ${Caller},
    $(call FAIL,Caller should be empty. Actual:${Caller})
  ,
    $(call PASS,Caller is empty.)
  )

  $(call __Push-Macro,2)
  $(call Expect-List,1 2,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Push-Macro,3)
  $(call Expect-List,1 2 3,${Macro_Stack})
  $(call Expect-Vars,Caller=2)

  $(call __Pop-Macro)
  $(call Expect-List,1 2,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Pop-Macro)
  $(call Expect-List,1,${Macro_Stack})
  $(call Expect-Vars,Caller=)
  $(call __Pop-Macro)
  $(call Expect-Vars,Macro_Stack= Caller=)

  $(call Expect-Error,Macro call stack is empty.)
  $(call __Pop-Macro)
  $(call Verify-Error)
  $(call Expect-Vars,Macro_Stack= Caller=)


  $(call __Push-Macro,1)
  $(call Expect-List,1,${Macro_Stack})
  $(call Expect-Vars,Caller=)
  $(call Expect-Message,Recursive call to macro 1 detected.)
  $(call __Push-Macro,1)
  $(call Verify-Message)
  $(call Expect-List,1 1,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Push-Macro,2)
  $(call Expect-List,1 1 2,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Push-Macro,3)
  $(call Expect-List,1 1 2 3,${Macro_Stack})
  $(call Expect-Vars,Caller=2)
  $(call Expect-Message,Recursive call to macro 2 detected.)
  $(call __Push-Macro,2)
  $(call Verify-Message)
  $(call Expect-List,1 1 2 3 2,${Macro_Stack})
  $(call Expect-Vars,Caller=3)
  $(call __Pop-Macro)
  $(call Expect-List,1 1 2 3,${Macro_Stack})
  $(call Expect-Vars,Caller=2)
  $(call __Pop-Macro)
  $(call Expect-List,1 1 2,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Pop-Macro)
  $(call Expect-List,1 1,${Macro_Stack})
  $(call Expect-Vars,Caller=1)
  $(call __Pop-Macro)
  $(call Expect-List,1,${Macro_Stack})
  $(call Expect-Vars,Caller=)
  $(call __Pop-Macro)
  $(if ${Macro_Stack},
    $(call FAIL,Macro_Stack should be empty but contains:${Macro_Stack})
  ,
    $(call PASS,Macro_Stack is empty.)
  )
  $(call Expect-Vars,Caller=)

  $(eval Macro_Stack := ${__Macro_Stack})
  $(eval Caller := ${__Caller})
  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Set-Segment-Context)
define _help
${.TestUN}
  Verify the macro for establishing segment context.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.Path-To-UN \
  ${.SuiteN}.Push-Pop-SegID \
  ${.SuiteN}.Push-Pop-Macro
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))
  $(call Test-Info,SegID:${SegID} SegID_Stack:${SegID_Stack})

  $(call Display-Segs)
  $(eval __SegUN := ${SegUN})

  $(foreach __un,${SegUNs},
    $(call Test-Info,Checking context for seg ${__un}.)
    $(call Display-Seg-Attributes,${__un})
    $(call Set-Segment-Context,${${__un}.SegID})
    $(foreach __att,${SegAttributes},
      $(if $(or $(call Are-Equal,${__att},SegTL),
                 $(call Are-Equal,${__att},SegHL)),
      ,
        $(call Expect-Vars,${__att}=${${__un}.${__att}})
      )
    )
  )
  $(call Test-Info,Restoring context for ${__SegUN} ID ${${__SegUN}.SegID}.)
  $(call Set-Segment-Context,${${__SegUN}.SegID})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Use-Segment)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
  This requires some segs use other segs.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.Set-Segment-Context \
  ${.SuiteN}.Find-Segment
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))
  $(call Test-Info,SegID:${SegID} SegID_Stack:${SegID_Stack})

  $(call Save-Seg-Lists)

  $(call Test-Info,Running test:${.TestUN})

  $(call Save-Current-Context,__save)

  $(call Test-Info,Segment not in search path.)
  $(call Expect-Warning,Segment ts1 not found.)
  $(call Expect-Error,Segment ts1 could not be found.)
  $(call Use-Segment,ts1)
  $(call Verify-Error)
  $(call Verify-Warning)

  $(call Test-Info,Adding a search path.)
  $(call Add-Segment-Path,test-segs)

  $(call Test-Info,SegPaths:${SegPaths})

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts1)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Test-Info,SegPaths:${SegPaths})

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts2)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Test-Info,Attempt to use same segment twice.)
  $(call Expect-Message,Segment ts2 is already loaded.)
  $(call Expect-No-Error)
  $(call Use-Segment,ts2)
  $(call Verify-No-Error)
  $(call Verify-Message)

  $(call Verify-Current-Context,__save)

  $(call Test-Info,Segments in subdirectories.)
  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d1/td1)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d2/td2)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d2/sd2/tsd2)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Test-Info,Segments which use other segments in their directory.)
  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts3)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)

  $(call Verify-Current-Context,__save)

  $(call Test-Info,Full segment path (no find).)
  $(call Expect-Vars,\
    test-segs.ts3.SegP=${CorePath}/test-segs\
    test-segs.ts3.SegF=test-segs/ts3.mk\
    )

  $(call Expect-Message,\
    Segment ${CorePath}/${test-segs.ts3.SegF} is already loaded.)
  $(call Expect-No-Error)
  $(call Use-Segment,${CorePath}/${test-segs.ts3.SegF})
  $(call Verify-No-Error)
  $(call Verify-Message)

  $(call Verify-Current-Context,__save)

  $(call Restore-Seg-Lists)
  $(call End-Test)
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
__h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call End-Declare-Suite)

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
