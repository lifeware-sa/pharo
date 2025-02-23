Class {
	#name : #OCASTCheckerTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Tests-AST'
}

{ #category : #utilities }
OCASTCheckerTest >> nameAnalysisNoClosureIn: class for: ast [
	"Look up vars in classOrScope.  My tree will be annotated with bindings to Scopes and Variables."

	OCASTSemanticAnalyzer new
		compilationContext: class compiler compilationContext;
		visitNode: ast.
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testDoubleRemoteAnidatedBlocks [
	| ast scopes |
	ast := (OCOpalExamples >> #doubleRemoteAnidatedBlocks) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self assert: (ast scope lookupVar: 'last') isEscaping.
	self assert: (ast scope lookupVar: 'val') isEscaping.

	scopes := (OCScopesCollector new visitNode: ast) scopes.
	self assert: scopes size equals: 4.

	self assert: (scopes second lookupVar: 'i') isEscaping.	"This is due to the inlined block."


	self assert: scopes third tempVars size equals: 1.
	self deny: (scopes third lookupVar: 'continue') isEscaping	"It is not escaping since is being accessed in an optimized block."
]

{ #category : #'tests - simple' }
OCASTCheckerTest >> testExampleIfNotNilReturnNil [
	| ast |
	ast := (OCOpalExamples >> #exampleIfNotNilReturnNil) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0
]

{ #category : #'tests - blocks - optimized' }
OCASTCheckerTest >> testExampleInlineBlockCollectionLR3 [
	| ast |
	ast := (OCOpalExamples >> #exampleInlineBlockCollectionLR3) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 1	"index is a temp of the outer method due to optimized block"
]

{ #category : #'tests - primitives' }
OCASTCheckerTest >> testExamplePrimitiveErrorCode [
	| ast |
	ast := (OCOpalExamples>>#examplePrimitiveErrorCode) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.

	self assert: (ast scope lookupVar: 'code') isLocalVariable.
	self deny: (ast scope lookupVar: 'code') isUninitialized.
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testExampleSelf [
	| ast assignment |
	ast := (OCOpalExamples>>#exampleSelf) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0.
	self assert: (ast scope lookupVar: 'self') isSelfVariable.
	
	assignment := RBParseTreeSearcher treeMatching: 'self result: ``@anything' in: ast. 
	self assert: assignment arguments first variable isSelfVariable.
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testExampleSelfReceiver [
	| ast |
	ast := (OCOpalExamples>>#exampleSelfReceiver) parseTree.
	self assert: ast body statements first receiver isSelfVariable.
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testExampleSuper [
	| ast assignment |
	ast := (OCOpalExamples>>#exampleSuper) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0.
	self assert: (ast scope lookupVar: 'super') isSuperVariable.
	
	assignment := RBParseTreeSearcher treeMatching: 'self result:``@anything' in: ast. 
	self assert: assignment arguments first variable isSuperVariable.
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testExampleSuperReceiver [
	| ast |
	ast := (OCOpalExamples>>#exampleSuperReceiver) parseTree.
	self assert: ast body statements first receiver isSuperVariable
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testExampleThisContext [ 
	| ast assignment |
	ast := (OCOpalExamples>>#exampleThisContext) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0.
	self assert: (ast scope lookupVar: 'thisContext') isThisContextVariable.
	
	assignment := RBParseTreeSearcher treeMatching: 'self result: ``@anything' in: ast. 
	self assert: assignment arguments first variable isThisContextVariable.
]

{ #category : #'tests - blocks - optimized' }
OCASTCheckerTest >> testExampleToDoArgument [
	| ast |
	ast := (OCOpalExamples >> #exampleToDoArgument) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testInstanceVar [
	| ast assignment |
	ast := (OCOpalExamples >> #exampleInstanceVariableAssignment) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assertEmpty: ast scope tempVars.
	self assert: (ast scope outerScope lookupVar: 'iVar') isInstanceVariable.

	assignment := RBParseTreeSearcher treeMatching: '`var := ``@anything' in: ast.
	self assert: assignment variable isInstanceVariable
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testNoRemoteBlockArgument [
	| ast |
	ast := (OCOpalExamples >> #noRemoteBlockArgument) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 3.

	self deny: (ast scope lookupVar: 'block') isEscaping.
	self deny: (ast scope lookupVar: 'block1') isEscaping.
	self deny: (ast scope lookupVar: 'block2') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testNoRemoteBlockReturn [
	| ast |
	ast := (OCOpalExamples >> #noRemoteBlockReturn) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 0
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testNoRemoteBlockTemp [
	| ast |
	ast := (OCOpalExamples >> #noRemoteBlockTemp) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 3.

	self deny: (ast scope lookupVar: 'block') isEscaping.
	self deny: (ast scope lookupVar: 'block1') isEscaping.
	self deny: (ast scope lookupVar: 'block2') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testNoRemoteMethodTemp [
	| ast |
	ast := (OCOpalExamples >> #noRemoteMethodTemp) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self deny: (ast scope lookupVar: 'block1') isEscaping.
	self deny: (ast scope lookupVar: 'block2') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testOptimizedBlockWrittenAfterClosedOverCase1 [
	| ast scopes |
	ast := (OCOpalExamples >> #optimizedBlockWrittenAfterClosedOverCase1) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 1.

	"index is not escaping as it is (due to the optimized block) defined in the same block"
	self deny: (ast scope lookupVar: 'index') isEscaping.
	self assert: (ast scope lookupVar: 'index') scope equals: ast scope.

	scopes := (OCScopesCollector new visitNode: ast) scopes.

	self assert: (scopes third lookupVar: 'temp') isWrite.
	self assert: (scopes third lookupVar: 'temp') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testOptimizedBlockWrittenAfterClosedOverCase2 [
	| ast scopes |
	ast := (OCOpalExamples >> #optimizedBlockWrittenAfterClosedOverCase2) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 1.

	self deny: (ast scope lookupVar: 'index') isEscaping.
	self assert: (ast scope lookupVar: 'index') scope equals: ast scope.

	scopes := (OCScopesCollector new visitNode: ast) scopes.

	self assert: (scopes third lookupVar: 'temp') isEscapingWrite.
	self assert: (scopes third lookupVar: 'temp') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testOptimizedBlocksAndSameNameTemps [
	| ast scopes |
	ast := (OCOpalExamples >> #optimizedBlocksAndSameNameTemps) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self deny: (ast scope lookupVar: 's') isRemote.
	self deny: (ast scope lookupVar: 'c') isRemote.

	scopes := (OCScopesCollector new visitNode: ast) scopes.

	self deny: (scopes second lookupVar: 'a') isRemote.
	self deny: (scopes fourth lookupVar: 'i') isRemote
]

{ #category : #'tests - simple' }
OCASTCheckerTest >> testReturn1 [
	| ast |
	ast := (OCOpalExamples >> #exampleReturn42) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assertEmpty: ast scope tempVars
]

{ #category : #'tests - simple' }
OCASTCheckerTest >> testSemanticAnalysisOnNonMethodNode [
	| ast |
	{[ 1 + 2 ].
	thisContext.
	(OCOpalExamples >> #exampleReturn42)}
		do: [ :object | 
			ast := object sourceNode].
	#('1' 'true' 'nil' '1 + 2' '^1' '1 + 2. 2 + 3' '#(1 true)' '{ #foo . 1 }' '1+2;+3')
		do: [ :source | 
			ast := RBParser parseExpression: source.
			ast doSemanticAnalysis ].
	ast := RBParser parseMethod: 'foo 1 + 2'.
	ast doSemanticAnalysis
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testSingleRemoteDifferentBlocksSameArgumentName [
	| ast |
	ast := (OCOpalExamples >> #singleRemoteDifferentBlocksSameArgumentName) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 3.

	self deny: (ast scope lookupVar: 'b') isEscaping.
	self deny: (ast scope lookupVar: 'c') isEscaping.
	self assert: (ast scope lookupVar: 'z') isEscaping
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testSingleRemoteMethodArgument [
	| ast |
	ast := (OCOpalExamples >> #singleRemoteMethodArgument) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self deny: (ast scope lookupVar: 'block') isEscaping.
	self assert: (ast scope lookupVar: 'temp') isEscaping.
	self assert: (ast scope lookupVar: 'temp') isWrite
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testSingleRemoteTempVar [
	| ast |
	ast := (OCOpalExamples >> #singleRemoteTempVar) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 3.

	self assert: (ast scope lookupVar: 'index') isEscaping.
	self assert: (ast scope lookupVar: 'index') scope equals: ast scope.
	self deny: (ast scope lookupVar: 'block') isEscaping.
	self assert: (ast scope lookupVar: 'theCollection') isEscaping.
	self assert: (ast scope lookupVar: 'block') isTempVariable.
	self assert: (ast scope lookupVar: 'theCollection') isTempVariable.
	self deny: (ast scope lookupVar: 'theCollection') isInstanceVariable.
	self deny: (ast scope lookupVar: 'index') isInstanceVariable.
	self deny: (ast scope lookupVar: 'block') isInstanceVariable
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testsingleRemoteTempVarWhileWithTempNotInlined [
	| ast |
	ast := (OCOpalExamples >> #exampleWhileWithTempNotInlined) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self assert: (ast scope lookupVar: 'index') isEscaping.
	self assert: (ast scope lookupVar: 'index') scope equals: ast scope.
	self deny: (ast scope lookupVar: 'block') isEscaping.
	self assert: (ast scope lookupVar: 'block') isTempVariable
]

{ #category : #'tests - variables' }
OCASTCheckerTest >> testsingleRemoteTempVarWrittenAfterClosedOver [
	| ast |
	ast := (OCOpalExamples >> #singleRemoteTempVarWrittenAfterClosedOver) parseTree.
	self nameAnalysisNoClosureIn: OCOpalExamples for: ast.
	self assert: ast scope isMethodScope.
	self assert: ast scope tempVars size equals: 2.

	self assert: (ast scope lookupVar: 'index') isWrite.
	self assert: (ast scope lookupVar: 'index') scope equals: ast scope.
	self deny: (ast scope lookupVar: 'block') isEscaping.
	self assert: (ast scope lookupVar: 'block') isTempVariable
]
