Class {
	#name : #OCTargetCompilerSample,
	#superclass : #Object,
	#category : #'OpalCompiler-Tests-Semantic'
}

{ #category : #accessing }
OCTargetCompilerSample class >> compilerClass [
	^ OCTargetCompiler
]

{ #category : #examples }
OCTargetCompilerSample class >> returnExpected [
	" the target compiler will ignore the code and force this to return #expectedReturn
		self returnExpected
		self new returnExpected
	"
	^ #dontReturnThis
]

{ #category : #examples }
OCTargetCompilerSample >> returnExpected [
	" the target compiler will ignore the code and force this to return #expectedReturn "
	^ #dontReturnThis
]
