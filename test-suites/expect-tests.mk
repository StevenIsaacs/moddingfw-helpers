#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Verify the helper macros for expecting values and results.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Verify the helper macros for expecting values and results.)
# -----

define _help
Make test suite: ${Seg}.mk

This test suite verifies the variety of expect macros.

Command line goals:
  help-${SegUN}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,TestList,Test list.)

$(call Declare-Suite,${Seg},Verify the variable related helper macros.)

# Define the tests in the order in which they should be run.

$(call Declare-Test,Expect-Vars)
define _help
${.TestUN}
  Verify Expect-Vars for both passing and failing.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Set-Expected-Results
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v1 := 1)
  $(eval _v2 := 2)
  $(eval _v3 := 3)
  $(call Expect-Vars,_v1=1 _v2=2 _v3=3)

  $(call Test-Info,Using delimiter override.)
  $(call Expect-Vars,_v1:1 _v2:2 _v3:3,:)

  $(eval _v1 := abc)
  $(eval _v2 := Def)
  $(eval _v3 := GhIJKlmnop)
  $(call Expect-Vars,_v1=abc _v2=Def _v3=GhIJKlmnop)

  $(call Set-Expected-Results,PASS PASS FAIL)
  $(call Expect-Vars,_v1=abc _v2=Def _v3=X)

  $(call Set-Expected-Results,PASS FAIL PASS)
  $(call Expect-Vars,_v1=abc _v2=def _v3=GhIJKlmnop)

  $(call Set-Expected-Results,FAIL PASS PASS)
  $(call Expect-Vars,_v1= _v2=Def _v3=GhIJKlmnop)

  $(eval _v1 :=)
  $(call Set-Expected-Results,PASS PASS PASS)
  $(call Expect-Vars,_v1= _v2=Def _v3=GhIJKlmnop)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Set-Expected-Results)
define _help
${.TestUN}
  Verify a list of expected results will produce the correct test results.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Set-Expected-Results,PASS)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should PASS:PASS.)
  $(if ${ExpectedResultsL},
    $(call FAIL,ExpectedResultsL should be empty.)
  ,
    $(call PASS,ExpectedResultsL is empty.)
  )
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should not call Verify-Result.)

  $(call Set-Expected-Results,FAIL)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should not call Verify-Result.)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})

  $(call Set-Expected-Results,PASS PASS FAIL FAIL FAIL)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call PASS,This should PASS:PASS.)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(if ${.Failed},
    $(call Test-Info,Test has already failed -- skipping FAIL reset.)
    $(call FAIL,This should FAIL:PASS.)
  ,
    $(call FAIL,This should FAIL:PASS.)
    $(if ${.Failed},
      $(call Test-Info,FAIL was expected${Comma} resetting .Failed.)
      $(call Undo-FAIL)
    ,
      $(call Test-Info,Expected a FAIL but the step passed.)
      $(call Record-FAIL)
    )
  )
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(if ${.Failed},
    $(call Test-Info,Test has already failed -- skipping FAIL reset.)
    $(call PASS,This should FAIL:FAIL.)
  ,
    $(call PASS,This should FAIL:FAIL.)
    $(if ${.Failed},
      $(call Test-Info,FAIL was expected${Comma} resetting .Failed.)
      $(call Undo-FAIL)
    ,
      $(call Test-Info,Expected a FAIL but the step passed.)
      $(call Record-FAIL)
    )
  )
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(call FAIL,This should PASS:FAIL.)
  $(call Verbose,ExpectedResultsL:${ExpectedResultsL})
  $(if ${ExpectedResultsL},
    $(call FAIL,ExpectedResultsL should be empty.)
  ,
    $(call PASS,ExpectedResultsL is empty.)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Expect-List)
define _help
${.TestUN}
  Verify Expect-List for both passing and failing.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Set-Expected-Results
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Set-Expected-Results,PASS)
  $(eval _l := $(call Expect-List,a b c,a b c))

  $(call Set-Expected-Results,FAIL)
  $(eval _l := $(call Expect-List,a b c,a x c))

  $(call Set-Expected-Results,FAIL FAIL)
  $(eval _l := $(call Expect-List,a b c d,a x c y))

  $(call Set-Expected-Results,FAIL)
  $(eval _l := $(call Expect-List,a b c d,a b c))

  $(call Set-Expected-Results,FAIL)
  $(eval _l := $(call Expect-List,a b c,a b c d))

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Expect-String)
define _help
${.TestUN}
  Verify Expect-String for both passing and failing.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Set-Expected-Results
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _str := This is a string.)
  $(call Set-Expected-Results,PASS)
  $(eval _l := $(call Expect-String,${_str},This is a string.))

  $(call Set-Expected-Results,FAIL)
  $(eval _l := $(call Expect-String,${_str},This is A string.))

  $(call Set-Expected-Results,FAIL FAIL)
  $(eval _l := $(call Expect-String,${_str},This Is A string.))

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Expect-Message)
define _help
${.TestUN}
  Verify Expect-Message for both passing and failing.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Set-Expected-Results
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Verifying match for a message.)
  $(eval __m := This should PASS.)
  $(call Expect-Message,${__m})
  $(call Info,${__m})
  $(call Set-Expected-Results,PASS)
  $(call Verify-Message)
  $(if ${MatchFound},
    $(call PASS,MatchFound is TRUE.)
  ,
    $(call FAIL.MatchFound is FALSE.)
  )
  $(if $(filter 1,${MatchCount}),
    $(call PASS,Message was found ${MatchCount} time.)
  ,
    $(call FAIL,Message was found ${MatchCount} time.)
  )
  $(if ${MismatchFound},
    $(call Test-Info,MismatchList=${MismatchList})
    $(call FAIL,MismatchFound is TRUE.)
  ,
    $(call PASS.MismatchFound is FALSE.)
  )
  $(if $(filter 0,${MismatchCount}),
    $(call PASS,Message was found ${MatchCount} time.)
  ,
    $(call FAIL,Message was found ${MatchCount} time.)
  )


  $(call Test-Info,Verifying no matching messages.)
  $(call Expect-Message,${__m})
  $(call Info,This should FAIL.)
  $(call Set-Expected-Results,FAIL)
  $(call Verify-Message)
  $(call Test-Info,Mismatch list:${MismatchList})
  $(if ${MatchFound},
    $(call FAIL,MatchFound is TRUE.)
  ,
    $(call PASS.MatchFound is FALSE.)
  )
  $(if $(filter 0,${MatchCount}),
    $(call PASS,Message was found ${MatchCount} time.)
  ,
    $(call FAIL,Message was found ${MatchCount} time.)
  )
  $(if ${MismatchFound},
    $(call PASS,MismatchFound is TRUE.)
  ,
    $(call FAIL.MismatchFound is FALSE.)
  )
  $(if $(filter 1,${MismatchFound}),
    $(call PASS,Message was found ${MismatchFound} time.)
  ,
    $(call FAIL,Message was found ${MismatchFound} time.)
  )

  $(call Test-Info,Verifying multiple matches.)
  $(eval __m := This should match.)

  $(call Expect-Message,${__m})
  $(call Info,${__m})
  $(call Set-Expected-Results,PASS)
  $(call Verify-Message,1)

  $(call Expect-Message,${__m})
  $(call Info,${__m})
  $(call Info,Not a match.)
  $(call Info,${__m})
  $(call Set-Expected-Results,PASS)
  $(call Verify-Message,2)

  $(call Expect-Message,${__m})
  $(call Info,${__m})
  $(call Info,Not a match.)
  $(call Set-Expected-Results,FAIL)
  $(call Verify-Message,2)

  $(call Expect-Message,${__m})
  $(call Info,${__m})
  $(call Info,Not a match.)
  $(call Info,${__m})
  $(call Info,${__m})
  $(call Set-Expected-Results,FAIL)
  $(call Verify-Message,2)
  $(if ${MatchFound},
    $(call PASS,MatchFound is TRUE.)
  ,
    $(call FAIL.MatchFound is FALSE.)
  )
  $(if $(filter 3,${MatchCount}),
    $(call PASS,Message was found ${MatchCount} time.)
  ,
    $(call FAIL,Message was found ${MatchCount} time.)
  )
  $(if ${MismatchFound},
    $(call PASS,MismatchFound is TRUE.)
  ,
    $(call FAIL.MismatchFound is FALSE.)
  )
  $(if $(filter 1,${MismatchFound}),
    $(call PASS,Message was found ${MismatchFound} time.)
  ,
    $(call FAIL,Message was found ${MismatchFound} time.)
  )

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
