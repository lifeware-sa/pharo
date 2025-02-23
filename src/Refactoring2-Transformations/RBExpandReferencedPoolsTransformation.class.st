Class {
	#name : #RBExpandReferencedPoolsTransformation,
	#superclass : #RBTransformation,
	#instVars : [
		'pools',
		'fromClass',
		'parseTree',
		'toClasses'
	],
	#category : #'Refactoring2-Transformations-Model-Migrated'
}

{ #category : #api }
RBExpandReferencedPoolsTransformation class >> forMethod: aParseTree fromClass: aClass toClasses: classCollection [
	^ self new
		forMethod: aParseTree
		fromClass: aClass
		toClasses: classCollection;
		yourself
]

{ #category : #api }
RBExpandReferencedPoolsTransformation class >> model: aRBNamespace forMethod: aParseTree fromClass: aClass toClasses: classCollection [
	^ self new
		model: aRBNamespace;
		forMethod: aParseTree
		fromClass: aClass
		toClasses: classCollection;
		yourself
]

{ #category : #transforming }
RBExpandReferencedPoolsTransformation >> computePoolsToMove [

	| poolVariables searcher |
	poolVariables := self poolVariableNamesFor: fromClass.
	pools := Set new.
	searcher := self parseTreeSearcher.
	searcher
		matches: '`var'
		do: [ :aNode :answer | 
			| varName pool |

			varName := aNode name.
			( aNode whoDefines: varName )
				ifNil: [ ( poolVariables includes: varName )
						ifTrue: [ pool := self whichPoolDefines: varName.
							pool ifNotNil: [ pools add: pool ]
							]
					]
			].
	searcher executeTree: parseTree
]

{ #category : #api }
RBExpandReferencedPoolsTransformation >> forMethod: aParseTree fromClass: aClass toClasses: classCollection [
	fromClass := self model classFor: aClass.
	parseTree := aParseTree.
	toClasses := classCollection collect: [:each | self model classFor: each]
]

{ #category : #testing }
RBExpandReferencedPoolsTransformation >> hasPoolsToMove [
	^pools isNotEmpty
]

{ #category : #preconditions }
RBExpandReferencedPoolsTransformation >> movePool: aSymbol toClass: aClass [
	| nonMetaClass |
	nonMetaClass := aClass instanceSide.
	(nonMetaClass definesPoolDictionary: aSymbol) ifFalse: [ nonMetaClass addPoolDictionary: aSymbol ]
]

{ #category : #executing }
RBExpandReferencedPoolsTransformation >> movePoolVariables [
	pools 
		do: [:poolDict | toClasses do: [:each | self movePool: poolDict toClass: each]]
]

{ #category : #preconditions }
RBExpandReferencedPoolsTransformation >> preconditions [

	^ self emptyCondition
]

{ #category : #transforming }
RBExpandReferencedPoolsTransformation >> privateTransform [

	self computePoolsToMove.
	self hasPoolsToMove 
		ifTrue: 
			[self 
				refactoringWarning: 'This method contains references to pools<n>which may need to be moved.<n>Proceed anyway?' 
						expandMacros].
	self movePoolVariables
]

{ #category : #printing }
RBExpandReferencedPoolsTransformation >> storeOn: aStream [

	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' forMethod: '''.
	parseTree storeOn: aStream.
	aStream
		nextPutAll: ''' fromClass: ''';
		nextPutAll: fromClass name;
		nextPutAll: ''' toClasses: '.
	toClasses storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #testing }
RBExpandReferencedPoolsTransformation >> whichPoolDefines: varName [
	| currentClass |
	currentClass := fromClass.
	[currentClass isNil] whileFalse: 
			[currentClass allPoolDictionaryNames 
				detect: [:each | ((self poolVariableNamesIn: each) includes: varName)] ifFound: [ :each | ^ each ].
			currentClass := currentClass superclass].
	^nil
]
