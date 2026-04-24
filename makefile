#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the helpers.
#----------------------------------------------------------------------------
#DEBUG=1

TmpTestPath := ${CURDIR}/tmp/test-helpers
LOG_PATH := ${TmpTestPath}/log
LOG_FILE := test-helpers.log

STICKY_PATH := ${TmpTestPath}/sticky

# DEBUG := 1

MakeTL := Run the test suites to test the helpers.

# VERBOSE is required because some tests verify verbose output. If VERBOSE is
# not set, the test output is not verbose and the tests fail.
VERBOSE=1
MAKEFLAGS += --warn-undefined-variables

include helpers.mk

$(call Enable-Log-File)

$(call Info,CorePath: ${CorePath})
$(call Info,CoreVar: ${CoreVar})

$(call Use-Segment,test-helpers,,Included for testing.)

$(call Run-Suites,${SUITES_PATH},${CASES})

$(call Display-Segs)

$(call Attention,Makefile Seg:${Seg})
$(call Attention,Makefile SegUN:${SegUN})
$(call Attention,Makefile SegID:${SegID})
clean:
> rm -rf ${TmpTestPath}

__h := $(or \
  $(call Is-Goal,help-${Seg}), \
  $(call Is-Goal,help-${SegUN}), \
  $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Defining ${__h} for:${Seg} SegUN:${SegUN})
define __help
Makefile: ${Seg}
Usage: make [<option>=<value> ...] [<goal> [<goal> ...]]

NOTE: This help is displayed if no goal is specified.

This make file is used to run test suites for testing the helpers and the test helpers.

The sticky variable CASES defines which tests are run. See help-CASES for more information.

Use the test goal. See help-test-helpers for more information.

endef
${__h} := ${__help}
endif
$(call Resolve-Help-Goals)
