Class {
	#name : #RBInlineTemporaryTransformation,
	#superclass : #RBCompositeMethodTransformation,
	#instVars : [
		'sourceInterval',
		'sourceTree',
		'assignmentNode',
		'definingNode'
	],
	#category : #'Refactoring2-Transformations-Model-Migrated'
}

{ #category : #api }
RBInlineTemporaryTransformation class >> inline: anInterval from: aSelector in: aClass [
	^ self new 
		inline: anInterval
		from: aSelector
		in: aClass
]

{ #category : #api }
RBInlineTemporaryTransformation class >> model: aRBNamespace inline: anInterval from: aSelector in: aClass [
	^ self new
		model: aRBNamespace;
		inline: anInterval
		from: aSelector
		in: aClass;
		yourself
]

{ #category : #executing }
RBInlineTemporaryTransformation >> buildTransformations [
	^ OrderedCollection 
		with: self replaceAssignment
		with: self replaceReferences
]

{ #category : #testing }
RBInlineTemporaryTransformation >> hasOnlyOneAssignment [
	| searcher |
	searcher := self parseTreeSearcher.
	searcher
		matches: assignmentNode variable name , ' := ``@object'
		do: [ :aNode :answer | answer + 1 ].
	^ (searcher executeTree: definingNode initialAnswer: 0) == 1
]

{ #category : #api }
RBInlineTemporaryTransformation >> inline: anInterval from: aSelector in: aClass [
	class := self model classObjectFor: aClass.
	selector := aSelector.
	sourceInterval := anInterval
]

{ #category : #preconditions }
RBInlineTemporaryTransformation >> preconditions [
	^(RBCondition definesSelector: selector in: class) 
		& (RBCondition withBlock: 
					[self verifySelectedInterval.
					true])
]

{ #category : #executing }
RBInlineTemporaryTransformation >> replaceAssignment [
	^ RBCustomTransformation model: self model with: [ :rbModel |
		assignmentNode parent isSequence 
		ifTrue: [assignmentNode parent removeNode: assignmentNode]
		ifFalse: [assignmentNode replaceWith: assignmentNode value]]
]

{ #category : #executing }
RBInlineTemporaryTransformation >> replaceReferences [
	^ RBCustomTransformation model: self model with: [ :rbModel |
	| rewriter |
	rewriter := self parseTreeRewriter.
	rewriter replaceTree: assignmentNode variable
		withTree: assignmentNode value.
	definingNode removeTemporaryNamed: assignmentNode variable name.
	rewriter executeTree: definingNode.
	class compileTree: sourceTree ]
]

{ #category : #printing }
RBInlineTemporaryTransformation >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream nextPutAll: ' inline: '.
	sourceInterval storeOn: aStream.
	aStream
		nextPutAll: ' from: #';
		nextPutAll: selector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #preconditions }
RBInlineTemporaryTransformation >> verifySelectedInterval [

	sourceTree := class parseTreeFor: selector.
	sourceTree ifNil: [ self refactoringFailure: 'Could not parse source' ].
	assignmentNode := sourceTree whichNodeIsContainedBy: sourceInterval.
	assignmentNode isAssignment
		ifFalse: [ self refactoringFailure: 'The selected node is not an assignment statement' ].
	definingNode := assignmentNode whoDefines: assignmentNode variable name.
	self hasOnlyOneAssignment
		ifFalse: [ self refactoringError: 'There are multiple assignments to the variable' ].
	( RBReadBeforeWrittenTester
		isVariable: assignmentNode variable name
		writtenBeforeReadIn: definingNode )
		ifFalse: [ self refactoringError: 'The variable is possible read before it is assigned' ]
]
