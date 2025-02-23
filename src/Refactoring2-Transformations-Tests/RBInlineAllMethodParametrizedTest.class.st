Class {
	#name : #RBInlineAllMethodParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBInlineAllMethodParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBInlineAllSendersRefactoring };
		yourself
]

{ #category : #accessing }
RBInlineAllMethodParametrizedTest >> constructor [ 
	^ #sendersOf:in:
]

{ #category : #tests }
RBInlineAllMethodParametrizedTest >> testInlineMethodCalledAsSuper [
	| class superclass |
	model := RBClassModelFactory rbNamespace new.
	superclass := model classNamed: self class superclass name.
	superclass compile: 'foo: arg1 bar: arg2 ^ arg1 + arg2' classified: #(#accessing).
	class := model classNamed: self class name.
	class compile: 'foo: arg1 bar: arg2 ^ (super foo: arg1 bar: arg2) - arg1' classified: #(#accessing).
	self executeRefactoring: (self createRefactoringWithModel: model
		andArguments: { #foo:bar: . superclass }).
	self assert: (class parseTreeFor: #foo:bar:) 
			equals: (self parseMethod: 'foo: arg1 bar: arg2 ^ (arg1 + arg2) - arg1')
]

{ #category : #'failure tests' }
RBInlineAllMethodParametrizedTest >> testInlineMethodCanNotUnderstandSelectorInClass [
	| refactoring |
	refactoring := self createRefactoringWithArguments: 
		{ #caller3 .RBRefactoryTestDataApp }.
	self shouldFail: refactoring.
]

{ #category : #tests }
RBInlineAllMethodParametrizedTest >> testInlineMethodWithMultipleArgs [
	| class |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class
		compile: 'foo: arg1 bar: arg2 ^ arg1 + arg2' classified: #(#accessing);
		compile: 'exampleInline | x | x := 3 + (self foo: a bar: b). ^ (self foo: 5 bar: 7)' 
		classified: #(#accessing).
	self executeRefactoring: (self createRefactoringWithModel: model
		andArguments: { #foo:bar: . class }).
	self assert: (class parseTreeFor: #exampleInline) 
			equals: (self parseMethod: 'exampleInline
	| x |
	x := 3 + (a + b).
	^ 5 + 7').
]

{ #category : #tests }
RBInlineAllMethodParametrizedTest >> testInlineMethodWithMultipleSendersInMethod [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := self createRefactoringWithArguments:  
		{ methodName . RBRefactoryTestDataApp }.
	self executeRefactoring: refactoring.
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #inlineLast) equals: (self parseMethod: 'inlineLast
	5 = 3 ifTrue: [^self caller] ifFalse: [^(1 to: 10) inject: 1 into: [:sum :each | sum * (self foo: each)]] ').
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #multipleCalls) equals: (self parseMethod: 'multipleCalls
	(1 to: 10) inject: 1 into: [:sum :each | sum * (self foo: each)].
	(1 to: 10) inject: 1 into: [:sum1 :each1 | sum1 * (self foo: each1)]')
]

{ #category : #tests }
RBInlineAllMethodParametrizedTest >> testRecursiveMethod [
	| class |
	model := RBClassModelFactory rbNamespace new.
	class := model classNamed: self class name.
	class
		compile: 'foo ^self foo' classified: #(#accessing);
		compile: 'bar ^self foo' classified: #(#accessing).
	self executeRefactoring: (self createRefactoringWithModel: model
		andArguments: { #foo . class }).
	self assert: (class parseTreeFor: #foo) 
			equals: (self parseMethod: 'foo ^self foo').
	self assert: (class parseTreeFor: #bar) 
			equals: (self parseMethod: 'bar ^self foo')
]
