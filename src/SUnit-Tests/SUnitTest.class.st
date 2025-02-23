"
This is both an example of writing tests and a self test for the SUnit. The tests 
here are pretty strange, since you want to make sure things blow up. You should 
not generally have to write tests this complicated in structure, although they 
will be far more complicated in terms of your own objects- more assertions, more 
complicated setup. Kent says: ""Never forget, however, that if the tests are hard 
to write, something is probably wrong with the design"".
"
Class {
	#name : #SUnitTest,
	#superclass : #TestCase,
	#instVars : [
		'hasRun',
		'hasSetup',
		'hasRanOnce',
		'forkedProcesses'
	],
	#category : #'SUnit-Tests-Core'
}

{ #category : #history }
SUnitTest class >> lastStoredRun [
	^ ((Dictionary new) add: (#passed->((Set new) add: #testWithExceptionDo; add: #testAssert; add: #testRanOnlyOnce; add: #testDialectLocalizedException; add: #testFail; add: #testDefects; add: #testIsNotRerunOnDebug; add: #testResult; add: #testRunning; add: #testError; add: #testException; add: #testShould; add: #testSuite; yourself)); add: (#timeStamp->'22 November 2008 10:11:35 pm'); add: (#failures->((Set new))); add: (#errors->((Set new))); yourself)
]

{ #category : #private }
SUnitTest >> assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount [

	self assert: aResult runCount equals: aRunCount.
	self assert: aResult passedCount equals: aPassedCount.
	self assert: aResult failureCount equals: aFailureCount.
	self assert: aResult errorCount equals: anErrorCount
]

{ #category : #private }
SUnitTest >> assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount expectedFailures: anExpectedFailureCount [
	self assert: aResult runCount equals: aRunCount.
	self assert: aResult expectedPassCount equals: aPassedCount.
	self assert: aResult failureCount equals: aFailureCount.
	self assert: aResult errorCount equals: anErrorCount.
	self assert: aResult expectedDefectCount equals: anExpectedFailureCount
]

{ #category : #helpers }
SUnitTest >> assertTerminationOfFailedChildProcesses [

	| failedProcesses |
	failedProcesses := self failedChildProcesses.
	self assert: failedProcesses notEmpty.
	self assert: (failedProcesses allSatisfy: #isTerminated)
]

{ #category : #helpers }
SUnitTest >> deprecatedMessage [
	self deprecated: 'Deprecated method used by #testIgnoreDeprecationWarnings' on: '' in: ''
]

{ #category : #private }
SUnitTest >> error [
	3 zork
]

{ #category : #testing }
SUnitTest >> errorShouldntRaise [
	self someMessageThatIsntUnderstood
]

{ #category : #private }
SUnitTest >> expectedFailureFails [
	<expectedFailure>
	self assert: false.
]

{ #category : #private }
SUnitTest >> expectedFailurePasses [
	<expectedFailure>
	self assert: true.
]

{ #category : #private }
SUnitTest >> failedChildProcessTest [
	"During this test forked process should signal error.
	It means that after fork we should give the process control"
	
	| process |
	process := [ self error: 'error from child process'] forkNamed: 'failed child for ', testSelector.
	forkedProcesses add: process.
	Processor yield.
]

{ #category : #helpers }
SUnitTest >> failedChildProcesses [
	^forkedProcesses select: [: each | each name beginsWith: 'failed child']
]

{ #category : #private }
SUnitTest >> failedTestWithFailedChildProcessTest [
	"This failing test first launches a subprocess that fails and then fails."
	self failedChildProcessTest.
	Processor yield.
	self error: 'failed test with failed child process'
]

{ #category : #accessing }
SUnitTest >> forkedProcesses [
	^forkedProcesses
]

{ #category : #accessing }
SUnitTest >> forkedProcesses: aCollection [
	forkedProcesses := aCollection
]

{ #category : #private }
SUnitTest >> hangedChildProcessTest [

	| process |
	process := [10 seconds wait] forkNamed: #hangedChildProcessTest.
	forkedProcesses add: process
]

{ #category : #private }
SUnitTest >> hangedTestDueToFailedChildProcess [
	self timeLimit: 10 milliSeconds.
	
	self failedChildProcessTest.
	
	20 milliSeconds wait.
]

{ #category : #accessing }
SUnitTest >> hasRun [
	^hasRun
]

{ #category : #accessing }
SUnitTest >> hasSetup [
	^hasSetup
]

{ #category : #private }
SUnitTest >> longRunningTest [

	self timeLimit: 10 milliSeconds.
	20 milliSeconds wait
]

{ #category : #helpers }
SUnitTest >> newTestCase: myTestSelector [ 
	| testCase |
	testCase := self class selector: myTestSelector.	
	"During the #run the #tearDown logic resets to nil all inst vars of #testCase instance.
	Here is a hook to collect any required state inside the receiver so that it can be accessed directly from the receiver despite on the reset #testCase.
	#forkedProcesses variable is used to keep all processes forked during the testCase execution"
	forkedProcesses ifNil: [ forkedProcesses := OrderedCollection new ].
	testCase forkedProcesses: forkedProcesses.
	^testCase
]

{ #category : #private }
SUnitTest >> noop [
]

{ #category : #testing }
SUnitTest >> raiseDeprecationWarnings [
	| oldRaiseWarning |
	oldRaiseWarning := Deprecation raiseWarning.
	[ Deprecation raiseWarning: true.
	self deprecatedMessage.
	self fail ]
		ensure: [ Deprecation raiseWarning: oldRaiseWarning ]
]

{ #category : #private }
SUnitTest >> setRun [
	hasRun := true
]

{ #category : #running }
SUnitTest >> setUp [
	super setUp.
	hasSetup := true
]

{ #category : #testing }
SUnitTest >> testAssert [
	self assert: true.
	self deny: false
]

{ #category : #testing }
SUnitTest >> testChildProcessShouldNotBeStoredStronglyByTestEnvironment [

	| process weak |
	process := [   ] forkNamed: 'child test process'.
	weak := WeakArray with: process.
	process := nil.
	Processor yield.
	Smalltalk garbageCollect.
	
	self assert: weak first equals: nil
]

{ #category : #testing }
SUnitTest >> testDefects [
	| result suite error failure |
	suite := self classForTestSuite new.
	suite addTest: (error := self newTestCase: #error).
	suite addTest: (failure := self newTestCase: #fail).
	result := suite run.
	self assert: result defects asArray equals: (Array with: error with: failure).
	self
		assertForTestResult: result
		runCount: 2
		passed: 0
		failed: 1
		errors: 1
]

{ #category : #testing }
SUnitTest >> testDialectLocalizedException [

	self
		should: [self classForTestResult signalFailureWith: 'Foo']
		raise: self defaultTestFailure.
	self
		should: [self classForTestResult signalErrorWith: 'Foo']
		raise: self defaultTestError.
]

{ #category : #testing }
SUnitTest >> testError [

	| case result |

	case := self newTestCase: #error.
	result := case run.
	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1.

	case := self newTestCase: #errorShouldntRaise.
	result := case run.
	self 
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1
]

{ #category : #testing }
SUnitTest >> testErrorShouldResetWatchDog [

	| case result |
	
	DefaultExecutionEnvironment beActive.
	TestExecutionEnvironment new beActiveDuring: [ 
		case := self newTestCase: #fail.
		result := case run.
		1 seconds wait]. 

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 1
		errors: 0
]

{ #category : #testing }
SUnitTest >> testException [

	self
		should: [self error: 'foo']
		raise: self defaultTestError
]

{ #category : #testing }
SUnitTest >> testExecutionEnvironmentShouldBeInstalled [

	| env |
	env := self executionEnvironment.

	self assert: env class equals: TestExecutionEnvironment.
	self assert: env testCase equals: self
]

{ #category : #testing }
SUnitTest >> testExpectedFailure [

	| case result |
	case := self newTestCase: #expectedFailureFails.
	self deny: case shouldPass.
	result := case run.
	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 0
		expectedFailures: 1.
]

{ #category : #testing }
SUnitTest >> testExpectedFailureDetection [
	self assert: self expectedFailures size equals: 2.
	self assert: (self expectedFailures includesAll: #(expectedFailureFails expectedFailurePasses))
]

{ #category : #testing }
SUnitTest >> testExpectedFailurePass [

	| case result |
	case := self newTestCase: #expectedFailurePasses.
	self deny: case shouldPass.
	result := case run.
	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 1
		errors: 0
		expectedFailures: 0.
]

{ #category : #testing }
SUnitTest >> testFail [

	| case result |

	case := self newTestCase: #fail.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 1
		errors: 0
]

{ #category : #testing }
SUnitTest >> testFailedChildProcessTest [

	| case result |
	DefaultExecutionEnvironment beActive.
	case := self newTestCase: #failedChildProcessTest.	
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1.		
	self assertTerminationOfFailedChildProcesses
]

{ #category : #testing }
SUnitTest >> testFailedChildProcessTestShouldNotEffectFollowingAnotherTest [

	| result case1 case2 |
	DefaultExecutionEnvironment beActive.
	TestExecutionEnvironment new beActiveDuring: [ 
		case1 := self newTestCase: #failedChildProcessTest.	
		result := case1 run.
		
		case2 := self newTestCase: #noop.	
		result := case2 run].

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0.		
	self assertTerminationOfFailedChildProcesses
]

{ #category : #testing }
SUnitTest >> testFailedTestWithFailedChildProcessTestShouldNotEffectFollowingAnotherTest [

	| result case1 case2 |
	DefaultExecutionEnvironment beActive.
	TestExecutionEnvironment new beActiveDuring: [ 
		case1 := self newTestCase: #failedTestWithFailedChildProcessTest.	
		result := case1 run.
		
		case2 := self newTestCase: #noop.	
		result := case2 run].

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0.
	self assertTerminationOfFailedChildProcesses
]

{ #category : #testing }
SUnitTest >> testFileOutResult [
	| suite result fileout |
	suite := self classForTestSuite new.
	suite
		addTest: (self newTestCase: #noop);
		addTest: (self newTestCase: #fail);
		addTest: (self newTestCase: #error).
	result := suite run.
	fileout := String streamContents: [ :aStream | result fileOutOn: aStream ].
	self
		assert: fileout
		equals:
			'3 ran, 1 passed, 0 skipped, 0 expected failures, 1 failure, 1 error, 0 passed unexpected
Failures:
SUnitTest(TestAsserter)>>#fail

Errors:
SUnitTest>>#error
'
]

{ #category : #testing }
SUnitTest >> testGreenTestThenLongRunningTest [

	| case result |
	DefaultExecutionEnvironment beActive.
	case := self newTestCase: #noop.
	result := case run.
	case := self newTestCase: #longRunningTest.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1
]

{ #category : #testing }
SUnitTest >> testHangedChildProcessTestWhenItIsAllowedToLeaveProcessesAfterTest [

	| case result hangedProcess |
	
	case := self newTestCase: #hangedChildProcessTest.	
	case executionProcessMonitor allowTestToLeaveProcesses.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0.
		
	hangedProcess := forkedProcesses detect: [: each | each name = #hangedChildProcessTest].
	self assert: hangedProcess isTerminated
]

{ #category : #testing }
SUnitTest >> testHangedChildProcessTestWhenLeftProcessIsConsideredAsFailure [

	| case result |

	case := self newTestCase: #hangedChildProcessTest.	
	case executionProcessMonitor failTestLeavingProcesses.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1
]

{ #category : #testing }
SUnitTest >> testHangedTestDueToFailedChildProcess [

	| case result |
	DefaultExecutionEnvironment beActive.
	case := self newTestCase: #hangedTestDueToFailedChildProcess.	
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1.
		
	self assertTerminationOfFailedChildProcesses
]

{ #category : #testing }
SUnitTest >> testIgnoreDeprecationWarnings [
	| oldRaiseWarning |
	oldRaiseWarning := Deprecation raiseWarning.
	[ Deprecation raiseWarning: false.
	self deprecatedMessage.
	self assert: true ]
		ensure: [ Deprecation raiseWarning: oldRaiseWarning ]
]

{ #category : #testing }
SUnitTest >> testIsNotRerunOnDebug [

	| case |

	case := self newTestCase: #testRanOnlyOnce.
	case run.
	case debug
]

{ #category : #testing }
SUnitTest >> testLongRunningTest [

	| case result |
	DefaultExecutionEnvironment beActive.
	case := self newTestCase: #longRunningTest.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 0
		errors: 1
]

{ #category : #testing }
SUnitTest >> testLongRunningTestThenGreenTest [

	| case result |
	DefaultExecutionEnvironment beActive.
	case := self newTestCase: #longRunningTest.
	result := case run.
	case := self newTestCase: #noop.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0
]

{ #category : #testing }
SUnitTest >> testRaiseDeprecationWarnings [
	| case result |
	case := self newTestCase: #raiseDeprecationWarnings.
	result := case run.
	self assert: result defects asArray equals: (Array with: case).
	self
		assertForTestResult: result
		runCount: 1
		passed: 0
		failed: 1
		errors: 0
]

{ #category : #testing }
SUnitTest >> testRan [

	| case |

	case := self newTestCase: #setRun.
	case resources do: [:each | each availableFor: case].
	[case setUp.
	case performTest] ensure: [
		self assert: case hasSetup.
		self assert: case hasRun.
		case tearDown.
		case cleanUpInstanceVariables].
	self assert: case hasSetup isNil.
	self assert: case hasRun isNil.
]

{ #category : #testing }
SUnitTest >> testRanOnlyOnce [

	self assert: hasRanOnce ~= true.
	hasRanOnce := true
]

{ #category : #testing }
SUnitTest >> testResult [

	| case result |

	case := self newTestCase: #noop.
	result := case run.

	self
		assertForTestResult: result
		runCount: 1
		passed: 1
		failed: 0
		errors: 0
]

{ #category : #testing }
SUnitTest >> testRunning [

	10 milliSeconds wait
]

{ #category : #testing }
SUnitTest >> testRunningLongTime [
	self timeLimit: 3 seconds.
	
	2 seconds wait
]

{ #category : #testing }
SUnitTest >> testSelectorWithArg: anObject [
	"should not result in error"
]

{ #category : #testing }
SUnitTest >> testShould [

	self
		should: [true];
		shouldnt: [false]
]

{ #category : #testing }
SUnitTest >> testShouldIgnoreTimeLimitWhenTestProcessIsSuspended [
	"If you open debugger on test (by halt or error) and will not close it more then test time limit then following interaction with debugger will fail. 
	As simple fix watch dog should check that test process is not suspended. It of course will open possibility to hang test execution when tested code will suspend active process by incident. But we could live with it and probably it could be addressed too in future"
	| testProcess |
	self timeLimit: 30 milliSeconds.
	testProcess := Processor activeProcess.
	[ 50 milliSeconds wait. testProcess resume ] fork.
	testProcess suspend.
	self assert: true.
]

{ #category : #testing }
SUnitTest >> testSuite [
	| suite result |
	suite := self classForTestSuite new.
	suite
		addTest: (self newTestCase: #noop);
		addTest: (self newTestCase: #fail);
		addTest: (self newTestCase: #error).
	result := suite run.
	self
		assertForTestResult: result
		runCount: 3
		passed: 1
		failed: 1
		errors: 1
]

{ #category : #testing }
SUnitTest >> testWatchDogProcessShouldNotBeCatchedAsForkedProcess [
	| env |
	env := self executionEnvironment.

	self assertEmpty: env forkedProcesses
]

{ #category : #testing }
SUnitTest >> testWithExceptionDo [

	self
		should: [self error: 'foo']
		raise: self defaultTestError
		withExceptionDo: [:exception |
			self assert: (exception description includesSubstring: 'foo')
		]
]
