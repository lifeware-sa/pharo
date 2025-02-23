"
A trait for test purposes
"
Trait {
	#name : #TSetArithmetic,
	#category : #'Collections-Abstract-Tests-Traits'
}

{ #category : #requirements }
TSetArithmetic >> anotherElementOrAssociationIn [
	" return an element (or an association for Dictionary ) present  in 'collection' "
	^ self explicitRequirement
]

{ #category : #requirements }
TSetArithmetic >> anotherElementOrAssociationNotIn [
	" return an element (or an association for Dictionary )not present  in 'collection' "
	^ self explicitRequirement
]

{ #category : #requirements }
TSetArithmetic >> collection [

	^ self explicitRequirement
]

{ #category : #requirements }
TSetArithmetic >> collectionClass [
	"Return the class to be used to create instances of the class tested"
	
	^ self explicitRequirement
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> containsAll: union of: one andOf: another [
			
	self assert: (one allSatisfy: [:each | union includes: each]).
	self assert: (another allSatisfy: [:each | union includes: each])
]

{ #category : #requirements }
TSetArithmetic >> nonEmpty [

	^ self explicitRequirement
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> numberOfSimilarElementsInIntersection [

	^ self collection occurrencesOf: self anotherElementOrAssociationIn
]

{ #category : #'tests - fixture' }
TSetArithmetic >> test0FixtureSetAritmeticTest [
	self collection.
	self denyEmpty: self collection.
	self nonEmpty.
	self denyEmpty: self nonEmpty.
	self anotherElementOrAssociationNotIn.
	self collection isDictionary
		ifTrue: [ self deny: (self collection associations includes: self anotherElementOrAssociationNotIn key) ]
		ifFalse: [ self deny: (self collection includes: self anotherElementOrAssociationNotIn) ].
	self collectionClass
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testDifference [
	"Answer the set theoretic difference of two collections."

	| difference |
	self assertEmpty: (self collectionWithoutEqualElements difference: self collectionWithoutEqualElements).
	self assertEmpty: (self empty difference: self collectionWithoutEqualElements).
	difference := self collectionWithoutEqualElements difference: self empty.
	self assert: difference size = self collectionWithoutEqualElements size.
	self collectionWithoutEqualElements do: [ :each | self assert: (difference includes: each) ]
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testDifferenceWithNonNullIntersection [
	"Answer the set theoretic difference of two collections. 
	 	#(1 2 3) difference: #(2 4) ->  #(1 3)"
	
	| res overlapping |
	overlapping := self collectionClass 
		with: self anotherElementOrAssociationNotIn
		with: self anotherElementOrAssociationIn.
	res := self collection difference: overlapping.
	self deny: (res includes: self anotherElementOrAssociationIn).
	overlapping do: [ :each | self deny: (res includes: each) ]
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testDifferenceWithSeparateCollection [
	"Answer the set theoretic difference of two collections."

	| res separateCol |	
	separateCol := self collectionClass with: self anotherElementOrAssociationNotIn.
	res := self collectionWithoutEqualElements difference: separateCol.
	
	self deny: (res includes: self anotherElementOrAssociationNotIn).
	self assert: res size equals: self collectionWithoutEqualElements size.
	
	self collectionWithoutEqualElements do: [ :each|
		self assert: (res includes: each)].
	
	res := separateCol difference: self collection.
	self deny: (res includes: self collection anyOne).
	self assert: res equals: separateCol
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testIntersectionBasic [
	| inter |
	inter := self collection intersection: (self collectionClass with: self anotherElementOrAssociationIn).
	self denyEmpty: inter.
	self assert: (inter includes: self anotherElementOrAssociationIn value)
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testIntersectionEmpty [
	| inter |
	inter := self empty intersection: self empty.
	self assertEmpty: inter.
	inter := self empty intersection: self collection.
	self assert: inter equals: self empty
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testIntersectionItself [
	
	| result |
	result := self collectionWithoutEqualElements intersection: self collectionWithoutEqualElements.
	self assert: result size equals: self collectionWithoutEqualElements size.
	self collectionWithoutEqualElements do: [ :each|
		self assert: (result includes: each) ].
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testIntersectionTwoSimilarElementsInIntersection [

	| inter |
	inter := self collection intersection: (self collectionClass with: self anotherElementOrAssociationIn).
	self assert: (self collection occurrencesOf: self anotherElementOrAssociationIn) equals: self numberOfSimilarElementsInIntersection.
	self assert: (inter includes: self anotherElementOrAssociationIn value)
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testUnion [
	
	| union |
	union := self empty union: self nonEmpty.
	self containsAll: union of: self empty andOf: self nonEmpty.
	union := self nonEmpty union: self empty.
	self containsAll: union of: self empty andOf: self nonEmpty.
	union := self collection union: self nonEmpty.
	self containsAll: union of: self collection andOf: self nonEmpty.
]

{ #category : #'tests - set arithmetic' }
TSetArithmetic >> testUnionOfEmpties [
	self assertEmpty: (self empty union: self empty)
]
