"
I'm a container for slots.

"
Class {
	#name : #AbstractLayout,
	#superclass : #Object,
	#instVars : [
		'host'
	],
	#category : #'Kernel-Layout'
}

{ #category : #testing }
AbstractLayout class >> isAbstract [
	^self == AbstractLayout
]

{ #category : #comparing }
AbstractLayout >> = other [
	^ self class = other class
]

{ #category : #accessing }
AbstractLayout >> allSlots [
	^ {}
]

{ #category : #enumerating }
AbstractLayout >> allSlotsDo: aBlock [
	self slotScope allSlotsDo: aBlock
]

{ #category : #accessing }
AbstractLayout >> allVisibleSlots [
	^ {}
]

{ #category : #validation }
AbstractLayout >> checkIntegrity [
	self checkSanity
]

{ #category : #validation }
AbstractLayout >> checkSanity [
	host ifNil: [ self error: 'Host should not be nil' ].
]

{ #category : #api }
AbstractLayout >> definesSlot: aSlot [ 
	^self slots identityIncludes: aSlot
]

{ #category : #accessing }
AbstractLayout >> extend: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractLayout >> extendByte [
	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractLayout >> extendDoubleByte [
	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractLayout >> extendDoubleWord [
	^ self subclassResponsibility
]

{ #category : #extending }
AbstractLayout >> extendImmediate [
	^ ImmediateLayout new
]

{ #category : #accessing }
AbstractLayout >> extendVariable: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractLayout >> extendWord [
	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractLayout >> fieldSize [
	^ 0
]

{ #category : #testing }
AbstractLayout >> hasBindingThatBeginsWith: aString [
	"Answer true if there is a Slot that begins with aString, false otherwise"
	^false
]

{ #category : #testing }
AbstractLayout >> hasFields [
	^ false
]

{ #category : #api }
AbstractLayout >> hasSlot: aSlot [
	^ self allSlots identityIncludes: aSlot
]

{ #category : #api }
AbstractLayout >> hasSlotNamed: aString [
	"Return true whether the receiver defines an instance variable named aString.
	this includs non-visible slots"
	^self allSlots anySatisfy: [:slot | slot name = aString  ]
]

{ #category : #testing }
AbstractLayout >> hasSlots [
	^ false
]

{ #category : #comparing }
AbstractLayout >> hash [
	^ self class hash
]

{ #category : #accessing }
AbstractLayout >> host [
	^ host
]

{ #category : #accessing }
AbstractLayout >> host: aClass [
	host := aClass
]

{ #category : #accessing }
AbstractLayout >> instVarNames [
	^ {}
]

{ #category : #testing }
AbstractLayout >> isBits [
	^ false
]

{ #category : #testing }
AbstractLayout >> isFixedLayout [
	^false
]

{ #category : #testing }
AbstractLayout >> isVariable [
	^ false
]

{ #category : #testing }
AbstractLayout >> isWeak [
	^ false
]

{ #category : #accessing }
AbstractLayout >> resolveSlot: aName [
	^SlotNotFound signalForName: aName
]

{ #category : #api }
AbstractLayout >> resolveSlot: aName ifFound: foundBlock ifNone: exceptionBlock [
	^exceptionBlock value
]

{ #category : #accessing }
AbstractLayout >> slotScope [
	^ LayoutEmptyScope instance
]

{ #category : #accessing }
AbstractLayout >> slots [
	^ {}
]

{ #category : #accessing }
AbstractLayout >> visibleSlots [
	^self slots select: [:slot | slot isVisible]
]
