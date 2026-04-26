#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this test suite segment>
#----------------------------------------------------------------------------

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

__TestSeg := testing-seg

_macro := __Save-Seg-Lists
define _help
${_macro}
  Save segment related lists so that tests which modify these lists will not affect other tests. The helper variables SegPaths and SegUNs are reset so that prior tests will not affect the segment tests.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(eval __Saved,MAKEFILE_LIST := ${MAKEFILE_LIST})
  $(eval __Saved.FirstSegUN := ${FirstSegUN})
  $(eval __Saved.SegPaths := ${SegPaths})
  $(eval __Saved.SegUNs := ${SegUNs})
  $(eval __Saved.SegUN := ${SegUN})
  $(call Exit-Macro)
endef

_macro := __Undefine-Segments
define _help
${_macro}
  Undefine any segments which were declared for testing.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${SegUNs},
    $(call Test-Info,Undefining segments:${SegUNs})
    $(foreach _un,${SegUNs},
      $(if $(filter ${_un},${__Saved.SegUNs}),
        $(call Warn,Segment ${_un} is in saved list -- not undefining.)
      ,
        $(foreach _att,${SegAttributes},
          $(eval undefine ${_un}.${_att})
        )
      )
    )
  ,
    $(call Test-Info,No additional segments were used.)
  )
endef

_macro := __Reset-Seg-Lists
define _help
${_macro}
  The helper variables SegPaths and SegUNs are reset so that prior tests will not affect the segment tests. NOTE: This macro should be used only after the lists have been saved using __Save-Seg-Lists.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,MAKEFILE_LIST is: ${MAKEFILE_LIST})
  $(call __Undefine-Segments)
  $(eval MAKEFILE_LIST := ${__TestSeg})
  $(call Test-Info,MAKEFILE_LIST reset to: ${MAKEFILE_LIST})
  $(eval FirstSegUN := ${__TestSeg})
  $(eval SegPaths := )
  $(eval SegUNs := ${__TestSeg})
  $(eval SegUN := ${__TestSeg})
  $(call __Init-First-Segment-Context,For testing using segments.)
  $(call Exit-Macro)
endef

_macro := __Restore-Seg-Lists
define _help
${_macro}
  Restore previously saved segment related lists so that tests which modify these lists will not affect other tests. The segments used by the test are also undefined.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call __Undefine-Segments)
  $(eval SegPaths := ${__Saved.SegPaths})
  $(eval SegUNs := ${__Saved.SegUNs})
  $(eval SegUN := ${__Saved.SegUN})
  $(eval FirstSegUN := $(__Saved.FirstSegUN))
  $(call Exit-Macro)
endef

_macro := __Verify-Seg-Context
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
    NewSegUN:$(1) \
    SegUN:${NewSegUN} \
    ${SegUN}.SegUN:${SegUN} \
    SegID:$(words ${SegUNs}) \
    ${SegUN}.SegID:${SegID} \
    ${SegUN}.Seg:${Seg} \
    ${SegUN}.SegV:${SegV} \
    ${SegUN}.SegP:${SegP} \
    ${SegUN}.SegD:${SegD} \
    ${SegUN}.SegF:${SegF} \
    ,:)
  $(call Exit-Macro)
endef

_macro := __Save-Current-Context
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
  $(foreach _a,${SegAttributes},
    $(eval $(1).${_a} := ${_a})
  )
  $(call Exit-Macro)
endef

_macro := __Verify-Current-Context
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
  $(eval _ch := )
  $(foreach _a,${SegAttributes},
    $(if $(filter ${$(1).${_a}},${_a}),
    ,
      $(call Test-Info,Attribute ${_a} has changed!)
      $(eval _ch := 1)
    )
  )
  $(if ${_ch},
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
  The variable SegUN is saved and set to a test value to avoid having to change this test if this segment is moved to a different location.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _SegUN := ${SegUN})
  $(eval SegUN := test-seg)

  $(eval _tp := test1/test2/test3.mk)
  $(call Path-To-UN,${_tp},_un)
  $(call Expect-Vars,_un=${SegUN}.test3)

  $(eval _tp := d1/td1.n.mk)
  $(call Path-To-UN,${_tp},_un)
  $(call Expect-Vars,_un=${SegUN}.td1.n)

  $(eval SegUN := ${_SegUN})

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
  $(call __Save-Seg-Lists)

  $(call Mark-Step,Testing single paths.)
  $(eval _tp := nothing)
  $(call Expect-Error,Segment path ${_tp} does not exist.)
  $(call Add-Segment-Path,${_tp})
  $(call Verify-Error)

  $(if $(filter ${_tp},${SegPaths}),
    $(call FAIL,The segment path should not have been added.)
  ,
    $(call PASS,The segment path was NOT added.)
  )

  $(eval _tp := test-segs)
  $(call Expect-No-Error)
  $(call Add-Segment-Path,${_tp})
  $(call Verify-No-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-Vars,SegPaths=${_tp})
  $(if $(filter ${_tp},${SegPaths}),
    $(call PASS,The segment path was added.)
  ,
    $(call FAIL,The segment path was NOT added.)
  )

  $(call Expect-Warning,Segment path ${_tp} was already added.)
  $(call Add-Segment-Path,${_tp})
  $(call Verify-Warning)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-Vars,SegPaths=${_tp})
  $(if $(filter ${_tp},${SegPaths}),
    $(call PASS,The segment path was added.)
  ,
    $(call FAIL,The segment path was NOT added.)
  )

  $(eval undefine _tp)

  $(call Mark-Step,Testing multiple paths.)
  $(call __Restore-Seg-Lists)

  $(eval _tp1 := test-segs)
  $(eval _tp2 := test-segs/d1)
  $(call Expect-No-Error)
  $(call Add-Segment-Path,${_tp1} ${_tp2})
  $(call Verify-No-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(call Expect-List,${SegPaths},${__Saved.SegPaths} ${_tp1} ${_tp2})
  $(foreach _p,_tp1 _tp2,
    $(call Test-Info,Checking path:${${_p}})
    $(if $(filter ${${_p}},${SegPaths}),
      $(call PASS,The segment path ${${_p}} was added.)
    ,
      $(call FAIL,The segment path ${${_p}} was NOT added.)
    )
  )
  $(call __Restore-Seg-Lists)

  $(eval _tp1 := test-segs)
  $(eval _tp2 := xxx)
  $(call Expect-Error,Segment path ${_tp2} does not exist.)
  $(call Add-Segment-Path,${_tp1} ${_tp2})
  $(call Verify-Error)
  $(call Test-Info,SegPaths:${SegPaths})
  $(if $(filter ${_tp1},${SegPaths}),
    $(call PASS,The segment path ${_tp1} was added.)
  ,
    $(call FAIL,The segment path ${_tp1} was NOT added.)
  )
  $(if $(filter ${_tp2},${SegPaths}),
    $(call FAIL,The segment path ${_tp2} was added.)
  ,
    $(call PASS,The segment path ${_tp2} was NOT added.)
  )

  $(eval undefine _tp1)
  $(eval undefine _tp2)
  $(call __Restore-Seg-Lists)
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

  $(call __Save-Seg-Lists)

  $(call Mark-Step,Attempt to use segment not in the search paths.)
  $(call Expect-No-Error)
  $(call Expect-Warning,Segment ts1 not found.)
  $(call Find-Segment,ts1,_seg_f)
  $(call Verify-Warning)
  $(call Verify-No-Error)
  $(if ${_seg_f},
    $(call FAIL,Find-Segment returned a segment file name.)
  ,
    $(call PASS,Find-Segment did not return a segment file name.)
  )

  $(call Mark-Step,Attempt to use segment in search paths.)
  $(call Add-Segment-Path,test-segs)
  $(call Expect-No-Error)
  $(call Expect-No-Warning)
  $(call Find-Segment,ts1,_seg_f)
  $(call Verify-No-Warning)
  $(call Verify-No-Error)
  $(if ${_seg_f},
    $(call PASS,Find-Segment returned a segment file name.)
  ,
    $(call FAIL,Find-Segment did not return a segment file name.)
  )
  $(call Expect-Vars,_seg_f=test-segs/ts1.mk)

  $(call Mark-Step,Using partial path relative to a segment path,)
  $(call Expect-No-Error)
  $(call Expect-No-Warning)
  $(call Find-Segment,d1/td1,_seg_f)
  $(call Verify-No-Warning)
  $(call Verify-No-Error)
  $(if ${_seg_f},
    $(call PASS,Find-Segment returned a segment file name.)
  ,
    $(call FAIL,Find-Segment did not return a segment file name.)
  )
  $(call Expect-Vars,_seg_f=test-segs/d1/td1.mk)

  $(call __Restore-Seg-Lists)
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

  $(eval _SegID := ${SegID})
  $(eval _SegID_Stack := ${SegID_Stack})
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

  $(eval SegID_Stack := ${_SegID_Stack})
  $(eval SegID := ${_SegID})
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

  $(eval _Caller := ${Caller})
  $(eval _Macro_Stack := ${Macro_Stack})
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

  $(eval Macro_Stack := ${_Macro_Stack})
  $(eval Caller := ${_Caller})
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
  $(eval _SegUN := ${SegUN})

  $(foreach _un,${SegUNs},
    $(call Test-Info,Checking context for seg ${_un}.)
    $(call Display-Seg-Attributes,${_un})
    $(call __Set-Segment-Context,${${_un}.SegID})
    $(foreach _att,${SegAttributes},
      $(if $(or $(call Are-Equal,${_att},SegTL),
                 $(call Are-Equal,${_att},SegHL)),
      ,
        $(call Expect-Vars,${_att}=${${_un}.${_att}})
      )
    )
  )
  $(call Test-Info,Restoring context for ${_SegUN} ID ${${_SegUN}.SegID}.)
  $(call __Set-Segment-Context,${${_SegUN}.SegID})

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

  $(call __Save-Seg-Lists)
  $(call Display-Segs)
  $(call __Reset-Seg-Lists)

  $(call Mark-Step,Running test:${.TestUN})

  $(call __Save-Current-Context,_saved)

  $(call Mark-Step,Segment not in search path.)
  $(call Expect-Warning,Segment ts1 not found.)
  $(call Expect-Error,Segment ts1 could not be found.)
  $(call Use-Segment,ts1,,Included as a test.)
  $(call Verify-Error)
  $(call Verify-Warning)
  $(call Display-Segs)

  $(call __Reset-Seg-Lists)

  $(call Mark-Step,Adding a search path -- verify can use ts1.)
  $(call Add-Segment-Path,test-segs)

  $(call Test-Info,SegPaths:${SegPaths})

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts1,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call __Reset-Seg-Lists)
  $(call Add-Segment-Path,test-segs)

  $(call Mark-Step,Verify can use ts2 with existing search path.)
  $(call Test-Info,SegPaths:${SegPaths})

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts2,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call Mark-Step,Attempt to use same segment twice.)
  $(call Expect-Message,Segment makefile.ts2 is already loaded.)
  $(call Expect-No-Error)
  $(call Use-Segment,ts2,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-Message)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call __Reset-Seg-Lists)
  $(call Add-Segment-Path,test-segs)

  $(call Mark-Step,Segments in subdirectories.)
  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d1/td1,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d2/td2,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,d2/sd2/tsd2,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call Mark-Step,Segments which use other segments in their directory.)
  $(call Expect-No-Warning)
  $(call Expect-No-Error)
  $(call Use-Segment,ts3,,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-No-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call Mark-Step,Full segment path (no find).)
  $(call Expect-Vars,\
    makefile.ts3.SegP=${CorePath}/test-segs\
    makefile.ts3.SegF=test-segs/ts3.mk\
    )

  $(call Mark-Step,Same UN handling. Expecting: makefile.ts3.)
  $(call Expect-Warning,\
    Segment makefile.ts3 is already loaded.)
  $(call Expect-No-Error)
  $(call Use-Segment,${CorePath}/${makefile.ts3.SegF},,Included as a test.)
  $(call Verify-No-Error)
  $(call Verify-Warning)
  $(call Display-Segs)

  $(call __Verify-Current-Context,_saved)

  $(call __Restore-Seg-Lists)
  $(call End-Test)
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
_h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${_h},)
define _help
$(call Display-Help-List,${SegID})
endef
${_h} := ${_help}
endif # help goal message.

$(call End-Declare-Suite)
