Class {
	#name : #OCASTDoubleBranchConditionalTranslatorTest,
	#superclass : #OCASTDoubleBlockTranslatorTest,
	#category : #'OpalCompiler-Tests-AST'
}

{ #category : #'building suites' }
OCASTDoubleBranchConditionalTranslatorTest class >> testParameters [
	^ super testParameters *
		(ParametrizedTestMatrix new
			forSelector: #optimization addOptions: { #optionInlineIf . #optionInlineIfNil . #optionInlineNone })
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testFalseIfFalseIfTrueEvaluatesFalseBlock [

	self
		testComposedExample: 'example
	{definition}.
	^false ifFalse: {argument1} ifTrue: {argument2}'
		withFirstBlock: '[iVar := ''false'']'
		withSecondBlock: '[ self error ]'.

	self assert: instance iVar equals: 'false'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testFalseIfFalseIfTrueReturnsFalseBlockValue [
	| result |
	result := self
		testComposedExample: 'example
	{definition}.
	^false ifFalse: {argument1} ifTrue: {argument2}'
		withFirstBlock: '[iVar := ''false'']'
		withSecondBlock: '[ self error ]'..
	self assert: result equals: 'false'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testFalseIfTrueIfFalseEvaluatesFalseBlock [

	self
		testComposedExample: 'example
	{definition}.
	^false ifTrue: {argument1} ifFalse: {argument2}'
		withFirstBlock: '[ self error ]'
		withSecondBlock: '[iVar := ''false'']'.

	self assert: instance iVar equals: 'false'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testFalseIfTrueIfFalseReturnsFalseBlockValue [
	| result |
	result := self
		testComposedExample: 'example
	{definition}.
	^false ifTrue: {argument1} ifFalse: {argument2}'
		withFirstBlock: '[ self error ]'
		withSecondBlock: '[iVar := ''false'']'.

	self assert: result equals: 'false'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testTrueIfFalseIfTrueEvaluatesTrueBlock [

	self
		testComposedExample: 'example
	{definition}.
	^true ifFalse: {argument1} ifTrue: {argument2}'
		withFirstBlock: '[ self error ]'
		withSecondBlock: '[iVar := ''true'']'.

	self assert: instance iVar equals: 'true'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testTrueIfFalseIfTrueReturnsTrueBlockValue [
	| result |
	result := self
		testComposedExample: 'example
	{definition}.
	^true ifFalse: {argument1} ifTrue: {argument2}'
		withFirstBlock: '[ self error ]'
		withSecondBlock: '[iVar := ''true'']'.
	self assert: result equals: 'true'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testTrueIfTrueIfFalseEvaluatesTrueBlock [

	self
		testComposedExample: 'example
	{definition}.
	^true ifTrue: {argument1} ifFalse: {argument2}'
		withFirstBlock: '[iVar := ''true'']'
		withSecondBlock: '[ self error ]'.

	self assert: instance iVar equals: 'true'
]

{ #category : #'tests - conditionals' }
OCASTDoubleBranchConditionalTranslatorTest >> testTrueIfTrueIfFalseReturnsTrueBlockValue [
	| result |
	result := self
		testComposedExample: 'example
	{definition}.
	^true ifTrue: {argument1} ifFalse: {argument2}'
		withFirstBlock: '[iVar := ''true'']'
		withSecondBlock: '[ self error ]'.

	self assert: result equals: 'true'
]
