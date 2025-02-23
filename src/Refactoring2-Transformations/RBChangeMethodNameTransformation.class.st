Class {
	#name : #RBChangeMethodNameTransformation,
	#superclass : #RBMethodTransformation,
	#instVars : [
		'newSelector',
		'oldSelector',
		'permutation',
		'implementors',
		'renameMap'
	],
	#category : #'Refactoring2-Transformations-Model'
}

{ #category : #support }
RBChangeMethodNameTransformation >> convertAllReferencesTo: aSymbol of: classes using: searchReplacer [ 
	(self model allReferencesTo: aSymbol in: classes)
		do: 
			[:eachMethod | 
			self 
				convertMethod: eachMethod selector
				for: eachMethod modelClass
				using: searchReplacer]
]

{ #category : #support }
RBChangeMethodNameTransformation >> convertAllReferencesTo: aSymbol using: searchReplacer [ 
	|aBlock|
	aBlock := [:eachMethod | 
			self 
				convertMethod: eachMethod  selector
				for: eachMethod modelClass
				using: searchReplacer].
	self model allReferencesTo: aSymbol do: aBlock
]

{ #category : #support }
RBChangeMethodNameTransformation >> hasPermutedArguments [
	oldSelector numArgs = newSelector numArgs ifFalse: [^true].
	1 to: oldSelector numArgs
		do: [:i | (permutation at: i) = i ifFalse: [^true]].
	^false
]

{ #category : #support }
RBChangeMethodNameTransformation >> implementors [

	implementors ifNil: [ implementors := self model allImplementorsOf: oldSelector ].
	^ implementors
]

{ #category : #support }
RBChangeMethodNameTransformation >> implementorsCanBePrimitives [
	^false
]

{ #category : #support }
RBChangeMethodNameTransformation >> modifyImplementorParseTree: parseTree in: aClass [ 
	| oldArgs |
	oldArgs := parseTree arguments.
	parseTree renameSelector: newSelector andArguments: (permutation collect: [:each | oldArgs at: each])
]

{ #category : #support }
RBChangeMethodNameTransformation >> myConditions [
	"^self subclassResponsibility"
]

{ #category : #support }
RBChangeMethodNameTransformation >> newSelector [
	^newSelector
]

{ #category : #support }
RBChangeMethodNameTransformation >> parseTreeRewriter [
	| rewriteRule oldString newString |
	rewriteRule := self parseTreeRewriterClass new.
	oldString := self buildSelectorString: oldSelector.
	newString := self buildSelectorString: newSelector
				withPermuteMap: permutation.
	rewriteRule replace: '``@object ' , oldString
		with: '``@object ' , newString.
	^rewriteRule
]

{ #category : #preconditions }
RBChangeMethodNameTransformation >> preconditions [
	"This refactoring only preserves behavior if all implementors are renamed."

	| conditions |
	conditions := self myConditions 
				& (RBCondition definesSelector: oldSelector in: class) 
				& (RBCondition isValidMethodName: newSelector for: class).
					
	conditions := self implementors 
		inject: conditions into: [ :condition :each | 
			condition & (RBCondition hierarchyOf: each canUnderstand: newSelector) not ].
		
	^conditions & (RBCondition withBlock: 
		[self implementors size > 1 
			ifTrue: 
				[self refactoringWarning: ('This will modify all <1p> implementors. Proceed anyway?' 
							expandMacrosWith: self implementors size)].
		true])
]

{ #category : #support }
RBChangeMethodNameTransformation >> privateTransform [ 
	self renameImplementors.
	self renameMessageSends.
	self removeRenamedImplementors
]

{ #category : #support }
RBChangeMethodNameTransformation >> removeRenamedImplementors [
	oldSelector = newSelector
		ifTrue: [ ^ self ].
	self implementors 
		do: [ :each | each removeMethod: oldSelector ]
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameArgumentsIn: parseTree [
	self renameMap do: [ :arg |
		(self parseTreeRewriterClass rename: arg name to: arg newName) executeTree: parseTree
	]
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameImplementors [

	self implementors
		do: [ :each | 
			| parseTree |

			parseTree := each parseTreeFor: oldSelector.
			parseTree ifNil: [ self refactoringFailure: 'Could not parse source code.' ].
			self implementorsCanBePrimitives
				ifFalse: [ parseTree isPrimitive
						ifTrue: [ self
								refactoringFailure:
									( '<1p>''s implementation of #<2s> is a primitive' expandMacrosWith: each with: oldSelector )
							]
					].
			self modifyImplementorParseTree: parseTree in: each.
			( each methodFor: oldSelector ) compileTree: parseTree
			]
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameMap [
	^renameMap ifNil: [ renameMap := { } ]
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameMap: aColl [
	renameMap := aColl
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameMessageSends [
	self convertAllReferencesTo: oldSelector using: self parseTreeRewriter
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameMessageSendsIn: classes [
	self convertAllReferencesTo: oldSelector of: classes using: self parseTreeRewriter
]

{ #category : #support }
RBChangeMethodNameTransformation >> renameMethod: aSelector in: aClass to: newSel permutation: aMap [ 
	oldSelector := aSelector asSymbol.
	newSelector := newSel asSymbol.
	class := self model classObjectFor: aClass.
	permutation := aMap.
]
