"
I am the entry point into the **Oups** debugging tool layer.
My instances handle debug requests according to the system state and configuration:

- First, before opening a debugger, I query the current `UIManager`. If interactive debugging is not enabled, the debug request concludes there and the error is logged (_e.g._, if the system is running headless).

- Second, I collect the list of users of `TDebugger` (_i.e._, each debugger class) and I sort them based on their per-debugger user-defined priority. Then, a debugger selection strategy selects a debugger from that list to open the error.

- Finally, I ensure that the debug request is handled reliably.
If an exception is raised within the debugger system itself, or if the debugger selection strategy fails to select a debugger, then the original error is handled by the emergency evaluator.
"
Class {
	#name : #OupsDebuggerSystem,
	#superclass : #Object,
	#category : #'Debugger-Oups-Infrastructure'
}

{ #category : #'utilities api' }
OupsDebuggerSystem class >> closeAllDebuggers [
	TDebugger users do:[:debuggerClass| debuggerClass closeAllDebuggers]
]

{ #category : #'instance creation' }
OupsDebuggerSystem >> availableDebuggers [
	^DebuggerSettings availableDebuggers sort:[:a :b| a rank > b rank]
]

{ #category : #helpers }
OupsDebuggerSystem >> debuggerSelectionStrategy [

	"Returns the debugger selection strategy to be used by this DebuggerSystem. This is the value of the corresponding setting"

	^ OupsDebuggerSelectionStrategy debuggerSelectionStrategy with:
		  self availableDebuggers
]

{ #category : #'default values' }
OupsDebuggerSystem >> defaultUIManager [
	^ UIManager default
]

{ #category : #exceptions }
OupsDebuggerSystem >> ensureExceptionIn: aDebugSession [

	aDebugSession exception ifNotNil: [ ^ self ].
	aDebugSession exception: (OupsNullException fromSignallerContext:
			 aDebugSession interruptedContext)
]

{ #category : #'handle debug requests' }
OupsDebuggerSystem >> handleDebugRequest: aDebugRequest [

	"A DebugRequest has been submitted. Ask what to do to the default UIManager. Typically, the UIManager will call back my #openDebuggerOnRequest: method to open a debugger"

	[ self defaultUIManager handleDebugRequest: aDebugRequest fromDebuggerSystem: self]
		on: Error
		do: [ self signalDebuggerError: aDebugRequest ]
]

{ #category : #'handle debug requests' }
OupsDebuggerSystem >> handleWarningDebugRequest: aWarningDebugRequest [

	"A WarningDebugRequest has been submitted. Ask what to do to the default UIManager. Typically, the UIManager will call back my #openDebuggerOnRequest: method to open a debugger"

	[ 
	self defaultUIManager handleWarningDebugRequest: aWarningDebugRequest fromDebuggerSystem: self]
		on: Error
		do: [ self signalDebuggerError: aWarningDebugRequest ]
]

{ #category : #'open debugger' }
OupsDebuggerSystem >> logDebugRequest: aDebugRequest withUIManager: aCommandLineUIManager [

	aCommandLineUIManager
		debugProcess: aDebugRequest process
		context: aDebugRequest exception signalerContext
		label: aDebugRequest exception description
		fullView: false
		notification: aDebugRequest exception description
]

{ #category : #'open debugger' }
OupsDebuggerSystem >> openDebuggerOnRequest: aDebugRequest [

	"Prepare the opening of a debugger, and delegate the debugger selection and opening to a strategy"

	<debuggerCompleteToSender>
	| debuggerOpeningStrategy |
	aDebugRequest debugSession logStackToFileIfNeeded.
	self performPreDebugActionsIn: aDebugRequest.
	self spawnNewUIProcessIfNecessary: aDebugRequest.
	self ensureExceptionIn: aDebugRequest debugSession.

	"Schedule the debugger opening in a deferred UI message to address redraw problems after opening a debugger e.g. from the testrunner."
	debuggerOpeningStrategy := self debuggerSelectionStrategy.
	self defaultUIManager defer: [ 
		debuggerOpeningStrategy openDebuggerForSession:
			aDebugRequest debugSession ].
	self suspendDebuggedProcess: aDebugRequest
]

{ #category : #helpers }
OupsDebuggerSystem >> performPreDebugActionsIn: aDebugRequest [

	"Get the preDebug actions stored in aDebugRequest. Applies them to the debugSession held by aDebugRequest"

	aDebugRequest computePreDebugActions.
	aDebugRequest preDebugActions do: [ :preDebugAction | 
		preDebugAction value: aDebugRequest debugSession ]
]

{ #category : #'error management' }
OupsDebuggerSystem >> signalDebuggerError: aDebugRequest [
	| failingSession |
	failingSession := aDebugRequest debugSession
		name: self signalDebuggerErrorMessage;
		yourself.
	self inform: 'failingSession signalDebuggerError: aDebugRequest exception'
]

{ #category : #'error management' }
OupsDebuggerSystem >> signalDebuggerErrorMessage [
	^ 'DebuggerSystem failure'
]

{ #category : #helpers }
OupsDebuggerSystem >> spawnNewUIProcess [

	"See comment of spawnNewUIProcessIfNecessary:"

	DefaultExecutionEnvironment beActiveDuring: [ 
		self defaultUIManager spawnNewProcess ]
]

{ #category : #helpers }
OupsDebuggerSystem >> spawnNewUIProcessIfNecessary: aDebugRequest [

	"If aDebugRequest is about debugging the UI process, we must create a new UI process to take its place. Because the debugged process will be suspended at some point, and suspending the UI process means freezing the UI of the image"

	aDebugRequest debugSession isAboutUIProcess ifTrue: [ 
		self spawnNewUIProcess ]
]

{ #category : #helpers }
OupsDebuggerSystem >> suspendDebuggedProcess: aDebugRequest [
	aDebugRequest process suspend
]

{ #category : #'open debugger' }
OupsDebuggerSystem >> warningRequest: aDebugRequest withUIManager: aCommandLineUIManager [

	aCommandLineUIManager warningDefaultAction: aDebugRequest exception
]
