#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use this to help test macros and variables.
#-----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
$(call Verbose,$(call Last-Segment-Basename) UN:${LastSegUN})
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,\
  Test helpers for testing makefile segments and macros.)
# -----

DEFAULT_SUITES_PATH := test-suites

define _help
Makefile segment: ${Seg}.mk

This make segment provides test support macros. These are designed to run before any goals are processed and when makefile segments are loaded. The concept is similar to that of a C preprocessor.

Definitions:
Test suite:
  A collection of tests which are closely related. A test suite should begin by setting up an environment in which the tests are executed. On completion of the tests the environment should then be torn down to avoid corrupting the environment for subsequent test suites or normal development. A test suite should NOT be dependant upon conditions created by any other test suite. HOWEVER, a test suite can require that other test suites pass before running any additional tests. A required test suite is termed a
  prerequisite or Prereq. If a Prereq test suite did not pass an error is reported and the test run is terminated. This helps avoid cascading failures in a test run. For a test suite Prereqs are specified using the variable <suite>.Prereqs.

Test or test case:
  A specific test in a test suite. Each test should begin with a setup and end with a teardown. A test should first verify preconditions to ensure the environment has been setup properly for the test and to ensure previous tests have not corrupted the environment. A test should not rely upon conditions from a previous test and should not leave any artifacts to clutter the test environment or confuse subsequent tests. A test should be able to be executed atomically. Like with a test suite, a test can require other test(s) pass beforehand which helps avoid cascading failures. The required tests are termed prerequisite or Prereq tests. For a test Prereqs are specified using the variable <test>.Prereqs.

Test step:
  A single step in a test. This is reset at the beginning of a test.

Test context:
  Different contexts <ctx> are defined for a test run. These are:
    Declared
      A manifest is generated to describe all test suites and tests which have been declared. This is also used to assign IDs to suites and tests.
    Session
      A manifest is generated to describe all test suites and tests which were run as part of the session. Statistics for all tests ran in the session are maintained.
    Run
      A manifest is generated to describe all test suites and tests executed in a test run.
    Prereq
      A manifest is generated to describe all the test suites and tests specified as test prerequisites. This manifest is updated as prerequisites are run. Test results for this context are reset each time a test's prerequisites are run.
    Undo
      The Undo context is provided so that the FAIL result of the last test step can be undone (using Undo-FAIL). This is useful when testing the test helpers themselves to verify they will issue a FAIL appropriately. NOTE: Only a FAIL can be undone.
    <suite>
      This describes a single test suite. The context is referenced using a suite name (SuiteN).
    <test>
      This describes a single test. The context is referenced using a unique test name (TestUN or .SuiteN.TestN).

The active context:
  The active context represents the currently running test. This context is used to update all the other contexts. Passing an empty parameter to the context related macros specifies the active context. The active context is initialized by Begin-Test. All active context variables have a dot (.) as the first character.

Manifests:
  The Session, Prereq and Run contexts are described using a test manifest. In the case of a Session context the manifest details the suites and tests which have been declared. In the case of the Run context the manifest represents the list of suites and tests to be run. In the case of a Prereq context the manifest represents the prereq tests which have been run. The Session manifest is updated as suites are declared. The Run manifest is updated based upon the  contents of the CASES sticky variable. A manifest contains:
  <ctx>.SuiteC
    The number of test suites.
  <ctx>.SuiteL
    The list of test suites.
  <ctx>.TestC
    The number of tests.
  <ctx>.TestL
    The list of tests.

Test results:
  Each contest has a corresponding set of results. Results are referenced using a context name (ctx). Test results are updated at the beginning and end of a test or when a PASS or FAIL is reported. The various attributes are:
  <ctx>.ID
    An ID number assigned to the context when declared.
  <ctx>.Running
    Non-active indicates tests in the context are running.
  <ctx>.Completed
    Non-active indicates all tests for the context have completed.
  <ctx>.Failed
    A flag to indicate one or more test steps in the context have failed.
  <ctx>.CompletedTestsC
    The number of tests in the context which have completed.
  <ctx>.CompletedTestsL
    The list of completed tests.
  <ctx>.StepC
    The number of steps executed.
  <ctx>.PassedStepsC
    The number of passing test steps in the context.
  <ctx>.FailedStepsC
    The number of failing test steps in the context.
  <ctx>.FailedStepL
    The list of failed steps.

Test implementation recommendations:
  For consistency and to help avoid naming conflicts each test suite should be contained in a single makefile segment. The name of the segment ($${SegUN}) can then be passed to Declare-Suite to serve as the suite name (SuiteN). This is most important when using Use-Segment to load test suites to avoid loading the same suite more than once. Declare-Test uses .SuiteN as a prefix for naming all of the tests included contained within a suite.

  Each test in a test suite should be a macro and declared using Declare-Test making it possible for other tests to reference it as a prerequisite. This is most important when tests have prerequisites which are contained in other test suites. A test suite template is provided in suite-template.mk to illustrate this approach.

  A test should not call another test. Instead, other tests should be listed as prerequisites.

  All test suites in a test run should be contained within the same directory pointed to by the command line option SUITES_PATH.

endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,StickVars,Sticky command line variables.)

_var := SUITES_PATH
$(call Sticky,${_var},${DEFAULT_SUITES_PATH})
define _help
(Sticky) ${_var} = ${${_var}}
  The path to the directory containing the test suites to run.
  Default: DEFAULT_SUITES_PATH = ${DEFAULT_SUITES_PATH}
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := CASES
$(call Sticky,${_var},$(call Basenames-In,${SUITES_PATH}/*.mk))
define _help
(Sticky) ${_var} = ${${_var}}
  The list of test cases to run. This defaults to all of the makefile segments in the directory indicated by SUITES_PATH. To use this on the make command line enclose the test suite list in quotes. NOTE: All of the test suites must exist as makefile segments in the SUITES_PATH directory.

  The make wildcard character "%" is supported. In other words this can be used to match all test names matching the same pattern.

  Tests in a suite can be limited to one or more tests using the <suite>.<test>[+<test>...] notation. This relies upon each test suite defining a list of available tests. This variable must be named <suite>.TestL.
  Examples:
    Run all tests in the SUITES_PATH directory. NOTE: This does not change the previously saved sticky value.
      CASES=""
    Run all tests in suite1 and suite2.
      CASES="suite1 suite2"
    Run only test1 and test2 in suite1.
      CASES="suite1.test1+test2"
    Run all tests in the current segment context.
      CASES="."
    Run only test1 from current segment context.
      CASES=".test1"
    Run all tests having the same prefix in the current segment context.
      CASES=".test%"
    Run all tests having the same prefix in suite1 and suite2.
      CASES="suite1.test% suite2.test%"
    Run all tests matching any of multiple prefixes in suite1.
      CASES="suite1.test%+ts_%"
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,Options,Testing command line options.)

_var := SKIP_PREREQS
${_var} :=
define _help
${_var}
  When not empty prerequisite tests will not be executed. Their corresponding segments are still loaded.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PAUSE_ON_FAIL
${_var} :=
define _help
${_var}
  When not empty execution will pause any time a FAIL is reported.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,Context,Active test context.)

# Testing context variables.
_var := RunContext
${_var} :=
define _help
${_var}
  The context in which a test is being run. This is either Run or Prereq.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .SuiteN
${_var} :=
define _help
${_var}
  The name of the test suite being initialized or running. This is used to reference suite specific attributes (i.e. establish suite context). This is set by Declare-Suite so context is correct when initializing a test suite. This is also set by Begin-Test so that context is correct for a running test. NOTE: This is expected to equal the segment name of the test suite.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .SuiteID
${_var} :=
define _help
${_var}
  The ID of the test suite being initialized or running.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .TestN
${_var} :=
define _help
${_var}
  The name of the test being declared or running. This is used to reference test specific attributes (i.e. establish test context). This is set by Declare-Test so context is correct when initializing a test. This is also set by Begin-Test so that context is correct for a running test.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .TestID
${_var} :=
define _help
${_var}
  The ID of the test being initialized or running.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .TestUN
${_var} :=
define _help
${_var}
  The unique name of the test declared or running. The unique name is defined using the suite and test names in a dot format. e.g. .SuiteN.TestN. This is used to reference test specific attributes (i.e. establish test context). This is set by Declare-Test so context is correct when initializing a test. This is also set by Begin-Test so that context is correct for a running test.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := .StepC
${_var} :=
define _help
${_var}
  The running count of test steps.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := Self
${_var} :=
define _help
${_var}
  Establishes current context. This can be either a test suite or a test. This is used to make it clear when a suite or test is referencing itself.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,TestInfo,Test information.)

# Macros
_macro := Get-Suite-Name
define _help
${_macro}
  Returns the suite name from a dotted <suite>.<test> reference.
  Parameters:
    1 = The test reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 1,$(subst ., ,$(1)))

_macro := Get-Test-Name
define _help
${_macro}
  Returns the test name from a dotted <suite>.<test> reference.
  Parameters:
    1 = The test reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 2,$(subst ., ,$(1)))

_macro := Test-Info
define _help
${_macro}
  Display a test message in a parsable format. This shows the test number along with the test message.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Info,${.SuiteID}:${.TestID}:${.StepC}:$(strip $(1)))
endef

_macro := Mark-Step
define _help
${_macro}
  Display a message for the current step to mark the beginning of a series of related steps.
  Parameters:
    1 = The message for the test step.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Log-Message,step,.... $(1))
endef

$(call Add-Help-Section,TestLogging,Logging test results.)

_macro := Log-Result
define _help
${_macro}
  Display the result of a test step.
  Parameters:
    1 = A four character prefix for the result message. Typically this is PASS or FAIL since this is called by those macros.
    2 = The message for the result.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Inc-Var,.StepC)
  $(call Log-Message,$(1),${.SuiteID}:${.TestID}:${.StepC}:$(2))
endef

_macro := Record-PASS
define _help
${_macro}
  Record a PASS test step result.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Inc-Var,.PassedStepsC)
  $(eval .StepFailed :=)
endef

_macro := Record-FAIL
define _help
${_macro}
  Record a FAIL test step result.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(eval Undo.FailedStepsC := ${.FailedStepsC})
  $(eval Undo.FailedStepsL := ${.FailedStepsL})
  $(eval Undo.Failed := ${.Failed})
  $(call Inc-Var,.FailedStepsC)
  $(eval .StepFailed := 1)
  $(eval .FailedStepsL += ${.SuiteN}:${.TestN}:${.SuiteID}:${.TestID}:${.StepC})
  $(eval .Failed := 1)
endef

$(call Add-Help-Section,Results,Recording and handling test results.)

_macro := Undo-FAIL
define _help
${_macro}
  Undo the previous step if it FAILED and instead record it as a PASS. This is useful for verifying conditions which are expected to report a failure.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${.StepFailed},
    $(call Test-Info,Undoing previous step failure.)
    $(eval .FailedStepsC := ${Undo.FailedStepsC})
    $(eval .FailedStepsL := ${Undo.FailedStepsL})
    $(eval .Failed := ${Undo.Failed})
    $(call Record-PASS)
  )
endef

_var := ExpectedResultsL
${_var} :=
define _help
${_var}
  The list of PASS or FAIL results to verify. Each call to PASS or FAIL advances to the next result in the list. The results are verified in the order in which they are specified in this list. e.g. FAIL PASS PASS FAIL PASS Expects a FAIL followed by a PASS followed by two PASSEs and finally a FAIL.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_macro := Verify-Result
define _help
${_macro}
  This is called by either PASS or FAIL when ExpectedResultL is not active. As each result is verified it is removed from the head of the list. The message for the result is logged.

  NOTE: If the expected results list is active then an error is emitted.
  Parameters:
    1 = The step result -- either PASS or FAIL.
    2 = The message for the result.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Result:$(1) Msg:$(call To-String,$(2)))
  $(if ${ExpectedResultsL},
    $(if $(filter $(1),$(word 1,${ExpectedResultsL})),
      $(call Log-Result,PASS,$(1):$(2))
      $(call Record-PASS)
    ,
      $(call Log-Result,FAIL,$(1):$(2))
      $(call Record-FAIL)
    )
    $(eval ExpectedResultsL := \
      $(wordlist 2,$(words ${ExpectedResultsL}),${ExpectedResultsL}))
  ,
    $(call Signal-Error,Call to Verify-Result when no results are expected.)
  )
  $(call Exit-Macro)
endef

_macro := PASS
define _help
${_macro}
  Display a test passed message. If results are expected the PASS result is verified using Verify-Result.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${ExpectedResultsL},
    $(call Verify-Result,$(0),$(1))
  ,
    $(call Log-Result,PASS,$(1))
    $(call Record-PASS)
  )
endef

_macro := FAIL
define _help
${_macro}
  Display a test failed message. This also flags the current test and suite as having failed. If results are expected the FAIL result is verified using Verify-Result.
  Command line options:
    PAUSE_ON_FAIL
      When not empty pause test execution.
  Parameters:
    1 = The message to display.
    2 = When not empty this parameter signals that the tests should be terminated. This is done by calling Signal-Error.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${ExpectedResultsL},
    $(call Verify-Result,$(0),$(1))
  ,
    $(call Log-Result,FAIL,$(1))
    $(call Record-FAIL)
    $(if ${PAUSE_ON_FAIL},
      $(call Pause)
    )
    $(if $(2),
      $(call Signal-Error,Exiting because of failure.,exit)
    )
  )
endef

$(call Add-Help-Section,Expects,Verifying expected results and variable values.)

_var := Differences
${_var} := 1
define _help
${_var}
  This variable contains the list of detected differences between expected values and actual values.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})


# NOTE: The expect macros should not use Enter-Macro or Exit-Macro because
# they could influence other tests.

_macro := Set-Expected-Results
define _help
${_macro}
  Sets a list of test step results to be verified when PASS or FAIL are called. This is useful when a FAIL result is actually an indication that a test step passed.
  Parameters:
    1 = The list of PASS and FAIL results to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(eval ExpectedResultsL := $(1))
endef

_macro := Expect-Vars
define _help
${_macro}
  Steps through a list of <var>:<value> pairs and verifies the <var> has a value equal to <value>. PASS or FAIL messages are emitted accordingly.
  Parameters:
    1 = The list of <var>:<value> pairs. The pair must be separated with a equal (=) and the <value> cannot contain any spaces.
    2 = An optional delimiter. This is provided for situations where the normal delimiter (=) is contained within the expected value.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if $(2),
    $(eval __d := $(2))
  ,
    $(eval __d := =)
  )
  $(foreach _e,$(1),
    $(eval _ve := $(subst ${__d},${Space},${_e}))
    $(call Verbose,(${_ve}) Expecting:($(word 1,${_ve}))=($(word 2,${_ve})))
    $(call Verbose,Actual:(${$(word 1,${_ve})}))
    $(eval Differences := )
    $(if $(word 2,${_ve}),
      $(if $(filter ${$(word 1,${_ve})},$(word 2,${_ve})),
        $(call PASS,Expecting:(${_e}))
      ,
        $(call FAIL,Expecting:(${_e}) actual (${$(word 1,${_ve})}))
        $(eval Differences += ${_e}:${$(word 1,${_ve})})
      )
    ,
      $(if $(strip ${$(word 1,${_ve})}),
        $(call FAIL,Expecting:(${_e}) actual (${$(word 1,${_ve})}))
        $(eval Differences += ${_e}:${$(word 1,${_ve})})
      ,
        $(call PASS,Expecting:(${_e}))
      )
    )
  )
endef

_macro := Expect-List
define _help
${_macro}
  Verifies a list matches an expected list by stepping through the expected list and verifying each word of the list being verified matches. Only the words in the expected list are verified -- meaning the list being verified can be longer than the expected list. Words that do not match produce an error message.

  NOTE: The list can be a typical list or can be a sentence with each word separated by spaces.
  Parameters:
    1 = The expected list.
    2 = The list to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Test-Info,Expecting:$(1))
  $(call Test-Info,Actual:$(2))
  $(eval __le := $(words $(1)))
  $(eval __la := $(words $(2)))
  $(if $(filter ${__le},${__la}),
    $(eval _index := 0)
    $(eval Differences := )
    $(foreach _w,$(1),
      $(call Inc-Var,_index)
      $(call Verbose,Checking word at ${_index} = ${_w})
      $(if $(filter ${_w},$(word ${_index},$(2))),
        $(call Verbose,${_w} = $(word ${_index},$(2)))
      ,
        $(eval Differences += ${_index})
      )
    )
    $(if ${Differences},
      $(call Test-Info,Lists do not match.)
      $(call Test-Info,Differences at: ${Differences})
      $(foreach _i,${Differences},
        $(call FAIL,\
          Expected:($(word ${_i},$(1))) Found:($(word ${_i},$(2))))
      )
    ,
      $(call PASS,Lists match.)
    )
  ,
    $(call FAIL,List lengths are not the same.)
  )
endef

_macro := Expect-String
define _help
${_macro}
  A synonym for Expect-List for clarity when checking strings.
  Parameters:
    1 = The expected string,
    2 = The string to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Verbose,Expecting:$(1))
  $(call Verbose,Actual:$(2))
  $(call Expect-List,$(1),$(2))
endef

$(call Add-Help-Section,ExpectedMessages,Expected messages.)

ExpectedMessage :=
TestingExpect :=
MatchFound :=
MatchCount := 0
MismatchFound :=
MismatchCount := 0
MismatchList :=

define __Check-Message
  $(if ${TestingExpect},
  ,
    $(eval TestingExpect := 1)
    $(call Inc-Var,MessageCount)
    $(eval MismatchList := )
    $(eval _i := 0)
    $(foreach _expected,${ExpectedMessage},
      $(call Inc-Var,_i)
      $(eval _actual := $(word ${_i},$(1)))
      $(if $(filter ${_expected},${_actual}),
      ,
        $(eval MismatchList += ${_expected}:${_actual})
      )
    )
    $(if ${MismatchList},
      $(eval MismatchFound := 1)
      $(call Inc-Var,MismatchCount)
    ,
      $(eval MatchFound := 1)
      $(call Inc-Var,MatchCount)
    )
    $(eval TestingExpect :=)
  )
endef

_macro := Expect-Message
define _help
${_macro}
  Use this to check all messages for a match with an expected message. When the expected message is detected then indicate the expect passed. Use Verify-Message to signal a pass or a fail.

  NOTE: This checks the entire log line including all trace information. This works by setting a callback to the expect filter using Set-Log-Callback.
  Parameters:
    1 = The expected message. The make wildcard character "%" can be used in
        individual words.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Test-Info,Expecting message:$(1))
  $(eval ExpectedMessage := $(1))
  $(eval MatchFound := )
  $(eval MatchCount := 0)
  $(eval MismatchFound := )
  $(eval MismatchCount := 0)
  $(eval MessageCount := 0)
  $(call Set-Message-Callback,__Check-Message)
endef

_macro := Verify-Message
define _help
${_macro}
  Verifies one or more messages matched the expected message. If a match occurred the specified number of times a PASS is emitted. Otherwise, a FAIL is emitted. This also clears the message callback.
  Parameters:
    1 = The optional number of times the message should have matched. If this is empty then at least one match is verified to have occurred.
    2 = The optional number of times the message should NOT have matched. If this is empty then message mismatches are not checked.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Set-Message-Callback)
  $(if ${MatchFound},
    $(if $(1),
      $(call Test-Info,Verifying the message matched $(1) times.)
      $(if $(filter ${MatchCount},$(1)),
        $(call PASS,The message matched ${MatchCount} times.)
      ,
        $(call FAIL,The message matched ${MatchCount} times.)
      )
    ,
      $(call PASS,The message matched ${MatchCount} times.)
    )
  ,
    $(call FAIL,No messages matched.)
  )
  $(if $(2),
    $(if ${MismatchFound},
      $(call Test-Info,Verifying the message mismatched $(2) times.)
      $(if $(filter ${MismatchCount},$(2)),
        $(call PASS,The message did not match ${MismatchCount} times.)
      ,
        $(call FAIL,The message did not match ${MismatchCount} times.)
      )
    ,
      $(call FAIL,No mismatched messages found.)
    )
  )
endef

$(call Add-Help-Section,ExpectedErrors,Expected warning and error messages.)

Expected_Warning :=
Actual_Warning :=

_macro := Oneshot-Warning-Callback
define _help
${_macro}
  Use this as a one-shot message callback which verifies the error message using Expect-String. This is designed to be called from Warn. Use Set-Warning-Callback to install it. Once called Oneshot-Warning-Callback disables itself.
  Parameters:
    1 = The error message to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Set-Warning-Callback)
  $(eval Actual_Warning := $(1))
  $(call Verbose,Actual warning:$(1))
  $(call Expect-String,${Expected_Warning},${Actual_Warning})
endef

_macro := Expect-Warning
define _help
${_macro}
  Enables (arm) Oneshot-Warning-Callback as a callback and sets Expected_Warning. The next call should be one which would generate the expected warning. That should be followed by a call to Verify-Warning.
  Parameters:
    1 = The expected warning.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Test-Info,Expecting warning:$(1))
  $(eval Expected_Warning := $(1))
  $(eval Actual_Warning :=)
  $(call Set-Warning-Callback,Oneshot-Warning-Callback)
endef

_macro := Verify-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Callback was called since calling Expect-Warning. A PASS is emitted if the error occurred. Otherwise a FAIL is emitted. This also disables the warning handler to avoid confusing subsequent tests.

  NOTE: For this to work Expect-Warning must be called to arm the one-shot handler.
  Parameters:
    1 = If not active then the handler should have been called. Otherwise, the handler should not have been called.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${Actual_Warning},
    $(call PASS,Warning occurred -- as expected.)
    $(call Expect-String,${Expected_Warning},${Actual_Warning})
  ,
    $(call FAIL,Warning did not occur.)
    $(call Set-Warning-Callback)
  )
endef

_macro := Expect-No-Warning
define _help
${_macro}
  Enables (arm) Oneshot-Warning-Callback as a callback and sets Expected_Warning to empty. The next call should be one which could generate a warning. That should be followed by a call to Verify-No-Warning.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(eval Expected_Warning :=)
  $(eval Actual_Warning :=)
  $(call Set-Warning-Callback,Oneshot-Warning-Callback)
endef

_macro := Verify-No-Warning
define _help
${_macro}
  Verifies Oneshot-Warning-Callback was not called since calling Expect-Warning. A PASS is emitted If the warning has NOT occurred. Otherwise a FAIL is emitted. This also disables the warning handler to avoid confusing subsequent tests.

  NOTE: For this to work Expect-Warning must be called to arm the one-shot handler.
  Parameters:
    1 = If not active then the handler should have been called. Otherwise, the handler should not have been called.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${Actual_Warning},
    $(call FAIL,Unexpected warning:${Actual_Warning})
  ,
    $(call PASS,Warning did not occur -- as expected.)
    $(call Set-Warning-Callback)
  )
endef

Expected_Error :=
Actual_Error :=

_macro := Oneshot-Error-Callback
define _help
${_macro}
  Use this as a one-shot error handler which verifies the error message using Expect-String. This is designed to be called from Signal-Error. Use Set-Error-Callback to install it. Once called Oneshot-Error-Callback disables itself.
  Parameters:
    1 = The error message to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(eval Actual_Error := $(1))
  $(call Set-Error-Callback)
endef

_macro := Expect-Error
define _help
${_macro}
  Enables (arm) Oneshot-Error-Callback as an error handler and sets Expected_Error.

  NOTE: Verify-Error must be called to verify that the error occurred and that the expected message was emitted.
  Parameters:
    1 = The expected error message.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Test-Info,Expecting error:$(1))
  $(eval Expected_Error := $(1))
  $(eval Actual_Error :=)
  $(eval Exit_On_Error :=)
  $(call Set-Error-Callback,Oneshot-Error-Callback)
endef

_macro := Verify-Error
define _help
${_macro}
  Verifies Oneshot-Error-Callback was called since calling Expect-Error. A PASS is recorded if the error occurred. Otherwise, a FAIL is recorded. This also disables the error handler to avoid confusing subsequent tests. The expected error is cleared.

  NOTE: For this to work Expect-Error must be called to arm the one-shot handler.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${Actual_Error},
    $(call PASS,Error occurred -- as expected.)
    $(call Expect-String,${Expected_Error},${Actual_Error})
    $(if ${Differences},
      $(call FAIL,An unexpected error occurred.)
    ,
      $(call PASS,Error occurred -- as expected.)
    )
    $(call Clear-Errors)
  ,
    $(call FAIL,Error did not occur.)
    $(call Set-Error-Callback)
  )
endef

_macro := Expect-No-Error
define _help
${_macro}
  Enables (arm) Oneshot-Error-Callback as an error handler and sets Expected_Error to empty. NOTE: Verify-No-Error must be called to verify that the error did not occur.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(eval Expected_Error :=)
  $(eval Actual_Error :=)
  $(call Set-Error-Callback,Oneshot-Error-Callback)
endef

_macro := Verify-No-Error
define _help
${_macro}
  Verifies Oneshot-Error-Callback was not called since calling Expect-No-Error. A PASS is recorded If the error has NOT occurred. Otherwise a FAIL is recorded. This also disables the error handler to avoid confusing subsequent tests.

  NOTE: For this to work Expect-No-Error must be called to arm the one-shot handler.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(if ${Actual_Error},
    $(call FAIL,Unexpected error:${Actual_Error})
  ,
    $(call PASS,Error did not occur -- as expected.)
    $(call Set-Error-Callback)
  )
endef

$(call Add-Help-Section,Reports,Report variable and context values.)

_macro := Display-Vars
define _help
${_macro}
  Display a list of variables and their values. This produces a series of messages formatted as <varname> = <varvalue>
  Parameters:
    1 = The list of variable names.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Vars:$(call To-String,$(1)))
  $(foreach _v,$(1),
    $(call Test-Info,$(_v) = ${$(_v)})
  )
  $(call Exit-Macro)
endef

#+
# Display the current context and the context for a segment.
#-
_macro := Report-Seg-Context
define _help
${_macro}
  Displays a series of messages for the current segment context as defined by Enter-Segment and Set-Segment-Context (see help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Display-Vars,
    SegID \
    Seg \
    SegV \
    SegP \
    SegF \
    SegTL \
    ${SegUN}.SegID \
    ${SegUN}.Seg \
    ${SegUN}.SegV \
    ${SegUN}.SegP \
    ${SegUN}.SegF \
    ${SegUN}.SegTL \
  )

  $(call Test-Info,\
  Get-Segment-File:SegID:$(call Get-Segment-File,${SegID}))
  $(call Test-Info,\
  Get-Segment-Basename:SegID:$(call Get-Segment-Basename,${SegID}))
  $(call Test-Info,\
  Get-Segment-Var:SegID:$(call Get-Segment-Var,${SegID}))
  $(call Test-Info,\
  Get-Segment-Path:SegID:$(call Get-Segment-Path,${SegID}))

  $(call Test-Info,\
  Get-Segment-File:${SegUN}.SegID:$(call Get-Segment-File,${${SegUN}.SegID}))
  $(call Test-Info,\
  Get-Segment-Basename:${SegUN}.SegID:$(call Get-Segment-Basename,${${SegUN}.SegID}))
  $(call Test-Info,\
  Get-Segment-Var:${SegUN}.SegID:$(call Get-Segment-Var,${${SegUN}.SegID}))
  $(call Test-Info,\
  Get-Segment-Path:${SegUN}.SegID:$(call Get-Segment-Path,${${SegUN}.SegID}))

  $(call Test-Info,Last-Segment-Id:$(call Last-Segment-Id))
  $(call Test-Info,Last-Segment-Basename:$(call Last-Segment-Basename))
  $(call Test-Info,Last-Segment-Var:$(call Last-Segment-Var))
  $(call Test-Info,Last-Segment-Path:$(call Last-Segment-Path))
  $(call Test-Info,Last-Segment-File:$(call Last-Segment-File))
  $(call Test-Info,MAKEFILE_LIST:$(MAKEFILE_LIST))
  $(call Exit-Macro)
endef

$(call Add-Help-Section,Context,Context management.)

_macro := Init-Context-Manifest
define _help
${_macro}
  Initialize or reset a context manifest.
  Parameters:
    1 = The context for which to init the manifest.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Context=$(1))
  $(eval $(1).SuiteC := 0)
  $(eval $(1).SuiteL :=)
  $(eval $(1).TestC := 0)
  $(eval $(1).TestL :=)
  $(call Exit-Macro)
endef

_macro := Init-Context-Results
define _help
${_macro}
  Initialize test results for a given context.
  Parameters:
    1 = The context for which to init the results. To initialize the "active" context do not pass this parameter.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Context=$(1))
  $(eval $(1).Completed :=)
  $(eval $(1).Failed :=)
  $(eval $(1).CompletedTestsC := 0)
  $(eval $(1).CompletedTestsL :=)
  $(eval $(1).StepC := 0)
  $(eval $(1).PassedStepsC := 0)
  $(eval $(1).FailedStepsC := 0)
  $(eval $(1).FailedStepsL :=)
  $(call Exit-Macro)
endef

_macro := Declare-Contexts
define _help
${_macro}
  Create and initialize context specific variables or each of the specified contexts. This initializes both the manifest and the test results for the context.
  Parameters:
    1 = The list of contexts being declared.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),ContextList:$(call To-String,$(1)))
  $(foreach _ctx,$(1),
    $(call Init-Context-Manifest,${_ctx})
    $(call Init-Context-Results,${_ctx})
  )
  $(call Exit-Macro)
endef

_macro := Add-Suite-To-Contexts
define _help
${_macro}
   Add a test suite to one or more context manifests.
  Parameters:
    1 = The list of contexts to add the suite to.
    2 = The name of the test suite.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),ContextList:$(call To-String,$(1)) Suite=$(2))
  $(foreach _ctx,$(1),
    $(if ${${_ctx}.SuiteC},
      $(if $(filter $(2),${${_ctx}.SuiteL}),
        $(call Signal-Error,\
          Suite $(2) has already been added to context ${_ctx}.)
      ,
        $(call Verbose,Adding suite $(2) to $(1) context.)
        $(call Inc-Var,${_ctx}.SuiteC)
        $(eval ${_ctx}.SuiteL += $(2))
      )
    ,
      $(call Signal-Error,\
        Attempt to add suite $(2) to un-declared context ${_ctx}.)
    )
  )
  $(call Exit-Macro)
endef

_macro := Add-Tests-To-Contexts
define _help
${_macro}
  Add one or more tests to one or more context manifests.
  Parameters:
    1 = The list of contexts to add the suite to.
    2 = The list of tests to add to the manifest.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),ContextList:$(call To-String,$(1)) Tests: $(2))
  $(foreach _ctx,$(1),
    $(if ${${_ctx}.TestC},
      $(foreach _t,$(2),
        $(if $(filter $(_t),${${_ctx}.TestL}),
          $(call Signal-Error,\
            Test $(_t) has already been added to context ${_ctx}.)
        ,
          $(call Verbose,Adding test ${_t} to ${_ctx} context.)
          $(call Inc-Var,${_ctx}.TestC)
          $(eval ${_ctx}.TestL += $(_t))
        )
      )
    ,
      $(call Signal-Error,\
        Attempt to add test $(2) to un-declared context ${_ctx}.)
    )
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,Results,Test result recording and reporting.)

_macro := Update-Test-Results
define _help
${_macro}
  Update test results for each specified context based upon the results of the current test which have been stored in the active context.
  Parameters:
    1 = The list of contexts for which to update the results.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),ContextList:$(call To-String,$(1)))
  $(if $(1),
    $(foreach _ctx,$(1),
      $(if ${_ctx}.ID,
        $(eval ${_ctx}.Failed := ${.Failed})
        $(call Inc-Var,${_ctx}.CompletedTestsC)
        $(eval ${_ctx}.CompletedTestsL += ${.TestUN})
        $(call Add-Var,${_ctx}.StepC,${.StepC})
        $(call Add-Var,${_ctx}.PassedStepsC,${.PassedStepsC})
        $(call Add-Var,${_ctx}.FailedStepsC,$(.FailedStepsC))
        $(eval ${_ctx}.FailedStepsL += ${.FailedStepsL})
      ,
        $(call Signal-Error,Invalid attempt to update an uninitialized context.)
      )
    )
  ,
    $(call Signal-Error,Invalid attempt to update the <active> context.)
  )
  $(call Exit-Macro)
endef

_macro := Report-Test-Results
define _help
${_macro}
  Display a summary of test results for each specified context.
  Parameters:
    1 = The list of contexts for which to report the results.
  Displays:
    <ctx>.CompletedTestsC
      This is also the total number of tests reported.
    <ctx>.PassedStepsC
      The total number of test steps reported as PASS.
    <ctx>.FailedStepsC
      The total number of test steps reported as FAIL.
    <ctx>.FailedStepsL
      The list of test steps reported as FAIL.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),ContextList:$(call To-String,$(1)))
  $(if $(1),
    $(foreach _ctx,$(1),
      $(call Line)
      $(call Test-Info,Results for context:${_ctx})
      $(call Test-Info,\
        Ran ${${_ctx}.StepC} steps in ${${_ctx}.CompletedTestsC} tests.)
      $(call Test-Info,\
        Total passed:${${_ctx}.PassedStepsC} Total failed:${${_ctx}.FailedStepsC})
      $(if ${QUIET},
        $(info \
          ${_ctx}:Total passed:${${_ctx}.PassedStepsC} Total failed:${${_ctx}.FailedStepsC})
        $(if ${${_ctx}.FailedStepsL},
          $(warning Context ${_ctx} ${${_ctx}.FailedStepsC} steps failed.)
          $(call Test-Info,Failed tests:)
          $(foreach _step,${${_ctx}.FailedStepsL},
            $(call Test-Info,${_step})
          )
        )
      )
    )
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,TestWrappers,Test entry and exit.)

_macro := Begin-Test
define _help
${_macro}
  Prepare to run a test and set the suite context. Previous errors are cleared.
  Parameters:
    1 = The unique name of the test (defined by Declare-Test).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),TestUN=$(1))

  $(call Clear-Errors)
  $(eval .TestUN := $(1))
  $(eval Self := $(1))
  $(eval .SuiteN := $(call Get-Suite-Name,$(1)))
  $(eval .SuiteID := ${${.SuiteN}.ID})
  $(eval .TestN := $(call Get-Test-Name,$(1)))
  $(eval .TestID := ${${.TestUN}.ID})
  $(call Init-Context-Results)
  $(eval ${Self}.Running := 1)

  $(call Line)
  $(call Test-Info,Begin test:$(1))

  $(call Exit-Macro)
endef

_macro := End-Test
define _help
${_macro}
  Mark the end of a test and do any end of test processing. This updates the testing stats and clears the suite context.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,End test:${Self})
  $(call Update-Test-Results,Session ${RunContext} ${.SuiteN} ${Self})
  $(call Report-Test-Results,${Self})
  $(eval ${Self}.Completed := 1)
  $(eval ${Self}.Running :=)
  $(eval .SuiteN :=)
  $(eval .SuiteID :=)
  $(eval .TestN :=)
  $(eval .TestID :=)
  $(eval .TestUN :=)
  $(eval .StepC :=)
  $(eval Self :=)
  $(call Line)
  $(call Exit-Macro)
endef

$(call Add-Help-Section,DeclareSuites,Declaring test suites and tests.)

_macro := Declare-Suite
define _help
${_macro}
  Initialize a test suite. This also establishes the test suite context.
  Parameters:
    1 = The test suite name (<suite>).
    2 = A message describing the test suite.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Suite=$(1) Msg=$(call To-String,$(2)))

  $(eval .SuiteN := $(1))
  $(eval Self := $(1))
  $(call Add-Suite-To-Contexts,Session Declared,${Self})
  $(eval ${Self}.ID := ${Declared.SuiteC})
  $(eval .SuiteID := ${${Self}.ID})
  $(call Declare-Contexts,${Self})

  $(call Line)
  $(call Test-Info,++++ $(1):$(2) ++++)

  $(call Exit-Macro)
endef

_macro := End-Declare-Suite
define _help
${_macro}
  End initialization of the current test suite. This clears the suite context so that proper context can be verified when using context specific variables.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0))
  $(call Test-Info,---- ${.SuiteN} ----)
  $(eval .SuiteN := )
  $(eval Self := )
  $(call Exit-Macro)
endef

_macro := Declare-Test
define _help
${_macro}
  Add a test to the list of tests and the current test suite. If the test has already been added a warning is issued. The test can then be uniquely referenced using the <suite>.<test> notation.
  Parameters:
    1 = The name of the test <test>.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Test=$(1))
  $(if ${.SuiteN},
    $(eval .TestUN := ${.SuiteN}.$(1))
    $(if $(filter ${.TestUN},${Declared.TestL}),
      $(call Warn,Name conflict with test ${.TestUN}.)
    ,
      $(call Test-Info,++++ Test:$(1))
      $(call Add-Tests-To-Contexts,Session Declared ${.SuiteN},${.TestUN})
      $(eval ${.TestUN}.ID := ${Declared.TestC})
    )
  ,
    $(call Signal-Error,Proper suite context has not been established.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,Run,Running tests.)

_macro := Run-Prerequisites
define _help
${_macro}
  Run a list of prerequisite tests. If a prerequisite test has already run it will be skipped. A reference to a prerequisite test has the format:
    <seg>.<test>
  The segment <seg> is loaded if it has not already been loaded.

  Prerequisite tests are run recursively. If a prerequisite test has prerequisites then its prerequisites are run first.

  Parameters:
    1 = The test for which the prerequisites should be run.
endef
help-${_macro} = $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),Test=$(1))
  $(if ${$(1).Prereqs},
    $(eval Prereq.Running := 1)
    $(call Verbose,$(1) prereqs:${$(1).Prereqs})
    $(foreach _prereq,${$(1).Prereqs},
      $(if ${${_prereq}.Completed},
        $(eval ${_prereq}.Running := )
        $(call Test-Info,Test ${_prereq} has already completed -- skipping.)
        $(if ${${_prereq}.Failed},
          $(call Test-Info,Test ${_prereq} FAILED previously.)
          $(eval Prereq.Failed := 1)
        )
      ,
        $(call Test-Info,Running prerequisite:${_prereq}.)
        $(eval _st := $(call Get-Suite-Name,${_prereq}))
        $(call Verbose,Prerequisite suite:${_st})

        $(if ${${_st}.SegID},
          $(call Verbose,The suite containing ${_prereq} is in use.)
        ,
          $(call Use-Segment,${_st},)
        )
        $(call Verbose,Prereq ${_prereq} origin:$(origin ${_prereq}))
        $(if $(filter undefined,$(origin ${_prereq})),
          $(call Signal-Error,Prereq test ${_prereq} is undefined.)
          $(eval Prereq.Failed := 1)
        ,
          $(if ${${_prereq}.Running},
            $(call Signal-Error,Dependency loop for ${_prereq} detected.)
          ,
            $(eval ${_prereq}.Running := 1)
            $(call Run-Prerequisites,${_prereq})
            $(eval RunContext := Prereq)
            $(if ${SKIP_PREREQS},
              $(call Test-Info,NOT running prereq:$(_prereq))
            ,
              $(call ${_prereq})
            )
            $(eval RunContext :=)
            $(if ${${_prereq}.Failed},
              $(call Test-Info,Test ${_prereq} FAILED -- skipping.)
              $(eval Prereq.Failed := 1)
            )
          )
        )
      )
    )
    $(eval Prereq.Running :=)
  )
  $(call Exit-Macro)
endef

_macro := Run-Tests
define _help
${_macro}
  Run each test in a list of tests. The individual tests will be executed only if they are included in the list of goals. Each test can declare a list of tests which need to be successfully run (PASS) before running the current test (prerequisites). This list is declared in a variable named <test>.Prereqs. Prerequisite tests do not need to be listed as a goal. If any of the prerequisite tests fail as indicated by the variable Test.Failed
  the current test is considered to have failed.
  Parameters:  Parameters:
    1 = The name of the list of tests to run.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Test list=$(1))
  $(if $(1),
    $(call Init-Context-Results,Run)
    $(foreach _t,${$(1)},
      $(if ${${_t}.Completed},
        $(call Test-Info,Test ${_t} has already completed -- skipping.)
      ,
        $(call Test-Info,Running test:${_t})
        $(call Test-Info,Test: ${_t})
        $(if ${${_t}.Prereqs},
          $(call Test-Info,Running prereqs for test:${_t})
          $(call Run-Prerequisites,${_t})
        )
        $(if ${Prereq.Failed},
          $(call Test-Info,Prerequisites for test ${_t} have failed -- skipping.)
        ,
          $(eval RunContext := Run)
          $(call ${_t})
          $(eval RunContext := )
        )
      )
    )
    $(call Report-Test-Results,Run)
  ,
    $(call Test-Info,No tests have been listed.)
  )
  $(call Exit-Macro)
endef

_macro := Create-Run-List
define _help
${_macro}
  Create the list of tests to be run and ensure all of the test suite segments for a given test list are in use. This calls Use-Segment to load a test suite.

  NOTE: This does not include prerequisite tests.
  Parameters:
    1 = The list of test suites to use. If this is active then the CASES
        variable is used. If the CASES variable is active then all suites in
        the directory indicated by SUITES_PATH are used. This supports the
        notation described for CASES, See help-CASES for more information.
  Output:
    Run.SuiteL
      The list of test suites used.
    Run.TestL
      The list of test cases to be run using the dot notation <suite>.<test>.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Test suites=$(call To-String,$(1)))
  $(call Declare-Contexts,Run)
  $(if $(1),
    $(eval _cases := $(1))
  ,
    $(if ${CASES},
      $(eval _cases := ${CASES})
    ,
      $(call Test-Info,Running all tests in:${SUITES_PATH})
      $(eval _cases := $(call Basenames-In,${SUITES_PATH}/*.mk))
    )
  )
  $(call Verbose,Parsing:${_cases})
  $(foreach _case,${_cases},
    $(eval _s := $(call Get-Suite-Name,${_case}))
    $(eval _t := $(call Get-Test-Name,${_case}))
    $(call Verbose,Parsing test(s):${_t})
    $(if ${_s},
      $(eval _suite := ${_s})
    ,
      $(eval _suite := ${Seg})
    )
    $(if $(filter undefined,$(origin ${_suite}.ID)),
      $(if $(wildcard ${SUITES_PATH}/${_suite}.mk),
        $(call Use-Segment,${_suite})
      ,
        $(call Signal-Error,Test suite does not exist: ${_suite})
      )
    ,
      $(call Verbose,Test suite ${_suite} has already been loaded.)
    )
    $(if ${_t},
      $(eval _tl := $(subst +, ,${_t}))
      $(call Verbose,Test list:${_tl})
      $(foreach _test,${_tl},
        $(call Verbose,Parsing test(s):${_test})
        $(eval _t2 := $(filter ${_suite}.${_test},${${_suite}.TestL}))
        $(call Verbose,Checking test:${_t2})
        $(if ${_t2},
          $(call Verbose,Adding test:${_t2})
          $(call Add-Tests-To-Contexts,Run,${_t2})
        ,
          $(call Signal-Error,\
            Test ${_test} is not a member of suite ${_suite})
        )
      )
    ,
      $(call Verbose,Adding suite ${_suite} to Run context.)
      $(call Add-Tests-To-Contexts,Run,${${_suite}.TestL})
    )
  )
  $(call Exit-Macro)
endef

_macro := Run-Suites
define _help
${_macro}
  Run each test suite specified by the CASES variable. Each test suite is contained in its own makefile segment and must be stand alone (i.e. not dependant upon conditions setup by other test suites). A test suite declares a list of tests which are to be executed as part of the suite. The suite then runs the tests using Run-Tests.

  NOTE: The test suites will not be run if any goal is help.
  Additional help for the suites and tests specified by the CASES variable can be displayed using the goals:
    help-Run.SuiteL
      Displays the help message for each of the suites in the run.
    help-Run.TestL
      Displays the help message for each of the tests in the run.
  Parameters:
    1 = The path to the directory containing the test suites.
    2 = The list of test cases to run. If this is active then the CASES variable is used. This supports the notation described for CASES, See help-CASES for more information.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
ifneq ($(call Is-Goal,help%),)
define ${_macro}
  $(call Enter-Macro,$(0),Path=$(1) Test-list=$(call To-String,$(2)))
  $(call Test-Info,Displaying help -- not running test suites.)
  $(call Declare-Contexts,Session Declared)
  $(eval Session.ID := ${SegID})
  $(eval Declared.ID := ${SegID})
  $(call Add-Segment-Path,$(1))
  $(call Create-Run-List,$(2))
  $(if $(call Is-Goal,help-Run.SuiteL),
    $(call Verbose,Building Run.SuiteL help list.)
    $(call More-Help,Run.SuiteL)
  )
  $(if $(call Is-Goal,help-Run.TestL),
    $(call Verbose,Building Run.TestL help list.)
    $(call More-Help,Run.TestL)
  )
  $(call Exit-Macro)
endef
else ifneq ($(call Is-Goal,test),)
define ${_macro}
  $(call Enter-Macro,$(0),Path=$(1) Test-list=$(call To-String,$(2)))
  $(call Add-Segment-Path,$(1))
  $(call Declare-Contexts,Session Declared Prereq)
  $(eval Session.ID := ${SegID})
  $(eval Declared.ID := ${SegID})
  $(call Create-Run-List,$(2))
  $(if ${Run.TestL},
    $(call Run-Tests,Run.TestL)
    $(call Report-Test-Results,Prereq Session)
  ,
    $(call Warn,No tests in the Run.TestL list.)
  )
  $(call Exit-Macro)
endef
endif

.PHONY: test
test:

# +++++
# Postamble
__h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
$(call Display-Help-List,${SegID})

Goals:
    test
      Use this goal to run all of the specified test suites.

endef
${__h} := ${__help}
endif
$(call Exit-Segment)
else # SegID exists
$(call Check-Segment-Conflicts)
endif # SegID
