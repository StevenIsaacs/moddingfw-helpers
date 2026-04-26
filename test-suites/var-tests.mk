#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Verify the helper macros for manipulating variables.
#----------------------------------------------------------------------------

define _help
Make test suite: ${Seg}.mk

A series of tests to verify the helpers variable related macros.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,TestList,Test list.)

$(call Declare-Suite,${Seg},Verify the variable related helper macros.)

# Define the tests in the order in which they should be run.

$(call Declare-Test,Inc-Var)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 0)
  $(foreach _e,0 1 2,
    $(call Expect-Vars,_v=${_e})
    $(call Inc-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Dec-Var)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 2)
  $(foreach _e,2 1 0,
    $(call Expect-Vars,_v=${_e})
    $(call Dec-Var,_v)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Add-Var)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 0)
  $(foreach _e,0 2 4,
    $(call Expect-Vars,_v=${_e})
    $(call Add-Var,_v,2)
  )

  $(eval _v := 0)
  $(foreach _e,0 101 202,
    $(call Expect-Vars,_v=${_e})
    $(call Add-Var,_v,101)
  )

  $(eval _v := -10)
  $(foreach _e,-10 -7 -4,
    $(call Expect-Vars,_v=${_e})
    $(call Add-Var,_v,3)
  )

  $(eval _v := 0)
  $(foreach _e,0 -3 -6,
    $(call Expect-Vars,_v=${_e})
    $(call Add-Var,_v,-3)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Sub-Var)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := 10)
  $(foreach _e,10 7 4,
    $(call Expect-Vars,_v=${_e})
    $(call Sub-Var,_v,3)
  )

  $(eval _v := 202)
  $(foreach _e,202 101 0,
    $(call Expect-Vars,_v=${_e})
    $(call Sub-Var,_v,101)
  )

  $(eval _v := 0)
  $(foreach _e,0 -3 -6,
    $(call Expect-Vars,_v=${_e})
    $(call Sub-Var,_v,3)
  )

  $(eval _v := 0)
  $(foreach _e,0 3 6,
    $(call Expect-Vars,_v=${_e})
    $(call Sub-Var,_v,-3)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Shell-Var)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Shell-Var,test-var-name))
  $(call Expect-Vars,_v=_test_var_name)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Are-Equal)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _val1 := value)
  $(eval _val2 := ${_val1})
  $(if $(call Are-Equal,${_val1},${_val2}),
    $(call PASS,Values ${_val1} and ${_val2} are equal)
  ,
    $(call FAIL,Values ${_val1} and ${_val2} SHOULD be equal)
  )

  $(eval _val2 := ${_val1}-not)
  $(if $(call Are-Equal,${_val1},${_val2}),
    $(call FAIL,Values ${_val1} and ${_val2} SHOULD NOT be equal)
  ,
    $(call PASS,Values ${_val1} and ${_val2} are not equal)
  )

  $(eval _val2 := different)
  $(if $(call Are-Equal,${_val1},${_val2}),
    $(call FAIL,Values ${_val1} and ${_val2} SHOULD NOT be equal)
  ,
    $(call PASS,Values ${_val1} and ${_val2} are not equal)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Lower)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Lower,AbCdEF))
  $(call Expect-Vars,_v=abcdef)

  $(eval _v := $(call To-Lower,"A123neq&bCD"))
  $(call Expect-Vars,_v=a123neq&bcd)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,To-Upper)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-Vars
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _v := $(call To-Upper,AbCdEF))
  $(call Expect-Vars,_v=ABCDEF)

  $(eval _v := $(call To-Upper,"A123neq&bCD"))
  $(call Expect-Vars,_v=A123NEQ&BCD)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Is-Not-Defined)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Mark-Step,Verify detection of undefined variable.)
  $(eval _v := not-defined)
  $(call Test-Info,Var _v is: $(flavor ${_v}))
  $(eval _r := $(call Is-Not-Defined,${_v}))
  $(call Test-Info,Is-Not-Defined returned:${_r})
  $(if $(call Is-Not-Defined,${_v}),
    $(call PASS,Is-Not-Defined says "${_v}" is not defined.)
  ,
    $(call FAIL,Is-Not-Defined says "${_v}" is defined.)
  )

  $(call Mark-Step,Verify detection of defined variable.)
  $(eval _v := is-defined)
  $(eval ${_v} :=)
  $(call Test-Info,Var _v is: $(flavor ${_v}))
  $(eval _r := $(call Is-Not-Defined,${_v}))
  $(call Test-Info,Is-Not-Defined returned:${_r})
  $(if $(call Is-Not-Defined,${_v}),
    $(call FAIL,Is-Not-Defined says "${_v}" is not defined.)
  ,
    $(call PASS,Is-Not-Defined says "${_v}" is defined.)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

define _Require-Callback

endef

$(call Declare-Test,Require)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := expect-tests.Expect-List
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _a :=)
  $(eval _b :=)
  $(eval _c :=)
  $(eval _d :=)

  $(call Mark-Step,Verify required variables exist.)
  $(eval _u := $(call Require,_a _b _c _d))
  $(if ${_u},
    $(call FAIL,Require returned:${_u})
  ,
    $(call PASS,Require returned an empty list.)
  )

  $(call Mark-Step,Verify required variable _z does not exist.)
  $(eval _u := $(call Require,_a _x _z _d))
  $(call Test-Info,Require returned:${_u})
  $(if ${_u},
    $(call Expect-List,${_u},_x _z)
  ,
    $(call FAIL,Require returned an empty list when should have been "_x _z")
  )

  $(eval undefine _a)
  $(eval undefine _b)
  $(eval undefine _c)
  $(eval undefine _d)

  $(call Mark-Step,Verify list of required variables no longer not exist.)
  $(eval _u := $(call Require,_a _b _c _d))
  $(call Test-Info,Require returned:${_u})
  $(if ${_u},
    $(call Expect-List,${_u},_a _b _c _d)
  ,
    $(call FAIL,\
      Require returned an empty list when should have been "_a _b _c _d")
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,Compare-Strings)
define _help
${.TestUN}
  Verify the helper macro:$(call Get-Test-Name,${.TestUN})
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _s1 := abc)
  $(eval _s2 := abc)

  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := xxx)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call PASS,Strings _s1 and _s2 are not the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := abc def)
  $(eval _s2 := abc def)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := abc xxx)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call PASS,Strings _s1 and _s2 are not the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := abc)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(if $(filter d,$(word 1,${_r})),
      $(call PASS,Strings _s1 and _s2 are different lengths.)
      $(if $(filter -1,$(word 2,${_r})),
        $(call PASS,Difference in lengths is correct.)
      ,
        $(call FAIL,Difference was $(word 2,${_r}). Should be -1.)
      )
    ,
      $(call FAIL,Difference in length was not detected.)
    )
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := abc def)
  $(eval _s2 := abc)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}")
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(if $(filter d,$(word 1,${_r})),
      $(call PASS,Strings _s1 and _s2 are different lengths.)
      $(if $(filter 1,$(word 2,${_r})),
        $(call PASS,Difference in lengths is correct.)
      ,
        $(call FAIL,Difference was $(word 2,${_r}). Should be 1.)
      )
    ,
      $(call FAIL,Difference in length was not detected.)
    )
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := This is a line.)
  $(eval _s2 := This is a line.)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}".)
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call FAIL,Strings _s1 and _s2 should have been the same.)
  ,
    $(call PASS,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := this is a line.)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}".)
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call PASS,Strings _s1 and _s2 are not the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval _s1 := This is a line)
  $(call Mark-Step,Comparing: "${_s1}" and "${_s2}".)
  $(call Compare-Strings,_s1,_s2,_r)
  $(if ${_r},
    $(call PASS,Strings _s1 and _s2 are not the same.)
  ,
    $(call FAIL,Strings _s1 and _s2 are the same.)
  )

  $(eval undefine _s1)
  $(eval undefine _s2)

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
