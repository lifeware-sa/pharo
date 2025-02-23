Class {
	#name : #CDFluidClassParserTest,
	#superclass : #TestCase,
	#category : #'ClassParser-Tests'
}

{ #category : #running }
CDFluidClassParserTest >> classDefinitionParserClass [

	^ CDFluidClassDefinitionParser
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testClassSideDefinitionIsClassSide [

	| def |
	def := self classDefinitionParserClass parse: 'Object class << Point class
			slot: {  }'.

	self assert: def isClassSide
]

{ #category : #'tests - (r) class side' }
CDFluidClassParserTest >> testClassSideEmpty [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object class << AlignmentMorph class
		'.		
	def := parser parse: defString.
	self assert: def class equals: CDMetaclassDefinitionNode.
]

{ #category : #'tests - (r) class side' }
CDFluidClassParserTest >> testClassSideWithTraits [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object class << AlignmentMorph class
		traits: TableRotate classTrait;
		slots: { #x . #y}'.
		
	def := parser parse: defString.
	self assert: def class equals: CDMetaclassDefinitionNode.
	self assert: def hasTraitComposition.
	self assert: def traitDefinition class equals: CDClassTraitNode.
	self assert: def traitDefinition name equals: #TableRotate.
	self assert: def slots first name equals: #x
]

{ #category : #'tests - (r) class variables' }
CDFluidClassParserTest >> testClassVariables [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		sharedVariables: { #A . #B };
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def sharedSlots first name equals: #A. 
	self assert: def sharedSlots second name equals: #B.
]

{ #category : #'tests - (r) slots' }
CDFluidClassParserTest >> testComplexSlots [

	| parser defString def slot |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		slots: { #inst => (InstanceVariableSlot default: 5) };
		package: #MyPackage'.
	def := parser parse: defString.
	slot := def slots first.
	self assert: slot name equals: #inst. 
	self assert: slot initializationMessage selectorParts equals: #(#default:).
	self assert: (slot initializationMessage argumentParts collect: [:each | each value]) equals: #(5) asOrderedCollection
]

{ #category : #'tests - (r) slots' }
CDFluidClassParserTest >> testEmptySlots [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		slots: {};
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def slots isEmpty
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testEphemeronSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: EphemeronLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: EphemeronLayout
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testInstanceDefinitionIsInstanceSide [

	| def |
	def := self classDefinitionParserClass parse: 'Object << #Point
			package: ''Kernel-BasicObjects'''.

	self assert: def isInstanceSide
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testNormalSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: FixedLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: FixedLayout
]

{ #category : #'tests - (r) sharedPools' }
CDFluidClassParserTest >> testSharedPools [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
	   sharedPools: {TextConstants};
		package: #MyPackage'.
	
	def := parser parse: defString.
	self assert: def sharedPools first name equals: 'TextConstants'
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testSimpleDefinition [

	| def |
	def := self classDefinitionParserClass parse: 'Object << #Point
			package: ''Kernel-BasicObjects'''.
			
	self assert: def className equals: #Point.
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testSimpleDefinitionClassNode [

	| def |
	def := self classDefinitionParserClass parse: 'Object << #Point
			package: ''Kernel-BasicObjects'''.

	self assert: def classNameNode className equals: #Point.
	
	"The following cannot work 
	
		self assert: def classNameNode binding value equals: Point. 
	
	because binding is defined as 
	
		existingBindingIfAbsent: aBlock

			| binding |
			binding := originalNode methodNode compilationContext environment bindingOf: className.
			^ binding ifNil: aBlock
	
	"
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testSimpleDefinitionPackageIsCorrect [
	
	| def |
	def := self classDefinitionParserClass parse: 'Object << #Point
			package: ''Kernel-BasicObjects'''.
	self assert: def packageName equals: 'Kernel-BasicObjects'
]

{ #category : #'tests - (r) simple class definition' }
CDFluidClassParserTest >> testSimpleDefinitionSuperclassName [

	| def |
	def := self classDefinitionParserClass parse: 'Object << #Point
			package: ''Kernel-BasicObjects'''.
			
	self assert: def superclassName equals: 'Object'
]

{ #category : #'tests - (r) slots' }
CDFluidClassParserTest >> testSimpleSlots [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		slots: { #a. #b };
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def slots size equals: 2.
	self assert: def slots first name equals: #a. 
	self assert: def slots second name equals: #b.
]

{ #category : #'tests - (r) tags' }
CDFluidClassParserTest >> testTag [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	defString := 'Object << #MyObject
		tag: ''tag1'';
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def tag name equals: 'tag1'
]

{ #category : #'tests - (r) traits' }
CDFluidClassParserTest >> testTraitAlias [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		traits: MyTrait @ {#foo -> #bar};
		package: #MyPackage'.
	
	def := parser parse: defString.
	self assert: def traitDefinition class equals: CDTraitAliasNode. 
	self assert: (def traitDefinition aliases values) equals: #(bar).
	self assert: (def traitDefinition aliases keys) equals: #(foo).
	self assert: def traitDefinition subject name equals: #MyTrait.
]

{ #category : #'tests - (r) traits' }
CDFluidClassParserTest >> testTraitEmpty [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		uses: {};
		package: #MyPackage'.
		
	def := parser parse: defString.
	self assert: def traitDefinition equals: nil
]

{ #category : #'tests - (r) traits' }
CDFluidClassParserTest >> testTraitPlainSimple [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		traits: MyTrait;
		package: #MyPackage'.
		
	def := parser parse: defString.
	self assert: def traitDefinition name equals: #MyTrait.
]

{ #category : #'tests - (r) traits' }
CDFluidClassParserTest >> testTraitSequence [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	defString := 'Object << #MyObject
		traits: MyTrait + (AnotherTrait - {#selector} @ {#selector1 -> #selector});
		package: #MyPackage'.

	def := parser parse: defString.
	self assert: def traitDefinition class equals: CDTraitCompositionSequenceNode. 
	self assert: def traitDefinition sequence size equals: 2.
	self assert: (def traitDefinition sequence second aliases values) equals: #(selector).
	self assert: (def traitDefinition sequence second aliases keys) equals: #(selector1).
	self assert: def traitDefinition sequence first name equals: #MyTrait.
]

{ #category : #'tests - (r) slots' }
CDFluidClassParserTest >> testTypedSlots [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		slots: { #inst => InstanceVariableSlot };
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def slots size equals: 1.
	self assert: def slots first name equals: #inst.
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testVariableByteSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: ByteLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: ByteLayout
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testVariableSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: VariableLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: VariableLayout
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testVariableWordSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: WordLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: WordLayout
]

{ #category : #'tests - (r) kinds' }
CDFluidClassParserTest >> testWeakSubclass [

	| parser defString def |
	parser := self classDefinitionParserClass new.
	
	defString := 'Object << #MyObject
		layout: WeakLayout;
		package: #MyPackage'.
	def := parser parse: defString.
	self assert: def layoutClass equals: WeakLayout
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB [

	| dict searcher |
	searcher := RBParseTreeSearcher new.
	searcher 
		matches: '`superklass << `#ClassName
		slots: {};
		sharedVariables: {};
		package: ''''' 
	 	do: [ :aNode :answer |  dict:= searcher context ].
	dict := searcher executeTree: (RBParser parseExpression: 'Object << #MyClass
		slots: {};
		sharedVariables: {};
		package: ''''').
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB10 [

	| searcher kind |
	searcher := RBParseTreeSearcher new.
	searcher
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | kind := #traitInstance ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | kind := #traitClass ];
		matches: '`@tm << `#symb' do: [:aNode :answer | kind := #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | kind := #class ].
	searcher executeTree: (RBParser parseExpression: '
		Trait << TViewModelMock3 classTrait
	') .
	self assert: kind equals: #traitClass.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB10WithError [

	| searcher kind |
	searcher := RBParseTreeSearcher new.
	searcher
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | kind := #traitInstance ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | kind := #traitClass ];
		matches: '`@tm << `#symb' do: [:aNode :answer | kind := #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | kind := #class ].
	searcher executeTree: (RBParser parseExpression: '
		Trait << TViewModelMock3 class
	') .
	self assert: kind isNil.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB3 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: '^self' do: [:aNode :answer | coll add: aNode ];
		matches: '^`@anything' do: [:aNode :answer |  coll add: aNode].
	searcher executeTree: (RBParser parseMethod: 'foo 
	|tmp| 
	tmp := 22.
	^ 42').
	self assert: coll size equals: 1
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB4 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: '`@tm := `@val' do: [:aNode :answer | coll add: aNode ];
		matches: '^`@anything' do: [:aNode :answer | coll add: aNode].
	searcher executeTree: (RBParser parseMethod: 'foo 
	| tmp | 
	tmp := 22.
	tmp := 55.
	^ 42').
	self assert: coll size equals: 3
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB5 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: '`@tm << `#symb' do: [:aNode :answer | coll add: #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | coll add: #class ];
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | coll add: #traitInstance ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | coll add: #traitClass ].
	searcher executeTree: (RBParser parseExpression: '
		Object << #Point
		  slots: { #x . #y };
			package: ''Foo''
	') .
	self assert: coll first equals: #instance.
	self assert: coll size equals: 1.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB6 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: '`@tm << `#symb' do: [:aNode :answer | coll add: #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | coll add: #class ];
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | coll add: #traitInstance ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | coll add: #traitClass ].
	searcher executeTree: (RBParser parseExpression: '
		Object class << #Point class
		  slots: { #x . #y };
			package: ''Foo''
	') .
	self assert: coll first equals: #class.
	self assert: coll size equals: 1.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB7 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: '`@tm << `#symb' do: [:aNode :answer | coll add: #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | coll add: #class ];
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | coll add: #traitInstance ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | coll add: #traitClass ].
	searcher executeTree: (RBParser parseExpression: '
		Trait << #TPoint classTrait
		  slots: { #x . #y };
			package: ''Foo''
	') .
	self assert: coll first equals: #traitClass.
	self assert: coll size equals: 1.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB8 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | coll add: #traitInstance ];
		matches: '`@tm << `#symb' do: [:aNode :answer | coll add: #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | coll add: #class ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | coll add: #traitClass ].
	searcher executeTree: (RBParser parseExpression: '
		Trait << #Point
		  slots: { #x . #y };
			package: ''Foo''
	') .
	self assert: coll size equals: 1.
	self assert: coll first equals: #traitInstance.
]

{ #category : #'tests - rb xp' }
CDFluidClassParserTest >> testWithRB9 [

	| searcher coll|
	searcher := RBParseTreeSearcher new.
	coll := OrderedCollection new. 
	searcher
		matches: 'Trait << `#traitSymbol' do: [:aNode :answer | coll add: #traitInstance ];
		matches: '`@tm << `#symb' do: [:aNode :answer | coll add: #instance ];
		matches: '`@tm class << `@symb class' do: [:aNode :answer | coll add: #class ];
		matches: 'Trait << `@symb classTrait' do: [:aNode :answer | coll add: #traitClass ].
	searcher executeTree: (RBParser parseExpression: '
		Object << #MyObject
		sharedVariables: { #A . #B };
		package: ''MyPackage''
	') .
	self assert: coll size equals: 1.
	self assert: coll first equals: #instance.
]
