"
This baseline is used to generate Pharo images from the local clone of pharo-project/pharo repository. 

Depends on:
- ConfigurationOfMorphic

Load type: 
- atomic

Installs:
- Spec
- Keymappings
- Rubric
- basic tools (old debugger, workspace)
- some other packages
"
Class {
	#name : #BaselineOfUI,
	#superclass : #BaselineOf,
	#classVars : [
		'Initialized'
	],
	#category : #BaselineOfUI
}

{ #category : #baseline }
BaselineOfUI >> baseline: spec [ 
    
	<baseline>

	| repository |
	 
	repository := self packageRepositoryURL.
       
	spec for: #common do: [
		spec postLoadDoIt: #'postload:package:'.
		
		"Loading the debugger model and infrastructure before the UI"		
		spec package: 'Debugger-Model'.
		spec package: 'Debugger-Oups'.

		"Load morphic before Spec"
		spec baseline: 'Morphic' with: [ spec repository: repository ].
		spec baseline: 'Commander2' with: [ spec repository: repository ].
		"Spec 2 (base), using external configuration"
		self specBase: spec.		
		
		spec baseline: 'DrTests' with: [ spec repository: repository ].

		spec package: 'StartupPreferences'.		
		
		spec package: 'Debugger-Actions'.

		spec package: 'Transcript-Tool'.
		spec package: 'Tool-Workspace'.

		spec package: 'Morphic-Widgets-Tree'.

		spec baseline: 'Keymapping' with: [ 
			spec 
				repository: repository;
				loads: 'ui' ].

		spec package: 'WebBrowser-Core'.

		spec package: 'HelpSystem-Core'.
	].
]

{ #category : #actions }
BaselineOfUI >> postload: loader package: packageSpec [

	"Ignore pre and post loads if already executed"
	Initialized = true ifTrue: [ ^ self ].

	Smalltalk tools register: Workspace as: #browser.
	Smalltalk tools register: Workspace as: #monticelloBrowser.
	Smalltalk tools register: Workspace as: #fileList.
	Smalltalk tools register: Workspace as: #changeList.	
	
	Smalltalk ui theme settings preferGradientFill: true.
	PharoCommonTools initialize.

	Initialized := true
]

{ #category : #baseline }
BaselineOfUI >> specBase: spec [
	
	spec baseline: 'SpecBase' with: [
		spec 
			repository: (self class environment at: #BaselineOfPharo) specRepository;
			className: 'BaselineOfSpec2';
			loads: #('Base' 'Tests') ]
]
