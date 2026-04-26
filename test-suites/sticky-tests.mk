#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the macros and variables related to Sticky variables.
#----------------------------------------------------------------------------

define _help
Make test suite: ${Seg}.mk

Verify the macros and variables used for maintaining sticky variables.

Command line goals:
  help-${SegUN}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,TestList,Test list.)

$(call Declare-Suite,${Seg},Verify the Sticky variable macros.)

${.SuiteN}.Prereqs :=

# Define the tests in the order in which they should be run.

$(call Declare-Test,Sticky)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
  This verifies the logic of sticky variables (see help-Sticky). Two sticky variables, CASES and SUITES_PATH, should already exist by the time
  this macro is called. These are first verified to have correct values.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-String
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Mark-Step,Verifying existing sticky variables.)
  $(foreach _vn,CASES SUITES_PATH,
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn}))
    $(call Test-Info,Verifying "${_vn}" equals "${${_vn}}".)
    $(if ${${_vn}},
      $(if $(filter ${_tmp},${${_vn}}),
        $(call PASS,${_vn} has correct value.)
      ,
        $(call FAIL,${_vn} has incorrect sticky value:"${_tmp}")
      )
    ,
      $(if ${_tmp},
        $(call FAIL,${_vn} has incorrect sticky value:"${_tmp}")
      ,
        $(call PASS,${_vn} has correct value.)
      )
    )
  )

  $(call Mark-Step,Creating a new sticky variable using default.)
  $(eval _vn1 := sticky1)
  $(eval _vv1 := default)
  $(call Sticky,${_vn1},${_vv1})
  $(if $(wildcard ${STICKY_PATH}/${_vn1}),
    $(call PASS,Sticky var ${_vn1} exists.)
    $(call Mark-Step,Checking variable contents.)
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn1}))
    $(call Expect-String,${_vv1},${_tmp})
    $(if $(filter ${_vn1},${StickyVars}),
      $(call PASS,Sticky ${_vn1} was declared.)
    ,
      $(call FAIL,Sticky ${_vn1} was NOT declared.)
    )
  ,
    $(call FAIL,Sticky var ${_vn1} was not created.)
  )

  $(call Mark-Step,Verify redefinition warning.)
  $(call Expect-Warning,Redefinition of sticky variable ${_vn1} ignored.)
  $(call Sticky,${_vn1},Redefined)
  $(call Verify-Warning)

  $(call Mark-Step,Verify NO redefinition warning.)
  $(eval _vn2 := sticky2)
  $(call Expect-No-Warning)
  $(call Sticky,${_vn2},new)
  $(call Verify-No-Warning)

  $(call Mark-Step,New sticky -- no default.)
  $(eval _vn3 := sticky3)
  $(eval _vv3 := new ${_vn3})
  $(call Sticky,${_vn3}=${_vv3})
  $(if $(wildcard ${STICKY_PATH}/${_vn3}),
    $(call PASS,Sticky var ${_vn3} exists.)
    $(call Test-Info,Checking variable contents.)
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn3}))
    $(call Expect-String,${_vv3},${_tmp})
    $(if $(filter ${_vn3},${StickyVars}),
      $(call PASS,Sticky ${_vn3} was declared.)
    ,
      $(call FAIL,Sticky ${_vn3} was NOT declared.)
    )
  ,
    $(call FAIL,Sticky var ${_vn3} was not created.)
  )

  $(call Mark-Step,Existing sticky -- get existing value.)
  $(eval _vn4 := sticky4)
  $(eval _vv4 := existing_${_vn4})
  $(file >${STICKY_PATH}/${_vn4},${_vv4})
  $(call Sticky,${_vn4})
  $(if $(wildcard ${STICKY_PATH}/${_vn4}),
    $(call PASS,Sticky var ${_vn4} exists.)
    $(call Test-Info,Checking variable contents.)
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn4}))
    $(call Expect-String,${_vv4},${_tmp})
    $(if $(filter ${_vn4},${StickyVars}),
      $(call PASS,Sticky ${_vn4} was declared.)
    ,
      $(call FAIL,Sticky ${_vn4} was NOT declared.)
    )
  ,
    $(call FAIL,Sticky var ${_vn4} was not created.)
  )

  $(call Mark-Step,Existing sticky -- new value.)
  $(eval _vn5 := sticky5)
  $(file >${STICKY_PATH}/${_vn5},existing ${_vn5})
  $(eval _vv5 := new ${_vn5})
  $(call Sticky,${_vn5}=${_vv5})
  $(if $(wildcard ${STICKY_PATH}/${_vn5}),
    $(call PASS,Sticky var ${_vn5} exists.)
    $(call Test-Info,Checking variable contents.)
    $(eval _tmp := $(file <${STICKY_PATH}/${_vn5}))
    $(call Expect-String,${_vv5},${_tmp})
    $(if $(filter ${_vn5},${StickyVars}),
      $(call PASS,Sticky ${_vn5} was declared.)
    ,
      $(call FAIL,Sticky ${_vn5} was NOT declared.)
    )
  ,
    $(call FAIL,Sticky var ${_vn5} was not created.)
  )

  $(eval _vn6 := sticky6)
  $(eval ${_vn6} := from file)
  $(call Expect-Warning,\
    Sticky variable ${_vn6} was defined in a make segment -- not saving.)
  $(call Sticky,${_vn6})
  $(call Verify-Warning)

  $(call Test-Info,Cleanup...)
  $(foreach _v,${_vn1} ${_vn2} ${_vn3} ${_vn4} ${_vn5} ${_vn6},
    $(eval StickyVars := $(filter-out ${_v},${StickyVars}))
    $(shell rm ${STICKY_PATH}/${_v})
    $(eval undefine ${_v})
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Redefine-Sticky)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Sticky var-tests.Compare-Strings
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _vn1 := redefine-sticky1)
  $(eval _vn1v := defining ${_vn1})
  $(call Sticky,${_vn1}=${_vn1v})
  $(eval _vn1g := ${${_vn1}})
  $(call Test-Info,Verifying ${_vn1} = "${_vn1v}")
  $(call Expect-String,${_vn1g},${${_vn1}})

  $(eval _vn1v := new ${_vn1})
  $(call Expect-No-Error)
  $(call Redefine-Sticky,${_vn1}=${_vn1v})
  $(call Verify-No-Error)
  $(eval _vn1g := ${${_vn1}})
  $(call Test-Info,Verifying ${_vn1} = "${_vn1v}")
  $(call Expect-String,${_vn1g},${${_vn1}})

  $(eval _vn1v := new ${_vn1})
  $(eval SubMake := 1)
  $(call Expect-Warning,Cannot overwrite ${_vn1} in a submake.)
  $(call Expect-No-Error)
  $(call Redefine-Sticky,${_vn1}=${_vn1v})
  $(call Verify-No-Error)
  $(call Verify-Warning)
  $(eval SubMake :=)
  $(call Test-Info,Verifying ${_vn1} = "${_vn1v}")
  $(call Expect-String,${_vn1g},${${_vn1}})

  $(eval _vn2 := does-not-exist)
  $(eval _vn2v := defining ${_vn2})
  $(call Expect-Error,Var ${_vn2} has not been defined.)
  $(call Redefine-Sticky,${_vn2}=${_vn2v})
  $(call Verify-Error)

  $(call Test-Info,Cleanup...)
  $(foreach _v,_vn1 _vn2,
    $(call Test-Info,Removing test var:${_v})
    $(eval StickyVars := $(filter-out ${${_v}},${StickyVars}))
    $(shell rm ${STICKY_PATH}/${${_v}})
    $(eval undefine ${${_v}})
    $(eval undefine ${_v})
    $(eval undefine ${_v}v)
    $(eval undefine ${_v}g)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Remove-Sticky)
define _help
${.TestUN}
  Verify the macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.Redefine-Sticky
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _vn1 := remove_sticky)
  $(eval _vn1v := ${_vn1})

  $(call Test-Info,STICKY_PATH:${STICKY_PATH})
  $(foreach _f,$(wildcard ${STICKY_PATH}/*),
    $(call Test-Info,Var file:${_f})
  )
  $(call Mark-Step,Sticky vars:${StickyVars})
  $(eval VERBOSE=1)
  $(call Sticky,${_vn1}=${_vn1v})
  $(eval VERBOSE=)

  $(call Mark-Step,Verifying ${_vn1} = "${_vn1v}")
  $(call Expect-Vars,${_vn1}:${_vn1v},:)
  $(call Test-Info,Sticky vars:${StickyVars})
  $(foreach _f,$(wildcard ${STICKY_PATH}/*),
    $(call Test-Info,Var file:${_f})
  )

  $(call Mark-Step,Verify can remove sticky variable.)
  $(call Expect-No-Error)
  $(call Remove-Sticky,${_vn1})
  $(call Verify-No-Error)

  $(call Mark-Step,Verify sticky variable has been removed.)
  $(call Expect-Error,Var ${_vn1} has not been defined.)
  $(call Remove-Sticky,${_vn1})
  $(call Verify-Error)

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
