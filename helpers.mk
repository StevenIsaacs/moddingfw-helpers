#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
__seg := $(basename $(lastword ${MAKEFILE_LIST}))
ifndef ${__seg}.SegID
# First time pre-init. This will be reset later by Set-Segment-Context.
Seg := ${__seg}
__p := $(subst /.,,$(dir $(realpath $(lastword ${MAKEFILE_LIST}))).)
SegUN :=  $(lastword $(subst /, ,${__p}))$(strip .${Seg})
SegID := $(words ${MAKEFILE_LIST})
${Seg}.SegID := ${SegID}

define _help
Make segment: ${Seg}.mk

This collection of variables and macros help simplify and improve consistency across different projects using make. Projects should include this makefile segment as early as possible.

NOTE: These macros and variables are NOT intended to be used as part of recipes. Instead, they are called as makefile segments are read by make. The concept is similar to that of a C preprocessor.

Naming conventions:
<seg>
  The name of a segment. This is used to declare segment specific variables and to derive directory and file names. As a result no two segments can have the same file name.
<seg>.mk
  The name of a makefile segment. A makefile segment is designed to be included from another file. These should be formatted to contain a preamble and postamble. See help-helpers for more information.
GLOBAL_VARIABLE
  Can be overridden on the command line. Sticky variables should have this form unless they are for a component in which case the should use the <seg>_VARIABLE form (below). See help-helpers for more information about sticky variables.
GlobalVariable
  Camel case is used to identify variables defined by the helpers. This is mostly helpers.mk.
Global_Variable
  This form is also used by the helpers to bring more attention to a variable.
<ctx>
  A specific context. A context can be a segment, macro or group of related variables.
<ctx>.VARIABLE
  A global variable prefixed with the name of specific context. These can be overridden on the command line. Context specific sticky variables should use this form.
<ctx>.Variable
  A global variable prefixed with the name of the segment defining the variable. These should not be overridden.
_private_variable or _Private_Variable or _PrivateVariable
  Make segment specific. Should not be used by other segments since these can be changed without concern for other segments.
Callable-Macro
  The name of a callable macro available to all segments.
_private-macro or _Private-Macro
                A private macro specific to a segment.
endef
help-$(Seg) := $(call _help)

# For generating text as part of a make file. This is used to cause the parser
# to not expand what follows. Call as $$.
. :=

define __Set-First-Path
  $(eval $(2) := )
  $(eval __seg := $(basename $(notdir $(1))))
  $(eval __p := $(subst /^,,$(dir $(abspath $(1)))^))
  $(eval $(2) := $(lastword $(subst /, ,${__p}.$(strip ${__seg}))))
endef

# Help messages cannot be accumulated until the helpers segment has been entered
# which depends upon other macros and vars being defined beforehand. Therefore,
# create a list of symbols to be added once segment entry has occurred.
__HelpQueue := ${Seg}

define __Queue-Help
  $(eval __HelpQueue += $(1))
endef

define __Queue-Help-Section
  $(eval help-${Seg}.$(1) := ---- $(1) ---- $(2))
  $(eval __HelpQueue += ${Seg}.$(1))
endef

_var := SegUNs
# For top level makefile.
$(call __Set-First-Path,$(firstword ${MAKEFILE_LIST}),${_var})
define _help
${_var}
  The list of pseudo unique names for all loaded segments. This can be indexed using SegID.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

define __Get-Segment-UN
  $(word $(1),${SegUNs})
endef

_macro := Add-Help
define _help
${_macro}
  Declare a help message and add it to the help list for the current context identified by SegID (see help-SegAttributes).
  Parameters:
    1 = The name of the variable or macro to declare help for.
endef
define ${_macro}
  $(eval __un := $(call __Get-Segment-UN,${SegID}))
  $(eval ${__un}.SegHL += $(1))
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})

_macro := Add-Help-Section
define _help
${_macro}
  Declare a help message section header and add it to the help list for the current context identified by SegID (see help-SegAttributes).
  Parameters:
    1 = The name of the section to declare help for.
    2 = The section description.
endef
define ${_macro}
  $(eval __un := $(call __Get-Segment-UN,${SegID}))
  $(eval __hn := ${__un}.$(1))
  $(eval help-${__hn} := ---- $(1) ----)
  $(eval help-${__hn} += $(2))
  $(call Add-Help, ${__hn})
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})

$(call __Queue-Help-Section,HelpL,\
  Use these macros to build and display help messages.)
$(call Add-Help,Add-Help-Section)
$(call Add-Help,${_macro})

_macro := Display-Help-List
define _help
${_macro}
  This macro can be called from a segment help to display the accumulated list of help messages.
  Parameters:
    1 = The segment ID for which to display the help list.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval __un := $(call __Get-Segment-UN,${SegID}))
  $(foreach _h,${${__un}.SegHL},

${help-${_h}})
endef

$(call __Queue-Help-Section,Options,Helper command line options.)

_var := PAUSE_ON_ERROR
${_var} :=
define _help
${_var}
  When not empty execution will pause any time an error is reported.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := STOP_ON_ERROR
${_var} :=
define _help
${_var}
  When not empty execution will exit when an error is reported.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Exit_On_Error
${_var} :=
define _help
${_var}
  When not empty execution will exit when an error is reported. This is the same as STOP_ON_ERROR but is ignored when testing.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,Vars,Helper variables.)

_var := .RECIPEPREFIX
${_var} := >
define _help
${_var} = ${${_var}}
  The ${_var} is changed because some editors, like vscode, don't handle tabs in make files very well. This also slightly improves readability.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

# NOTE: Bash is required because of some bash-isms being used.
_var := SHELL
${_var} := /bin/bash
define _help
${_var} = ${${_var}}
  Bash is required because of some bash-isms potentially being used in the helpers.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := True
${_var} := 1
define _help
${_var} = ${${_var}}
  When used in a conditional this evaluates to true. In make a non-empty value is true. This is provided to improve readability in conditionals.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := False
${_var} :=
define _help
${_var} = ${${_var}}
  When used in a conditional this evaluates to false. In make an empty value is false. This is provided to improve readability in conditionals.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := DefaultGoal
ifeq (${MAKECMDGOALS},)
  ${_var} := help-1
else
  ${_var} :=
endif
define _help
${_var} = ${${_var}}
  When there are no goals on the make command line the default goal is used. Normally, this is the first goal make encounters when parsing makefiles. The helpers changes this to display the help for the first makefile in the makefile list.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Goals
${_var} := ${DefaultGoal} ${MAKECMDGOALS}
define _help
${_var} = ${${_var}}
  This is the list of goals from the make command line.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := SubMake
ifeq (${MAKELEVEL},0)
  ${_var} := ${False}
else
  ${_var} := ${True}
endif
define _help
${_var} = ${${_var}}
  When non-empty this variable indicates make is being run from a makefile, a submake. There are some things a submake should not do such as change the log file variables.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := CorePath
${_var} := $(realpath $(dir $(word 1,${MAKEFILE_LIST})))
define _help
${_var} = ${${_var}}
  This is the path to the directory containing the top level makefile. In other words this is the path to the directory containing the first file in MAKEFILE_LIST.

  NOTE: If this is mounted in a container, mount as a read only volume and should not be written to.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := CoreDir
${_var} := $(notdir ${CorePath})
define _help
${_var} = ${${_var}}
  This is the name of the last directory in CorePath.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := CoreVar
${_var} := _$(subst -,_,$(CoreDir))
define _help
${_var} = ${${_var}}
  This is a bash compatible variable name for CoreDir.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := ContextPath
${_var} := $(realpath $(dir $(word 1,${MAKEFILE_LIST})))
define _help
${_var} = ${${_var}}
  This is the path to the directory from which make (the Core)was run.

  NOTE: If this is mounted in a container, mount as a read/write volume.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := ContextDir
${_var} := $(notdir ${ContextPath})
define _help
${_var} = ${${_var}}
  This is the name of the last directory in ContextPath.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := ContextVar
${_var} := _$(subst -,_,$(ContextDir))
define _help
${_var} = ${${_var}}
  This is a bash compatible variable name for ContextDir.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := HiddenPath
${_var} := ${ContextPath}/.${ContextDir}
define _help
${_var} = ${${_var}}
  The path to the directory containing hidden files.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := TmpDir
${_var} := ${ContextDir}
define _help
${_var} = ${${_var}}
  The name of the directory where temporary files such as log files and help messages are written to.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := TmpPath
${_var} := ${CURDIR}/tmp/${TmpDir}
$(shell mkdir -p ${${_var}})
define _help
${_var} = ${${_var}}
  The full path to the temporary directory.

  NOTE: On some systems files in the temporary directory are not persistent across reboots.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := LOG_DIR
${_var} ?= log
define _help
${_var} = ${${_var}}
  The name of the directory containing log files.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := LOG_PATH
${_var} ?= ${TmpPath}/${LOG_DIR}
define _help
${_var} = ${${_var}}
  The full path to the directory containing log files.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := LOG_FILE
${_var} ?=
define _help
${_var} = ${ContextDir}
  Use this variable on the make command line to enable message logging and set the name of the log file in the log file directory.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := LogFile
${_var} :=
define _help
${_var} = ${${_var}}
  The full path to the log file. This is set by the Enable-Log-File macro when LOG_FILE is set.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,BashStrings,For creating strings to be passed to bash.)

_var := NewLine
${_var} := nlnl
define _help
${_var} = ${${_var}}
  This variable is provided to embed a known pattern into strings which can then be replaced with a newline when the variable is exported to the environment when running a bash script.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

__empty :=
_var := Space
${_var} := ${__empty} ${__empty}
define _help
${_var} = ${${_var}}
  This is provided to embed a space in a variable which will be exported to the environment when running a bash script.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Comma
${_var} := ,
define _help
${_var} = ${${_var}}
  This is provided to embed a comma in a string so that it won't be parsed incorrectly and interpreted to be a parameter delimiter by make.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Dlr
${_var} := $
define _help
${_var} = ${${_var}}
  This is provided to embed a dollar sign in a variable which will be exported to the environment when running a bash script. Using this variable disables the normal make parsing of dollar signs.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,MakeTL,Top level make.)

_var := MakeTL
MakeTL ?= MakeTL is UNDEFINED.
define _help
${_var} := ${MakeTL}
  The one line description for the makefile which included the helpers. This must be defined before including helpers.mk.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,Stacks,For maintaining segment and macro context.)

_var := SegID_Stack
${_var} :=
define _help
${_var}
  This is a special variable containing the list of nested makefile segments using their segment IDs. This is used to save and restore segment context as segments are entered and exited.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Macro_Stack
${_var} := $(basename $(notdir $(word 1,${MAKEFILE_LIST})))
define _help
${_var}
  This is a special variable containing the list of macros and segments which have been entered using Enter-Macro and Enter-Segment. The last item on the stack is emitted with all messages.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Caller
${_var} := ${Macro_Stack}
define _help
${_var}
  This is the name of the file or macro calling a macro.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,Callback,Message handling, display and logging.)

_var := Message_Callback
${_var} :=
define _help
${_var}
  This variable is used to reference a macro which will be called when any message is emitted. This allows special handling of messages when they are reported.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Message_Safe
${_var} := 1
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the Message_Callback callback. The purpose is to avoid recursive calls to the callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Warning_Callback
${_var} :=
define _help
${_var}
  This variable is used to reference a macro which will be called when Warn is called. This allows special handling of warnings when they are reported.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Warning_Safe
${_var} := 1
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the Warning_Callback callback. The purpose is to avoid recursive calls to the callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Error_Callback
${_var} :=
define _help
${_var}
  This variable is used to reference a macro which will be called when Signal-Error is called. This allows special handling of errors when they are reported.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := Error_Safe
${_var} := 1
define _help
${_var}
  This variable is used as a semaphore to indicate when it is safe to call the Error_Callback callback. The purpose is to avoid recursive calls to the callback. The callback is safe when this variable is not empty.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call __Queue-Help-Section,Messaging,Message helpers.)

_var := DEBUG
${_var} ?=
define _help
${_var}
  Set this variable on the command line or a makefile segment to enable debug messages. If ${_var} is defined in a makefile segment setting ${_var} on the command line will override the previous setting.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := VERBOSE
${_var} ?=
define _help
${_var}
  Set this variable on the command line or a makefile segment to enable verbose messages. If ${_var} is defined in a makefile segment setting ${_var} on the command line will override the previous setting.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := QUIET
${_var} ?=
define _help
${_var} = ${_var}
  Set this variable on the command line to suppress console output. If QUIET is not empty then all messages except error messages are suppressed. They are still added to the message list and can still be displayed using the display-messages goal.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_macro := Div
define _help
${_macro}
  Use this macro to add a divider line between catenated messages.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}

endef

_macro := Log-Message
define _help
${_macro}
  Format a message string and display it. If a log file is specified, the message is also written to the log file.
  Parameters:
    1 = Four character message prefix.
    2 = The message.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval __msg := \
    $(strip $(1)):${Caller}:$(lastword ${Macro_Stack}):$(strip $(2)))
  $(if ${LogFile},
    $(file >>${LogFile},${__msg})
  )
  $(if ${QUIET},
  ,
    $(if $(filter $(lastword $(2)),${NewLine}),
      $(info )
    )
    $(info ${__msg})
  )
  $(if ${Message_Callback},
    $(if ${Message_Safe},
      $(eval Message_Safe :=)
      $(call ${Message_Callback},$(strip $(2)))
      $(eval Message_Safe := 1)
    ,
      $(eval __msg := \
        clbk:${SegUN}:$(lastword ${Macro_Stack}):$(strip \
          Recursive call to Message_Callback -- callback not called.))
      $(if ${LogFile},
        $(file >>${LogFile},${__msg})
      )
      $(info ${__msg})
    )
  )
  $(eval Messages = yes)
endef

_macro := To-String
define _help
  Convert a parameter to a string which can be displayed on one line of the log file. Normally, space separated words are treated as a list.
  Parameters:
    1 = The list of words to be treated as a string.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro}=$(subst ${Space},$${Space},$(strip $(1)))

_macro := Line
define _help
${_macro}
  Add a blank line or a line termination to the output.
  Uses:
    NewLine   The newline pattern is appended to the output.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(if ${LogFile},
    $(file >>${LogFile}, )
  )
  $(if ${QUIET},
  ,
    $(info )
  )
endef

_macro := Info
define _help
${_macro}
  Use this macro to add a message to a list of messages to be displayed by the display-messages goal. Info uses .... as a message prefix.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Log-Message,....,$(1))
endef

_macro := Attention
define _help
${_macro}
  Use this macro to flag a message as important. Important messages are prefixed with ATTN.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Log-Message,ATTN,$(1))
endef

_macro := Warn
define _help
${_macro}
  Display a warning message. Warning messages are prefixed with WARN.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Log-Message,WARN,$(1))
  $(if ${Warning_Callback},
    $(if ${Warning_Safe},
      $(eval Warning_Safe :=)
      $(call ${Warning_Callback},$(strip $(1)))
      $(eval Warning_Safe := 1)
    ,
      $(call Attention,\
        Recursive call to Warning_Callback -- callback not called.)
    )
  )
endef

_V:=n
_macro := Verbose
define _help
${_macro}
  Displays the message if VERBOSE has been defined. All verbose messages are automatically added to the message list. Verbose messages are prefixed with vrbs.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(if ${VERBOSE},
    $(call Log-Message,vrbs,$(1))
  )
endef
ifneq (${VERBOSE},)
_V:=v
endif

$(call __Queue-Help-Section,MacroContext,For maintaining macro context.)

define __Push-Macro
  $(if $(filter $(1),${Macro_Stack}),
    $(call Attention,Recursive call to macro $(1) detected.)
  )
  $(if ${Macro_Stack},
    $(eval Caller := $(lastword ${Macro_Stack}))
  ,
    $(eval Caller :=)
  )
  $(eval Macro_Stack += $(1))
  $(if ${DEBUG},
    $(call Log-Message, \
      $(words ${Macro_Stack})-->,${Macro_Stack})
    $(if ${Single_Step},$(call Step))
  )
endef

define __Pop-Macro
  $(if ${Macro_Stack},
    $(if ${DEBUG},
      $(call Log-Message, \
        <--$(words ${Macro_Stack}),Exiting:$(lastword ${Macro_Stack}))
    )
    $(eval Caller := )
    $(eval __l := $(words ${Macro_Stack}))
    $(call Dec-Var,__l)
    $(if $(filter ${__l},0),
      $(eval Macro_Stack := )
      $(call Attention,Macro stack is empty.)
    ,
      $(eval Macro_Stack := $(wordlist 1,${__l},${Macro_Stack}))
      $(if $(filter ${__l},1),
      ,
        $(call Dec-Var,__l)
        $(eval Caller := $(word ${__l},${Macro_Stack}))
      )
    )
  ,
    $(call Signal-Error,Macro call stack is empty.)
  )
endef

_macro := Enter-Macro
define _help
${_macro}
  Adds a macro name to the Macro_Stack. This should be called as the first line of the macro. If DEBUG is not empty then the list of parameters is logged.
  Parameter:
    1 = The name of the macro to add to the stack.
    2 = An optional list of parameters.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call __Push-Macro,$(1))
  $(if $(and ${DEBUG},$(2)),
    $(foreach __p,$(2),
      $(call Log-Message,parm,$(strip ${__p}))
    )
  )
endef

_macro := Exit-Macro
define _help
${_macro}
  Removes the last macro name from the Macro_Stack. This should be called as the last line of the macro.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call __Pop-Macro)
endef

$(call __Queue-Help-Section,DebugSupport,Rudimentary makefile debug support.)

_var := Single_Step
${_var} :=
define _help
${_var}
  This variable is used as a semaphore to indicate when single stepping messages is enabled.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_macro})

_macro := Enable-Single-Step
define _help
${_macro}
  When single step mode is enabled and DEBUG is not empty Step is called every time a macro is entered.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(eval Single_Step := yes)
  $(call Exit-Macro)
endef

_macro := Disable-Single-Step
define _help
${_macro}
  Disables single step mode.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(eval Single_Step :=)
  $(call Exit-Macro)
endef

_macro := Debug
define _help
${_macro}
  Emit a debugging message. All debug messages are automatically added to the message list. Debug messages are prefixed with dbug. This is disabled unless DEBUG is not empty.
  Debug messages are reserved for development. After development is complete either remove the Debug messages or change them to Verbose.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The message to display.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
ifneq (${DEBUG},)
define ${_macro}
  $(call Log-Message,dbug,$(1))
endef
MAKEFLAGS += --debug=vp --warn-undefined-variables
endif

_macro := Step
define _help
${_macro}
  Issues a step message and waits for the enter key to be pressed.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(shell read -r -p "Step: Press Enter to continue...")
endef

$(call __Queue-Help-Section,CallbackHandling,For message callbacks.)

_macro := Set-Message-Callback
define _help
${_macro}
  Install a message callback for when a Warn is issued. The callback should support one parameter which will be the message. To avoid recursive callbacks the variable Warning_Safe is used as a semaphore. If the variable is empty then the warning callback will NOT be called. Recursive callbacks are disallowed. To clear the callback simply call this macro with no parameters.
  Parameters:
    1 = The name of the macro to call when a message is called. To disable the current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval Message_Callback := $(1))
endef

$(call __Queue-Help-Section,Errors,For warning and error handling.)

_var := Errors
${_var} :=
define _help
${_var}
  When not empty this variable indicates one or more errors have been signaled and the variable ErrorList will contain a list of error messages.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := ErrorList
${_var} :=
define _help
${_var}
  This variable contains the list of errors that have been signaled.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_macro := Set-Warning-Callback
define _help
${_macro}
  Install a warning message callback for when a Warn is issued. The callback should support one parameter which will be the message.

  WARNING: A warning callback should not do any thing that could in turn trigger another warning. Doing so could result in a fatal infinite loop. To help mitigate this problem the variable Warning_Safe is used as a semaphore. If the variable is empty then the warning callback will NOT be called. Recursive callbacks are disallowed.
  Parameters:
    1 = The name of the macro to call when a message is called. To disable the current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Callback=$(1))
  $(eval Warning_Callback := $(1))
  $(call Exit-Macro)
endef

_macro := Set-Error-Callback
define _help
${_macro}
  Install a callback handler for when Signal-Error is called. The error handler should support one parameter which will be the error message.

  WARNING: An error handler should not do any thing that could in turn trigger an error. Doing so could result in a fatal infinite loop. To help mitigate this problem the variable Error_Safe is used as a semaphore. If the variable is empty then the error handler will NOT be called.
  Parameters:
    1 = The name of the macro to call when an error occurs. To disable the
        current handler do not pass this parameter or pass an empty value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Callback=$(1))
  $(eval Error_Callback := $(1))
  $(call Exit-Macro)
endef

_macro := Signal-Error
define _help
${_macro}
  Use this macro to issue an error message as a warning and signal a delayed error exit. The messages can be displayed using the display-errors goal. Error messages are prefixed with ERR!. If an error handler is connected (see Set-Error-Callback) and the Error_Safe variable is equal to 1 then the error handler is called with the error message as the first parameter.

  NOTE: This is NOT intended to be used as part of a recipe.
  Parameters:
    1 = The error message.
    2 = If not empty then exit after reporting the error.
  Command line options:
    STOP_ON_ERROR
      When not empty execution will stop when an  error is reported.
    PAUSE_ON_ERROR
      When not empty execution fill pause when an error is reported.
  Uses:
    Error_Callback = ${Error_Callback}
      The name of the macro to call when an error occurs.
    Exit_On_Error = ${Exit_On_Error}
      When not empty an error message is emitted and the run is halted. The callback can clear this to override the error.
    Error_Safe = ${Error_Safe}
      The handler is called only when this is equal to 1.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval ErrorList += ${NewLine}ERR!:${Caller}:$(1))
  $(call Log-Message,ERR!,$(1))
  $(eval Errors := yes)
  $(eval Exit_On_Error := ${STOP_ON_ERROR})
  $(call Verbose,Handler: ${Error_Callback} Safe:${Error_Safe})
  $(if ${Error_Callback},
    $(if ${Error_Safe},
      $(eval Error_Safe := )
      $(call Verbose,Calling ${Error_Callback}.)
      $(call Verbose,Message:$(1))
      $(call ${Error_Callback},$(1))
      $(eval Error_Safe := 1)
    ,
      $(call Warn,Recursive call to Signal-Error -- handler not called.)
    )
  )
  $(if $(or ${Exit_On_Error},$(2)),
    $(error Error:${SegUN}:$(1))
  ,
    $(warning Error:${SegUN}:$(1))
    $(if ${PAUSE_ON_ERROR},
      $(shell read -r -p "Press Enter to continue...")
    )
  )
endef

_macro := Clear-Errors
define _help
Reset the errors flag so that past errors won't influence subsequent decisions.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval Errors :=)
endef

_macro := Enable-Log-File
define _help
Enable logging messages to the log file.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(if ${LogFile},
  ,
    $(if ${LOG_FILE},
      $(shell mkdir -p ${LOG_PATH})
      $(eval LogFile := ${LOG_PATH}/${LOG_FILE})
      $(if $(filter ${SubMake},${True}),
        $(file >>${LogFile},++++++++ MAKELEVEL = ${MAKELEVEL} ++++++++)
      ,
        $(file >${LogFile},++++++++ ${ContextDir} log: $(shell date))
      )
    ,
      $(call Attention,LOG_FILE is undefined -- no log file.)
    )
  )
endef

_macro := Disable-Log-File
define _help
Disable logging messages to the log file.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(if ${LogFile},
    $(if $(filter ${SubMake},${True}),
      $(file >>${LogFile},-------- MAKELEVEL = ${MAKELEVEL} --------)
    ,
      $(file >${LogFile},-------- ${ContextDir} log: $(shell date))
    )
  )
  $(eval LogFile :=)
endef

#--------------

$(call __Queue-Help-Section,VarMacros,For manipulating variable values.)

_macro := Inc-Var
define _help
${_macro}
  Increment the value of a variable by 1.
  Parameters:
    1 = The name of the variable to increment.
  Returns:
    The value of the variable incremented by 1.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} + 1))
endef

_macro := Dec-Var
define _help
${_macro}
  Decrement the value of a variable by 1.
  Parameters:
    1 = The name of the variable to decrement.
  Returns:
    The value of the variable decremented by 1.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} - 1))
endef

_macro := Add-Var
define _help
  Add a value to a variable.
  Parameters:
    1 = The variable to which the value is added.
    2 = The value to add.
  Returns:
    The value of the variable increased by the value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} + $(2)))
endef

_macro := Sub-Var
define _help
  Subtract a value from a variable.
  Parameters:
    1 = The variable from which the value is subtracted.
    2 = The value to subtract.
  Returns:
    The value of the variable decreased by the value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(eval $(1):=$(shell expr ${$(1)} - $(2)))
endef

_macro := Are-Equal
define _help
${_macro}
  Compare two values and return a non-empty value if they are equal. Leading and trailing spaces are ignored.
  Parameters:
    1 = The first value.
    2 = The second value.
  Returns:
    If the two values are the same then the value is returned. Otherwise an empty value is returned.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(filter $(1),$(2))

_macro := To-Shell-Var
define _help
${_macro}
  Convert string to a format which can be used as a shell (${SHELL}) variable name.
  Parameters:
    1 = The string to convert to a variable name.
  Returns:
    A string which can be used as the name of a shell variable.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = _$(subst /,_,$(subst .,_,$(subst -,_,$(1))))

_macro := To-Lower
define _help
${_macro}
  Transform all upper case characters to lower case in a string.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(shell tr '[:upper:]' '[:lower:]' <<< $(1))

_macro := To-Upper
define _help
${_macro}
  Transform all lower case characters to upper case in a string.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(shell tr '[:lower:]' '[:upper:]' <<< $(1))

$(call __Queue-Help-Section,VarTesting,For checking variable contents.)

_macro := Is-Not-Defined
define _help
${_macro}
  Returns an non-empty value if a variable is not defined.
  Parameters:
    1 = The name of the variable to check.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(filter undefined,$(flavor $(1)))

_macro := Require
define _help
${_macro}
  Use this macro to verify variables are set.
  Parameters:
    1 = A list of required variables.
  Returns:
    A list of undefined variables.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(strip \
  $(call Enter-Macro,$(0),Required: $(1))
  $(call Verbose,Requiring defined variables:$(1))
  $(eval __r :=)
  $(foreach __v,$(1),
    $(call Verbose,Requiring: ${__v})
    $(if $(call Is-Not-Defined,${__v}),
      $(eval __r += ${__v})
      $(call Warn,${Caller} requires variable ${__v} must be defined.)
    )
  )
  $(call Exit-Macro)
  ${__r}
)
endef

define __mbof
  $(if $(filter ${$(1)},$(2)),
    $(call Verbose,$(1)=${$(1)} and is a valid option) 1
  ,
    $(call Signal-Error,Variable $(1)=${$(1)} must equal one of: $(2))
  )
endef

_macro := Must-Be-One-Of
define _help
${_macro}
  Verify a variable has a valid value. If not then issue a warning.
  Parameters:
    1 = The name to verify is in the list.
    2 = List of valid values.
  Returns:
    A non-empty string if the name is a member of the list.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),Name=$(1) Values:$(call To-String,$(2)))
  $(call __mbof,$(1),$(2))
  $(call Exit-Macro)
)
endef

_macro := Overridable
define _help
${_macro}
  Declare a variable which may be overridden. This mostly makes it obvious which variables are intended to be overridable. The variable is declared as a simply expanded variable only if it has not been previously defined. An overridable variable can be declared only once. To override the variable assign a value BEFORE Overridable is called or on the make command line.
  Parameters:
    1 = The variable name.
    2 = The value.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
OverridableVars :=
define ${_macro}
  $(call Enter-Macro,$(0),Var=$(1) Val=$(2))
  $(if $(filter $(1),${OverridableVars}),
    $(call Signal-Error,Var $(1) has already been declared.)
  ,
    $(eval OverridableVars += $(1))
    $(if $(call Is-Not-Defined,$(1)),
      $(eval $(1) := $(2))
    ,
      $(call Verbose,Var $(1) has override value: ${$(1)})
    )
  )
  $(call Exit-Macro)
endef

_macro := Compare-Strings
define _help
${_macro}
  Compare two strings and return a list of indexes of the words which do not match.  If the strings are identical then nothing is returned.If the lengths of the strings are not the same then the difference in lengths is returned as "d <diff>".
  NOTE: Multiple spaces are collapsed to a single space so it is not possible to detected a difference in the number of spaces separating the words of a string.
  Parameters:
    1 = The first string.
    2 = The second string.
    3 = The name of the variable in which to return the result of the compare.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(strip\
    String1=$(call To-String,$(1))\
    String2=$(call To-String,$(1))\
    Out=$(3)))
  $(eval __d := $(words ${$(1)}))
  $(call Sub-Var,__d,$(words ${$(2)}))
  $(if $(filter 0,${__d}),
    $(eval $(3) :=)
    $(eval __i := 0)
    $(foreach __w,${$(1)},
      $(call Inc-Var,__i)
      $(call Verbose,Checking words at:${__i})
      $(if $(filter ${__w},$(word ${__i},${$(2)})),
      ,
        $(call Verbose,Difference found.)
        $(eval $(3) += ${__i})
      )
    )
  ,
    $(call Verbose,String lengths differ by ${__d} words.)
    $(eval $(3) := d ${__d})
  )
  $(call Verbose,Returning:${$(3)})
  $(call Exit-Macro)
endef

#--------------

#++++++++++++++
# Makefile segment handling.
$(call __Queue-Help-Section,SegManagement,For managing segments.)

_var := SegAttributes
${_var} := SegID UserSegID SegUN Seg SegP SegD SegF SegV SegTL SegHL
define _help
${_var} = ${${_var}}
  Each makefile segment is managed using a set of attributes. The context for a given segment is prefixed by its unique name <segun>. The current context has no prefix.
    SegID or <segun>.SegID
      The ID for the segment. This is basically the index in MAKEFILE_LIST for the segment.
    UserSegID or <segun>.UserSegID
      The ID of the segment which used this segment. This is basically the index in MAKEFILE_LIST for the using segment.
    SegUN or <segun>.SegUN
      The pseudo unique name for the segment <segun>. This is then used as the key to access the attributes for a given segment. See help-Path-To-UN.
    Seg or <segun>.Seg
      The segment name.
    SegV or <segun>.SegV
      The name of the segment converted to a shell compatible variable name.
    SegP or <segun>.SegP
      The path to the makefile segment.
    SegD or <segun>.SegD
      The name of the directory containing the segment.
    SegF or <segun>.SegF
      The path and name of the makefile segment. This can be used as part of a dependency list.
    SegTL or <segun>.SegTL
      A one line description (tag line) for the segment.
    SegHL or <segun>.SegHL
      A list of symbol names for help messages.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

$(call Add-Help,SegUNs)

_macro := Path-To-UN
define _help
${_macro}
  Return a pseudo unique name for a given path. This name is a combination of the directory containing the segment and the name of the segment in dot notation.
  For example:
    If the path is: /dir1/dir2/dir3/seg.mk
    The resulting pseudo unique name is: dir3.seg
  Parameters:
    1 = The full file path for the UN.
    2 = The variable in which to store the UN.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Path=$(1) Out=$(2))
  $(call Verbose,MAKEFILE_LIST:${MAKEFILE_LIST})
  $(call Verbose,path:$(realpath $(1)))
  $(eval $(2) := )
  $(eval __seg := $(basename $(notdir $(1))))
  $(call Verbose,__seg:${__seg})
  $(call Verbose,dir:$(dir $(abspath $(1))))
  $(eval __p := $(subst /^,,$(dir $(abspath $(1)))^))
  $(call Verbose,__p:${__p})
  $(eval $(2) := $(lastword $(subst /, ,${__p}.$(strip ${__seg}))))
  $(call Verbose,$(2):${$(2)})
  $(call Exit-Macro)
endef


_var := FirstSegUN
$(call Path-To-UN,$(firstword ${MAKEFILE_LIST}),${_var})
define _help
${_var}
  The pseudo unique name of the first segment in the makefile list.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_var := LastSegUN
${_var} :=
define _help
${_var}
  The unique name of the last included segment.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_macro := Last-Segment-UN
define _help
${_macro}
  Returns a pseudo unique name for the most recently included makefile segment.
  Returns:
    LastSegUN
      The pseudo unique name for the last segment in MAKEFILE_LIST.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(call Path-To-UN,$(lastword ${MAKEFILE_LIST}),LastSegUN)
  $(call Verbose,Path-To-UN returned:${LastSegUN})
  $(call Exit-Macro)
endef

_macro := Last-Segment-File
define _help
${_macro}
  Returns the file name of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(lastword ${MAKEFILE_LIST})

_macro := Last-Segment-Basename
define _help
${_macro}
  Returns the basename of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(basename $(notdir $(lastword ${MAKEFILE_LIST})))

_macro := Last-Segment-Var
define _help
${_macro}
  Returns the name of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(call To-Shell-Var,$(call Last-Segment-Basename))

_macro := Last-Segment-Path
define _help
${_macro}
  Returns the directory of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

_macro := Last-Segment-Dir
define _help
${_macro}
  Returns the directory of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(lastword $(subst /, ,$(subst /^,,\
    $(dir $(realpath $(lastword ${MAKEFILE_LIST})))^)))

_macro := New-Segment-ID
define _help
${_macro}
  Returns the ID of the most recently included makefile segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(words ${SegUNs})

_macro := Get-Segment-UN
define _help
${_macro}
  Returns a unique name for the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.

endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(word $(1),${SegUNs})

_macro := Get-Segment-File
define _help
${_macro}
  Returns the file name of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(word $(1),${MAKEFILE_LIST})

_macro := Get-Segment-Basename
define _help
${_macro}
  Returns the basename of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(basename $(notdir $(word $(1),${MAKEFILE_LIST})))

_macro := Get-Segment-Var
define _help
${_macro}
  Returns the name of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(subst -,_,$(call Get-Segment-Basename,$(1)))

_macro := Get-Segment-Path
define _help
${_macro}
  Returns the path of the makefile segment corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(realpath $(dir $(word $(1),${MAKEFILE_LIST})))

_macro := Get-Segment-Dir
define _help
${_macro}
  Returns the name of the directory containing the makefile segment
  corresponding to ID.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = \
  $(lastword $(subst /, ,$(subst /=,,\
    $(dir $(realpath $(word $(1),${MAKEFILE_LIST})))=)))

_var := SegPaths
${_var} := \
  $(realpath $(dir $(word 1,${MAKEFILE_LIST})))
define _help
${_var}
  The list of paths to search to find or use a segment.
endef
help-${_var} := $(call _help)
$(call __Queue-Help, ${_var})

_macro := Add-Segment-Path
define _help
${_macro}
  Add one or more path(s) to the list of segment search paths (SegPaths). If more than one path is added each path must be separated by a space. Each path must exist at the time it is added.
  Parameters:
    1 = The path(s) to add.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Path=$(1))
  $(foreach __p,$(1),
    $(if $(wildcard ${__p}/.),
      $(if $(filter ${__p},${SegPaths}),
        $(call Warn,Segment path ${__p} was already added.)
      ,
        $(eval SegPaths += ${__p})
        $(call Verbose,Added path(s):${__p})
      )
    ,
      $(call Signal-Error,Segment path ${__p} does not exist.)
    )
  )
  $(call Exit-Macro)
endef

_macro := Find-Segment
define _help
${_macro}
  If the segment to find is a complete path to a .mk file then the file is verified to exist. Otherwise, list list of search directories are searched for the segment The segment can exist in multiple locations but only the last one found will be selected. If the segment is not found in any of the directories then the current segment directory (Segment-Path) is searched. If the segment cannot be found an error message is added to the error list.
  Parameters:
    1 = The segment to find.
    2 = The name of the variable in which to store the full path to the selected segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Seg=$(1) Out=$(2))
  $(eval $(2) := )
  $(call Verbose,Locating segment: $(1))
  $(if $(findstring .mk,$(1)),
    $(call Verbose,Checking seg file path:$(1))
    $(if $(wildcard $(1)),
      $(eval $(2) := $(1))
    )
  ,
    $(call Verbose,Segment paths:${SegPaths} ${SegP})
    $(foreach __p,${SegPaths} ${SegP},
      $(call Verbose,Trying: ${__p})
      $(if $(wildcard ${__p}/$(1).mk),
        $(eval $(2) := ${__p}/$(1).mk)
      )
    )
  )
  $(if ${$(2)},
    $(call Verbose,Found segment:${$(2)})
  ,
    $(call Warn,Segment $(1) not found.)
  )
  $(call Exit-Macro)
endef

_macro := Use-Segment
define _help
${_macro}
  If the segment contains .mk then a valid path to the segment is assumed and the segment is loaded directly. Otherwise, Find-Segment is used to search a list of directories for a segment and the segment is loaded it if it exists. The segment can exist in multiple locations and only the last one in the list will be loaded. If the segment is not found in any of the directories then the segment is loaded from the current segment directory (Segment-Path). If the segment cannot be found an error message is added to the error list.
  Parameters:
      1 = The segment to load.
      2 = The message type to emit if the segment is not found. This defaults to Signal-Error.

  The loaded segment is expected to define a new context to be used during its initialization and then to restore the previous context when it has completed initialization. The new segment is also expected to avoid executing the initialization a second time. Helper macros are provided to standardize this process. They are intended to be used at the beginning in a preamble and at the end in a postamble. Unfortunately, make syntax limitations prevent this from being simplified even further.

  Makefile segments should use the standard preamble and postamble to avoid inclusion of the same file more than once and to use standardized ID variables.

  Segments which do not use a standard preamble will trigger an error. Non-standard segments should be included normally.

  Each loaded segment is added to SegTLeps to trigger rebuilds when a a segment is changed. NOTE: All components will be rebuilt in this case because it is unknown if a change in a segment will cause a change in the build output of another segment.

  A template for new make segments can be generated using the Gen-Segment-Text macro (below).
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Seg=$(1) MsgType=$(2))
  $(call Find-Segment,$(1),__segf)
  $(if ${__segf},
    $(call Path-To-UN,${__segf},__sun)
    $(if $(filter undefined,$(origin ${__sun}.SegID)),
      $(call Verbose,Using segment:${__segf})
      $(eval -include ${__segf})
      $(if $(filter undefined,$(origin ${__sun}.SegID)),
        $(call Warn,Loaded non-ModdingFW format segment -- ${__sun}. Use include instead.)
      )
    ,
      $(call Verbose,Segment $(1) is already loaded.)
    )
  ,
    $(if $(2),
      $(call $(2),Optional segment $(1) does not exist -- skipping.)
    ,
      $(call Signal-Error,Segment $(1) could not be found.)
    )
  )
  $(call Exit-Macro)
endef

define __Push-SegID
  $(if $(filter ${SegID},${SegID_Stack}),
    $(call Signal-Error,Recursive entry to segment ${SegID} detected.)
  )
  $(eval SegID_Stack += ${SegID})
  $(if ${DEBUG},
    $(call Log-Message, \
      $(words ${SegID_Stack})~~>,SegID_Stack:${SegID_Stack})
    $(if ${Single_Step},$(call Step))
  )
endef

define __Pop-SegID
  $(if ${DEBUG},
    $(call Log-Message, \
      <~~$(words ${SegID_Stack}),Restoring SegID:$(lastword ${SegID_Stack}))
  )
  $(if ${SegID_Stack},
    $(eval SegID := $(lastword ${SegID_Stack}))
    $(eval __l := $(words ${SegID_Stack}))
    $(call Dec-Var,__l)
    $(if $(filter ${__l},0),
      $(eval SegID_Stack := )
    ,
      $(eval SegID_Stack := $(wordlist 1,${__l},${SegID_Stack}))
      $(if ${DEBUG},
        $(call Log-Message, \
          $(words ${SegID_Stack})~~>,SegID_Stack:${SegID_Stack})
        $(if ${Single_Step},$(call Step))
      )
    )
  ,
    $(call Signal-Error,SegID stack is empty.)
  )
endef

_macro := Set-Segment-Context
define _help
${_macro}
  Sets the context for the makefile segment corresponding to ID. Among other things this is needed in order to have correct prefixes prepended to messages emitted by a makefile segment.
  Parameters:
    1 = ID of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),SegID=$(1))

  $(call Attention,Setting context for SegID $(1))
  $(eval __un := $(call Get-Segment-UN,$(1)))
  $(call Attention,SegID $(1) UN:${__un})
  $(call Verbose,Setting context for segment: ${__un})
  $(foreach __att,${SegAttributes},
    $(eval ${__att} = ${${__un}.${__att}})
    $(call Verbose,Setting: ${__att} = ${${__att}})
  )

  $(call Exit-Macro)
endef

_macro := __Init-Makefile-Context
define _help
${_macro}
  Initialize the segment context for the segment in MAKEFILE_LIST which included the helpers segment. This should be called before any other segment related macros are used. Helpers MUST be the second item in MAKEFILE_LIST.
  Parameters:
    1 = A one line description for the initial segment.
endef
define ${_macro}
  $(call Enter-Macro,$(0),Desc=$(1))

  $(eval __pc := $(words ${MAKEFILE_LIST}))
  $(if $(filter ${__pc},2),
    $(eval SegID := 1)
    $(eval ${FirstSegUN}.SegID := ${SegID})
    $(eval ${FirstSegUN}.UserSegID :=)
    $(eval ${FirstSegUN}.SegUN := $(call Get-Segment-UN,1))
    $(eval ${FirstSegUN}.Seg := $(call Get-Segment-Basename,${SegID}))
    $(eval ${FirstSegUN}.SegP := $(call Get-Segment-Path,1))
    $(eval ${FirstSegUN}.SegD := $(call Get-Segment-Dir,1))
    $(eval ${FirstSegUN}.SegF := $(call Get-Segment-File,1))
    $(eval ${FirstSegUN}.SegV := $(call To-Shell-Var,${FirstSegUN}))
    $(eval ${FirstSegUN}.SegTL := $(1))
    $(eval ${FirstSegUN}.SegHL := )
    $(call Set-Segment-Context,1)
  ,
    $(eval __mf := $(notdir $(word ${__pc},${MAKEFILE_LIST})))
    $(call Signal-Error,\
      ${__mf} MUST be included only by the top level makefile.)
  )

  $(call Exit-Macro)
endef

_macro := __Init-Last-Segment
define _help
${_macro}
  Add the last segment to the list of segments and init the segment attributes.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(call Last-Segment-UN)
  $(call Attention,Declaring segment:${LastSegUN})
  $(call Verbose,Initializing segment context for segment: ${SegID})
  $(eval SegUNs += ${LastSegUN})
  $(eval ${LastSegUN}.UserSegID := ${SegID})
  $(eval SegID := $(call New-Segment-ID))
  $(eval ${LastSegUN}.SegID := ${SegID})
  $(eval ${LastSegUN}.SegUN := ${LastSegUN})
  $(eval ${LastSegUN}.Seg := $(call Last-Segment-Basename))
  $(eval ${LastSegUN}.SegP := $(call Last-Segment-Path))
  $(eval ${LastSegUN}.SegD := $(call Last-Segment-Dir))
  $(eval ${LastSegUN}.SegF := $(call Last-Segment-File))
  $(eval ${LastSegUN}.SegV := $(call To-Shell-Var,${LastSegUN}))
  $(eval ${LastSegUN}.SegTL := $(strip $(1)))
  $(eval ${LastSegUN}.SegHL := File: ${${LastSegUN}.SegF})
  $(call Exit-Macro)
endef

_macro := Enter-Segment
define _help
${_macro}
  This initializes the context for a new segment and saves information so that the context of the previous segment can be restored in the postamble. This is intended to be called only ONCE for each segment.
  Parameters:
    1 = A one line description of the segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Desc:$(call To-String,$(1)))
  $(call __Init-Last-Segment)
  $(eval $(call Verbose,\
    Entering segment: $(call Get-Segment-Basename,${${LastSegUN}.SegID})))
  $(call Verbose,${LastSegUN}.SegID:${${LastSegUN}.SegID})
  $(call Verbose,Setting context:${${LastSegUN}.SegID})
  $(call __Push-SegID)
  $(call Set-Segment-Context,${${LastSegUN}.SegID})
  $(call Exit-Macro)
  $(call __Push-Macro,${LastSegUN})
endef

_macro := Exit-Segment
define _help
${_macro}
  This initializes the help message for the segment and restores the context of the previous segment.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(call Verbose,Exiting segment: ${${SegUN}.Seg})
  $(call __Pop-SegID)
  $(eval $(call Set-Segment-Context,${SegID}))
  $(call Exit-Macro)
  $(call __Pop-Macro)
endef

_macro := Check-Segment-Conflicts
define _help
${_macro}
  This handles the case where a segment is being used more than once or the current segment is attempting to use the same prefix as a previously loaded segment. This should be called only when the segment ID for the seg is already defined.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(call Verbose,\
    Segment exists: ID = ${${LastSegUN}.SegID}: file = $(call Get-Segment-File,${${LastSegUN}.SegID}))
  $(if \
    $(filter \
      $(call Last-Segment-File),$(call Get-Segment-File,${${LastSegUN}.SegID})),
    $(call Warn,Segment ${LastSegUN} has already been included.)
    $(call Info,Segment file:$(call Last-Segment-File))
  ,
    $(call Signal-Error,\
      Context conflict with $(${LastSegUN}.Seg) in ${LastSegUN}.)
    $(call Info,Segment file:$(call Last-Segment-File))
  )
  $(call Exit-Macro)
endef

_macro := Gen-Segment-Text
define ${_macro}
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# $(strip $(2))
#----------------------------------------------------------------------------
# +++++
$$(call Last-Segment-UN)
$.ifndef $${LastSegUN}.SegID
$$(call Enter-Segment,$(2))
# -----

$.define _help
Make segment: $${Seg}.mk

<Overview of makefile segment>

Command line goals:
  # Describe additional goals provided by the segment.
  help-$${SegUN}
    Display this help.
$.endef
help-$${SegID} := $$(call _help)
$$(call Add-Help,$${SegID})

_macro := $${SegUN}.init
$.define _help
$${_macro}
  Run the initialization for the segment. This is designed to be called some time after the segment has been loaded. This is useful when this segment uses variables from other segments which haven't yet been loaded or the segment which is using this segment.
  Parameters:
    1 = The name to use to establish context for this segment.
$.endef
help-$${_macro} := $$(call _help)
$$(call Add-Help,$${_macro})
$.define $${_macro}
$$(call Enter-Macro,$$(0),Context=$$(1))
$$(call Info,Initializing $(1).)
$$(call Exit-Macro)
$.endef

$$(call Info,New segment: Add variables, macros, goals, and recipes here.)
# Remove the following line after completing this segment.
$$(call Attention,Segment $${Seg} has not yet been completed.)
$$(call Verbose,SegUN = $${SegUN})

# The command line goal for the segment.
$${LastSegUN}: $${SegF}

# +++++
# Postamble
# Define help only if needed.
$.__h := $$(or \$.
  $$(call Is-Goal,help-$${Seg}),\$.
  $$(call Is-Goal,help-$${SegUN}),\$.
  $$(call Is-Goal,help-$${SegID}))
$.ifneq ($${__h},)
$.define __help
$$(call Display-Help-List,$${SegID})
$.endef
$${__h} := $${__help}
$.endif # help goal message.

$$(call Exit-Segment)
$.else # $$(call Last-Segment-Basename).SegID exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename).SegID
# -----

endef
# Help is at the end of the macro declaration in this case because the
# macro is used to generate a portion of the help.
define _help
${_macro}
  This generates segment text which can then be written to a file.
  Parameters:
    1 = The segment name. This is used to name the segment file, associated variable and, specific goals.
    2 = A one line description.
  For example:
  $$(call Gen-Segment,sample-seg,This is a sample segment.)
  generates:
$(call Gen-Segment-Text,sample-seg,This is a sample segment.)
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})

_macro := Gen-Segment-File
define _help
${_macro}
  This uses Gen-Segment-Text to generate a segment file and writes it to the specified file.
  Parameters:
    1 = The segment name. This is used to name the segment file, associated variable and, specific goals.
    2 = The full path to where to write the segment file.
    3 = A one line description.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Seg=$(1) Path=$(2) Desc=$(call To-String,$(3)))
  $(file >$(2),$(call Gen-Segment-Text,$(1),$(3)))
  $(call Attention,\
    Segment file for $(1) has been generated -- remember to customize.)
  $(call Exit-Macro)
endef

_macro := Derive-Segment-File
define _help
${_macro}
  Derive a new segment file from an existing segment file. Segment related variables are modified to reference the new segment.
  Parameters:
    1 = The existing segment name.
    2 = The full path to the existing segment file.
    3 = The new segment name.
    4 = The full path to the new segment file.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Seg=$(1) Path=$(2) NewSeg=$(3) NewPath=$(4))
  $(call Verbose,Deriving $(3) from $(1).)
  $(eval __v1 := $(call To-Shell-Var,$(1)))
  $(eval __v3 := $(call To-Shell-Var,$(3)))
  $(call Run, \
    echo '#' "Derived from template - $(1)" > $(4) &&\
    sed \
      -e 's/$(1)/$(3)/g' \
      -e 's/${__v1}/${__v3}/g' \
      $(2) >> $(4) \
  )
  $(if ${Run_Rc},
    $(call Signal-Error,Error during edit of $(3) segment file.)
  )

  $(call Exit-Macro)
endef

#--------------

#++++++++++++++
# Goal management.
$(call __Queue-Help-Section,Goals,For checking and handling make goals.)

_macro := Resolve-Help-Goals
define _help
${_macro}
  This scans the goals for references to help and then insures the corresponding segment is loaded. This should be called only after all other segments have been loaded (Use-Segment) to avoid problems with variable declaration sequence dependencies.

  NOTE: All segments for which help is referenced must be in the segment search path (Add-Segment-Path).
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
  $(call Verbose,Resolving help goals.)
  $(call Verbose,Help goals: $(filter help%,${Goals}))
  $(foreach __s,$(patsubst help-%,%,$(filter help-%,${Goals})),
    $(if $(call Is-Not-Defined,help-${__s}),
      $(call Verbose,Resolving help for help-${__s})
      $(if $(filter \
        ${__s},2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20),
        $(eval help-${__s} := \
          SegID ${__s} does not exist -- help unavailable.)
        $(call Signal-Error,Segment ID ${__s} does not exist -- no help.)
      ,
        $(call Use-Segment,$(subst .,/,${__s}).mk,)
        $(if $(call Is-Not-Defined,help-${__s}),
          $(call Signal-Error,help-${__s} is undefined.)
        )
      )
    ,
      $(call Verbose,Help help-${__s} is defined.)
    )
  )
  $(call Exit-Macro)
$(call Test-Info,Suite run complete.)
endef

_macro := Is-Goal
define _help
${_macro}
  Returns the goal if it is a member of the list of goals. The special goal all is returned if all is in the list of goals.
  Parameters:
    1 = The goal to check.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
${_macro} = $(or $(filter all,${Goals}),$(filter $(1),${Goals}))

_macro := Add-To-Manifest
define _help
${_macro}
  Add an item to a manifest variable.
  Parameters:
    1 = The list to add to.
    2 = The optional variable to declare for the value. Use "null" to skip declaring a new variable.
    3 = The value to add to the list.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),List=$(1) OptVar=$(2) Val=$(3))
  $(call Verbose,Adding $(3) to $(1))
  $(call Verbose,Var: $(2))
  $(eval $(2) = $(3))
  $(call Verbose,$(2)=$(3))
  $(eval $(1) += $(3))
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Directories and files.
$(call __Queue-Help-Section,PathsAndFiles,Macros for paths and files.)

_macro := Basenames-In
define _help
${_macro}
  Get the basenames of all the files in a directory matching a glob pattern.
  Parameters:
    1 = The glob pattern including path.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(sort $(foreach f,$(wildcard $(1)),$(basename $(notdir ${f}))))
endef

_macro := Directories-In
define _help
${_macro}
  Get a list of directories in a directory. The path is stripped.
  Parameters:
    1 = The path to the directory.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(sort \
    $(strip $(foreach d,$(shell find $(1) -mindepth 1 -maxdepth 1 -type d),\
    $(notdir ${d})))
  )
endef

#--------------

#++++++++++++++
# Other helpers.
$(call __Queue-Help-Section,Other,Other macros for flow control.)

_macro := Confirm
define _help
${_macro}
  Prompts the user for a yes or no response. If the response matches the positive response then the positive response is returned. Otherwise an empty value is returned.
  Parameters:
    1 = The prompt for the response.
    2 = The expected positive response.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(strip $(filter $(2),$(shell read -r -p "$(1) [$(2)|N]: "; echo $$REPLY)))
endef

_macro := Input
define _help
${_macro}
  Prompts the user to enter an input line.
  Parameters:
    1 = The prompt for the response.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(strip $(shell read -r -p "$(1): "; echo $$REPLY))
endef

_macro := Pause
define _help
${_macro}
  Wait until the Enter key is pressed.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(shell read -r -p "Press Enter to continue...")
endef

_macro := Return-Code
define _help
${_macro}
  Returns the return code (last line) of the output produced by Run. This can then be used in a conditional.
  Parameter:
    1 = The previously captured console output.
  Returns:
    If the return code equals 0 then nothing is returned. Otherwise, the return code is returned.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),RC=$(lastword $(1)))
  $(if $(filter 0,$(lastword $(1))),,$(lastword $(1)))
  $(call Exit-Macro)
)
endef

_macro := Run
define _help
${_macro}
  Run a shell command and return the error code. The output is written to the log file.
  Parameters:
    1 = The command to run. This can be multiple commands separated by semicolons (;) or AND (&&) OR (||) conditionals.
    2 = When not empty then do not display the run output on the console.
  Returns:
    Run_Output
      The console output with the return code appended at the end of the last
      line.
    Run_Rc
      The return code from the output.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Cmd=$(call To-String,$(1)))
  $(call Verbose,Command:$(1) )
  $(if ${LogFile},
    $(if $(2),
      $(eval __log := >>${LogFile} ;echo $$?)
    ,
      $(eval __log := | tee -a ${LogFile};echo $${Dlr}PIPESTATUS)
    )
  ,
    $(eval __log := ;echo $$?)
  )
  $(eval Run_Output := $(shell $(1) 2>&1 ${__log}))
  $(call Info,Run_Output = ${Run_Output})
  $(eval Run_Rc := $(call Return-Code,${Run_Output}))
  $(if ${Run_Rc},
    $(call Warn,Shell return code:${Run_Rc})
  )
  $(call Verbose,Run_Rc = ${Run_Rc})
  $(call Exit-Macro)
endef

_macro := Gen-Command-Goal
define _help
${_macro}
  Generate a goal. This is provided to reduce repetitive typing. The goal is generated only if it is referenced on the command line.
  Parameters:
    1 = The name of the goal.
    2 = The commands for the goal.
    3 = An optional prompt. This generates a y/N confirmation and the goal is generated only if the response is y.
endef
help-${_macro} := $(call _help)
$(call __Queue-Help, ${_macro})
define ${_macro}
$(call Enter-Macro,$(0),\
  Goal=$(1) \
  Commands=$(call To-String,$(2)) \
  Prompt:$(call To-String,$(3)))
$(if $(call Is-Goal,$(1)),
  $(call Verbose,Generating $(1) to do "$(2)")
  $(if $(3),
    $(if $(call Confirm,$(3),y),
      $(eval
$(1):
$(strip $(2))
      )
    ,
    $(call Verbose,Not doing $(1))
    )
  ,
    $(eval
$(1):
$(strip $(2))
    )
  )
,
  $(call Verbose,Goal $(1) is not on command line.)
)
$(call Exit-Macro)
endef

#--------------

# Set SegID to the segment that included helpers so that the previous segment
# set by Enter-Segment and used by Exit-Segment will have a valid value.
$(call Verbose,MAKEFILE_LIST:${MAKEFILE_LIST})
$(call Verbose,$(realpath $(firstword ${MAKEFILE_LIST})))
$(call Verbose,__i:$(call New-Segment-ID))
# Initialize the top level context.
$(call __Init-Makefile-Context,${MakeTL})

$(call Enter-Segment,Helper macros for makefiles.)
$(call Verbose,In segment:${SegUN})

# Now can finally add the queued help messages.
$(call Verbose,Appending queued help messages.)

$(call Verbose,${SegUN}.SegHL = ${${SegUN}.SegHL})
${SegUN}.SegHL += ${__HelpQueue}
$(call Verbose,${SegUN}.SegHL = ${${SegUN}.SegHL})

# These are helper functions for shell scripts (Bash).
$(call Add-Help-Section,ShellHelpers,Helper functions for shell scripts .)

_var := HELPER_FUNCTIONS
${_var} := ${${SegUN}.SegP}/moddingfw-functions.sh
define _help
${_var} = ${${_var}}
  Helper functions for shell scripts.

  WARNING: This script contains bash-isms so must be run using bash.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

export HELPER_FUNCTIONS

#++++++++++++++
# Sticky variables.
$(call Add-Help-Section,Sticky,For handling sticky variables.)

# For storing sticky options in a known location.
_var := STICKY_DIR
${_var} := sticky
define _help
${_var} = ${${_var}}
  The name of the directory where sticky variables are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_STICKY_PATH
${_var} ?= ${HiddenPath}/${STICKY_DIR}
define _help
${_var} = ${${_var}}
  The default path to where sticky variables are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := STICKY_PATH
${_var} ?= ${DEFAULT_STICKY_PATH}
define _help
${_var} = ${${_var}}
  The path to where sticky variables are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := StickyVars
${_var} :=
define _help
${_var} = ${${_var}}
  This variable is the list of sticky variables which have been defined and is used to detect when a sticky variable is being redefined.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_macro := Is-Sticky-Var
define _help
${_macro}
  Returns the variable name if the variable is defined as a sticky variable -- meaning the variable has been defined to be a sticky variable using the Sticky macro.
  Parameters:
    1 = The sticky variable to check.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(filter $(1),${StickyVars})

_macro := Is-Sticky
define _help
${_macro}
  Returns the variable name if the variable is sticky -- meaning its value has been saved.
  Parameters:
    1 = The sticky variable to check.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(wildcard ${STICKY_PATH}/$(1))

_macro := Sticky
define _help
${_macro}
  A sticky variable is persistent and needs to be defined on the command line at least once or have a default value as an argument.

  If the variable has already been defined in a segment then the variable is not saved as a sticky variable.

  If the variable has not been defined when this macro is called then the previous value is used. Defining the variable will overwrite the previous sticky value.

  Only the first call to Sticky for a given variable will be accepted. Additional calls will produce a redefinition error.

  Sticky variables are read-only in a sub-make (MAKELEVEL != 0).
  Parameters:
    1 = Variable name[=<value>]
    2 = Optional default value.
  Returns:
    The variable value.
  Examples:
    $$(call Sticky,<var>,<default>)
      If <var> is undefined then restores the previously saved <value> or sets <var> equal to <default>.
      If <var> is defined then <var> is saved as a new value.
    $$(call Sticky,<var>=<value>)
      Sets the sticky variable equal to <value>. The <value> is saved for retrieval at a later time. NOTE: This form can override the variable if it was defined before calling Sticky (e.g on the command line).
    $$(call Sticky,<var>=<value>,<default>)
      Sets the sticky variable equal to <value>. The <value> is saved for retrieval at a later time. The default is ignored in this case.
    $$(call Sticky,<var>)
      Restores the previously saved <value>. If no value has been previously saved then an empty value is saved.
    $$(call Sticky,<var>=)
      Sets the sticky variable to an empty value. This is useful when saving flags.
    $$(call Sticky,<var>=,<default>)
      Also sets the sticky variable to an empty value. This is useful whensaving flags. The default is ignored in this case.
  To ignore a sticky variable and instead use its default, from the command line use:
    <var>=""
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Var=$(1) Val=$(2))
  $(eval __snl := $(subst =,${Space},$(1)))
  $(eval __sn := $(word 1,${__snl}))
  $(call Verbose,Sticky:Var:${__sn})

  $(if $(call Is-Sticky-Var,${__sn}),
    $(call Warn,Redefinition of sticky variable ${__sn} ignored.)
  ,
    $(eval StickyVars += ${__sn})
    $(if $(filter file,$(origin $(1))),
      $(call Warn,\
        Sticky variable $(1) was defined in a make segment -- not saving.)
    ,
      $(eval __sf := ${STICKY_PATH}/${__sn})
      $(if $(wildcard ${STICKY_PATH}),
      ,
        $(shell mkdir -p ${STICKY_PATH})
      )
      $(call Verbose,Flavor of ${__sn} is:$(flavor ${__sn}))
      $(eval __save :=)
      $(if $(call Is-Not-Defined,${__sn}),
        $(call Verbose,Defining ${__sn})
        $(if $(findstring =,$(1)),
          $(eval __sv := $(wordlist 2,$(words ${__snl}),${__snl}))
          $(eval __save := 1)
          $(call Verbose,Setting ${__sn} to:"${__sv}".)
        ,
          $(if $(call Is-Sticky,${__sn}),
            $(call Verbose,Reading previously saved value for ${__sn})
            $(eval __sv := $(file <${__sf}))
          ,
            $(if $(2),
              $(eval __sv := $(2))
              $(call Verbose,Setting ${__sn} to default:"${__sv}")
              $(eval __save := 1)
            ,
              $(eval __sv :=)
            )
          )
        )
        $(eval ${__sn} := ${__sv})
        $(if ${SubMake},
          $(call Verbose,Variables are read-only in a sub-make.)
        ,
          $(if ${__save},
            $(call Verbose,Creating sticky:${__sf}=${__sv})
            $(file >${__sf},${__sv})
            $(if $(wildcard ${__sf}),
              $(call Verbose,Sticky variable ${__sv} was created.)
            ,
              $(call Signal-Error,Sticky variable ${__sv} was not created.)
            )
          )
        )
      ,
        $(call Verbose,${__sn} is defined.)
        $(if $(findstring =,$(1)),
          $(eval ${__sn} := $(wordlist 2,$(words ${__snl}),${__snl}))
        )
        $(call Verbose,Saving sticky:${__sn}=${${__sn}})
        $(if ${SubMake},
          $(call Verbose,Variables are read-only in a sub-make.)
        ,
          $(if $(call Is-Sticky,${__sn}),
            $(call Verbose,Replacing sticky:${__sf})
          ,
            $(call Verbose,Creating sticky:${__sf})
          )
          $(file >${__sf},${${__sn}})
        )
      )
    )
  )
  $(call Exit-Macro)
endef

_macro := Redirect-Sticky
define _help
Change the path to where sticky variables are stored.
Parameters:
  1 = The new path for the sticky variables.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Path=$(1))
  $(call Attention,Redirecting sticky variables to:$(1))
  $(eval STICKY_PATH := $(1))
  $(call Exit-Macro)
endef

_macro := Redefine-Sticky
define _help
${_macro}
  Redefine a sticky variable that has been previously set. The variable is saved only if its new value is different than its current value and not running as a submake.
  Parameters:
    1 = Variable name[=<value>]
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Var=$(1))
  $(eval __rspl := $(subst =,${Space},$(1)))
  $(eval __rsp := $(word 1,${__rspl}))
  $(eval __rsv := $(wordlist 2,$(words ${__rspl}),${__rspl}))
  $(if $(call Is-Sticky-Var,${__rsp}),
    $(eval __rscv := ${${__rsp}})
    $(call Compare-Strings,__rsv,__rscv,__diff)
    $(call Verbose,Old and new diff:${__diff})
    $(if ${__diff},
      $(call Verbose,Redefining:${__rsp})
      $(call Verbose,SubMake:${SubMake})
      $(if ${SubMake},
        $(call Warn,Cannot overwrite ${__rsp} in a submake.)
      ,
        $(file >$(STICKY_PATH)/${__rsp},${__rsv})
      )
    ,
      $(call Verbose,Var ${__rsp} is unchanged:"${__rsv}" "${__rscv}")
    )
  ,
    $(call Signal-Error,Var ${__rsp} has not been defined.)
  )
  $(call Exit-Macro)
endef

_macro := Undefine-Sticky
define _help
${_macro}
  Undefine a sticky variable. The sticky variable file is retained.
  Parameters:
    1 = Variable name to undefine.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Var=$(1))
  $(if $(call Is-Sticky-Var,$(1)),
    $(call Verbose,Undefining sticky variable: $(1))
    $(eval StickyVars := $(filter-out $(1),${StickyVars}))
    $(eval undefine $(1))
  ,
    $(call Signal-Error,Var $(1) is not a sticky variable.)\
  )
  $(call Exit-Macro)
endef

_macro := Remove-Sticky
define _help
${_macro}
  Remove (unstick) a sticky variable. This deletes the sticky variable file and undefines the sticky variable.
  Parameters:
    1 = Variable name to remove.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),Var=$(1))
  $(if $(call Is-Sticky-Var,$(1)),
    $(call Undefine-Sticky,$(1))
    $(call Verbose,Removing sticky variable: $(1))
    $(shell rm ${STICKY_PATH}/$(1))
  ,
    $(call Signal-Error,Var $(1) has not been defined.)\
  )
  $(call Exit-Macro)
endef
#--------------

#++++++++++++++
# Other macros.
$(call Add-Help-Section,MiscMacros,Miscellaneous macros.)

_macro := Display-Seg-Attributes
define _help
${_macro}
  Display the attributes for a segment.
  See help-SegAttributes for more information.
  Parameters:
    1 = The SegUN for the attributes to display.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),SegUN=$(1))
    $(call Info,Displaying attributes for segment $(1).)
    $(foreach __a,${SegAttributes},
      $(call Info,$(1).${__a} = ${$(1).${__a}})
    )
  $(call Exit-Macro)
endef

_macro := Display-Segs
define _help
${_macro}
  Display a list of loaded segments. Each segment is listed as:
    <SegID>:<Seg>:<SegUN>:<SegTL>
  This information can the be used to determine the pseudo unique name for displaying the help of a segment.
  See help-SegAttributes for more information.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),)
    $(call Info,Segments:${SegUNs})
    $(call Info,SegID:Seg:SegUN:SegTL.)
    $(foreach __s,${SegUNs},
      $(call Info,${${__s}.SegID}:${${__s}.Seg}:${${__s}.SegUN}:${${__s}.SegTL})
    )
  $(call Exit-Macro)
endef

_macro := More-Help
define _help
${_macro}
  Add help messages to the help output.
  Parameters:
    1 = The name of the variable containing the list of macros or variables for which to add help messages.
  Defines:
    MoreHelpList
      The list of help messages to append to the help output.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),HelpList=$(1))
  $(if $(1),
    $(call Verbose,Help list for:$(1):${$(1)})
    $(eval $(1).MoreHelpList := )
    $(foreach __sym,${$(1)},
      $(call Verbose,Adding help for:${__sym})
      $(if $(call Is-Not-Defined,help-${__sym}),
        $(call Warn,Undefined help message: help-${__sym})
      ,
        $(eval $(1).MoreHelpList += help-${__sym})
      )
    )
  ,
    $(call Warn,Attempt to add empty help list ignored.)
  )
  $(call Exit-Macro)
endef

#--------------

# Special goal to force another goal.
FORCE:

$(call Info,Goals: ${Goals})

.DEFAULT_GOAL = ${DefaultGoal}

# Some behavior depends upon which platform.
ifeq ($(shell grep WSL /proc/version > /dev/null; echo $$?),0)
  Platform = Microsoft
else ifeq ($(shell echo $$(expr substr $$(uname -s) 1 5)),Linux)
  Platform = Linux
else ifeq ($(shell uname),Darwin)
# Detecting OS X is untested.
  Platform = OsX
else
  $(call Signal-Error,Unable to identify platform)
endif
$(call Info,Running on: ${Platform})

$(call Verbose,MAKELEVEL = ${MAKELEVEL})
$(call Verbose,MAKEFLAGS = ${MAKEFLAGS})

$(call Add-Help-Section,CallingMacros,Calling macros.)

_var := PARMS
${_var} :=
define _help
${_var} = ${${_var}}
  This of parameters passed to a macro being called using the call-<macro> goal when <macro>.PARMS is not defined.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := Callable_Macros
${_var} :=
define _help
${_var} = ${${_var}}
  This is the list of macros which can be called from the command line.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_macro := Macro-Is-Callable
define _help
${_macro}
  Returns a non-empty value if the macro has been declared to be callable.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(filter $(1),${Callable_Macros})

_macro := Declare-Callable-Macro
define _help
${_macro}
  Declare a macro to be callable from the command line. A macro must be declared callable before it can be called using the call-<macro> goal.
  Parameters:
    1 = The name of the macro to declare callable.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Info,Declaring callable macro:$(1))
  $(eval $(1).PARMS ?= )
  $(eval Callable_Macros += $(1))
  $(eval help-Callable_Macros += $(1))
endef

define __Call-Macro
$(if $(call Macro-Is-Callable,$(1)),
  $(if ${$(1).PARMS},
    $(eval __parms := ${$(1).PARMS})
  ,
    $(eval __parms := ${PARMS})
  )
  $(eval __w := $(subst :, ,${__parms}))
  $(call Attention,$(1) parameters:${__w})
  $(foreach pn,1 2 3,
    $(eval p${pn} := $(subst +, ,$(word ${pn},${__w})))
    $(call Verbose,p${pn}:${p${pn}})
  )
  $(call Clear-Errors)
  $(eval _q := ${QUIET})
  $(eval QUIET :=)
  $(call $(1),${p1},${p2},${p3})
  $(eval QUIET := ${_q})
,
  $(call Signal-Error,Macro $(1) is not callable.,exit)
)
endef

__goal := call
define _help
${__goal}-<macro>
  Call a macro with parameters. The macro must have been previously declared to be callable.
  Uses:
    <macro>.PARMS or PARMS
      A list of parameters to pass to the macro. The macro name provides context so that multiple calls can be used on the command line. If the context is not provided then PARMS is used.

      Because of the limited manner in which make deals with strings and lists of parameters special characters are needed to indicate different parameters versus strings. Parameters are separated using the colon character (:) and spaces in a parameter are indicated using the plus character (+).

      A maximum of three parameters are supported.

      Output form the macro is routed to a text file and then displayed using less.

      WARNING: This may not work for all macros. The list of macros this can be used with is currently undefined.
      For example:
        <macro>.PARMS="parm1:parm2+string"
        This declares two parameters where the second parameter is a string.

  See help-Callable_Macros for a list.
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

${__goal}-%:
> $(call __Call-Macro,$*)

$(call Add-Help-Section,CommandLineGoals,Command line goals.)

__goal := display-messages
define _help
${__goal}
  This goal displays the log file if LOG_FILE is defined.
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

ifneq (${LogFile},)
${__goal}: ${LogFile}
> less $<
else
  $(call Attention,Use LOG_FILE=<file> to enable message logging.)
${__goal}:
endif

__goal := display-errors
define _help
${__goal}
  This goal displays a list of accumulated errors if defined.
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

${__goal}:
> @if [ -n '${ErrorList}' ]; then \
  m="${ErrorList}";printf "Errors:$${m//${NewLine}/\\n}" | less;\
  fi

__goal := show-
define _help
${__goal}<var>
  Display the value of any variable.
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

${__goal}%:
> @echo '$*=$($*)'

_var := TermCols
${_var} := $(shell tput cols)
define _help
${_var} = ${${_var}}
  This is the number of columns in the terminal. This is used for formatting help messages.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

__goal := help-
define _help
${__goal}<sym>
  Display the help for a specific macro, segment, or variable.
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

${__goal}%:
> $(file >${TmpPath}/help-$*,${help-$*})
> $(if $(call Is-Not-Defined,$*.MoreHelpList),,\
    $(if ${$*.MoreHelpList},\
      $(foreach _h,${$*.MoreHelpList},\
        $(file >>${TmpPath}/help-$*,==== ${__h} ====)\
        $(file >>${TmpPath}/help-$*,${${__h}}))))
> @fmt -s -w ${TermCols} ${TmpPath}/help-$* | less
> @rm ${TmpPath}/help-$*

__goal := origin-
define _help
${__goal}<sym>
  Display the origin of a symbol. The result can be any of the values described in section 8.11 of the GNU make documentation (https://www.gnu.org/software/make/manual/html_node/Origin-Function.html).
endef
help-${__goal} := $(call _help)
$(call Add-Help,${__goal})

${__goal}%:
> @echo 'Origin:$*=$(origin $*)'

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
endif # help goal

$(call Declare-Callable-Macro,Display-Seg-Attributes)
$(call Declare-Callable-Macro,Display-Segs)

$(call Verbose,New-Segment-ID:$(call New-Segment-ID))
$(call Verbose,${LastSegUN}.SegID:${${LastSegUN}.SegID})
$(call Exit-Segment)
else # Already loaded.
$(call Check-Segment-Conflicts)
endif # helpers.SegID
