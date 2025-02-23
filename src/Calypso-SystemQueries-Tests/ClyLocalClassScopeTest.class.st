Class {
	#name : #ClyLocalClassScopeTest,
	#superclass : #ClyAbstractClassScopeTest,
	#category : #'Calypso-SystemQueries-Tests-Scopes'
}

{ #category : #testing }
ClyLocalClassScopeTest class >> isAbstract [
	^self = ClyLocalClassScopeTest
]

{ #category : #tests }
ClyLocalClassScopeTest >> testConvertingToFullHierarchyScope [
	| convertedScope inheritedScope |
	scope := self createSampleScope.
	inheritedScope := scope asInheritedScope.
	
	convertedScope := scope asFullHierarchyScope.
	
	self assert: convertedScope class equals: ClyCompositeScope.
	self assert: convertedScope name equals: ClyClassScope hierarchyScopeName.
	self assert: (convertedScope subscopes includes: scope).
	self assert: (convertedScope subscopes includes: inheritedScope).
	self assert: (convertedScope subscopes includes: (
		ClySubclassScope ofAll: scope basisObjects localScope: scope class))
]

{ #category : #tests }
ClyLocalClassScopeTest >> testConvertingToInheritedScope [
	| convertedScope |
	scope := self createSampleScope.
	
	convertedScope := scope asInheritedScope.
	
	self assert: (convertedScope representsScope: ClySuperclassScope).
	self assert: convertedScope localScopeClass equals: self scopeClass.
	self assert: convertedScope basisObjects equals: scope basisObjects.
	self assert: convertedScope environment equals: environment.
	self assert: convertedScope name equals: ClyClassScope inheritedScopeName
]

{ #category : #tests }
ClyLocalClassScopeTest >> testConvertingToNewMetaLevel [
	| convertedScope |
	scope := self createSampleScope.
	
	convertedScope := scope withMetaLevel: ClyInstanceSideScope.
	
	self assert: convertedScope class equals: ClyInstanceSideScope.
	self assert: convertedScope basisObjects equals: scope basisObjects.
	self assert: convertedScope environment equals: environment
]

{ #category : #tests }
ClyLocalClassScopeTest >> testConvertingToScopeIncludedInheritedScope [
	| convertedScope inheritedScope |
	scope := self createSampleScope.
	inheritedScope := scope asInheritedScope.
	
	convertedScope := scope withInheritedScope.
	
	self assert: convertedScope class equals: ClyCompositeScope.
	self assert: convertedScope name equals: ClyClassScope hierarchyScopeName.
	self assert: (convertedScope subscopes includes: scope).
	self assert: (convertedScope subscopes includes: inheritedScope)
]

{ #category : #tests }
ClyLocalClassScopeTest >> testConvertingToScopeIncludedInheritingScope [
	| convertedScope inheritingScope |
	scope := self createSampleScope.
	inheritingScope := scope asInheritingScope.
	
	convertedScope := scope withInheritingScope.
	
	self assert: convertedScope class equals: ClyCompositeScope.
	self assert: convertedScope name equals: ClyClassScope userHierarchyScopeName.
	self assert: (convertedScope subscopes includes: scope).
	self assert: (convertedScope subscopes includes: inheritingScope)
]
