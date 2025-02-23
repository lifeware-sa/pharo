"
I am a specialized OSEnvironment for Windows.
See my superclass to understand my common usage.

# Encoding Management

Windows hides the environment variables encoding through its API, and it's not up to the user how to encode them.
Thus, I do not propose an API to specify encodings.

# Implementation Details 

I use FFI calls to manage encodings. Pharo strings are first encoded in utf8 and used to create Win32 WideStrings, whose are used in the windows function calls.
See Win32WideString
"
Class {
	#name : #Win32Environment,
	#superclass : #OSEnvironment,
	#category : #'System-OSEnvironments-Platforms'
}

{ #category : #testing }
Win32Environment class >> isDefaultFor: aPlatform [ 
	^ aPlatform isWindows
]

{ #category : #accessing }
Win32Environment >> at: aKey ifAbsent: aBlock [
	"The primitive on Windows currently uses the ascii version of the Windows API.
	In such chase try to get value of the environment variable using FFI."

	^ self getEnvVariable: aKey bufferSize: 500 ifAbsent: aBlock
]

{ #category : #accessing }
Win32Environment >> at: aKey put: aValue [
	"The primitive on Windows currently uses the ascii version of the Windows API.
	In such chase try to set the value of the environment variable using FFI."

	| w32Key w32Value return |
	w32Key := aKey asWin32WideString.
	w32Value := aValue asWin32WideString.
	return := self setEnvironmentVariable: w32Key value: w32Value.	

	"From MSDN: If the function fails, the return value is zero."
	return = 0 ifTrue: [ 
		self error: 'An error occurred while setting environment variable ', aKey asString, ' to ', aValue asString ].
]

{ #category : #private }
Win32Environment >> doGetEnvVariable: aVariableName bufferSize: aSize ifAbsent: aBlock isRetry: isRetry [
	| name buffer return lastErrCode |

	name := aVariableName asWin32WideString.
	buffer := Win32WideString new: aSize.

	"This Windows API to get the environment variable has ambiguous behavior when handling environment variables with empty values.
	In the case of a empty string, the API call to get the environment variable returns 0. 
	We need to differentiate the 0 in the case of an empty string and when there is an error.
	To do so, we are clearing the last error variable, and also we are retrying.
	The retrying is needed because we can have a race condition between different API calls."

	lastErrCode := OSPlatform current setLastError: 0.
	return := OSPlatform current getEnvironmentVariable: name into: buffer size: aSize + 1.
	lastErrCode := OSPlatform current lastError.
	
	"From MSDN: If the function fails, the return value is zero. If the specified environment variable was not found in the environment block, GetLastError returns ERROR_ENVVAR_NOT_FOUND."
	return = 0 ifTrue: [ 
		lastErrCode = 0 ifTrue: [ ^ String new ].
		lastErrCode = "ERROR_ENVVAR_NOT_FOUND" 16r000000CB ifTrue: [ ^ aBlock value ].
		
		isRetry
			ifTrue: [ 
				self error: 'Error ', lastErrCode printString, 
					' occurred while fetching environment variable ', aVariableName asString ]
			ifFalse: [ ^ self doGetEnvVariable: aVariableName bufferSize: aSize ifAbsent: aBlock isRetry: true ] ].
	
	"From MSDN: If lpBuffer is not large enough to hold the data, the return value is the buffer size, in characters,
	required to hold the string and its terminating null character and the contents of lpBuffer are undefined."
	return > aSize ifTrue: [ ^ self doGetEnvVariable: aVariableName bufferSize: return ifAbsent: aBlock isRetry: false ].
	
	^ buffer asString
]

{ #category : #private }
Win32Environment >> environmentStrings [
	 ^ self ffiCall: #( void * GetEnvironmentStrings () )
]

{ #category : #private }
Win32Environment >> ffiLibraryName [

	^ #Kernel32
]

{ #category : #private }
Win32Environment >> getEnvVariable: aVariableName bufferSize: aSize ifAbsent: aBlock [

	^ self doGetEnvVariable: aVariableName bufferSize: aSize ifAbsent: aBlock isRetry: false
]

{ #category : #enumeration }
Win32Environment >> keysAndValuesDo: aBlock [
	"Under windows the environemtn variables are a single big String."

	"Lines starting with an equal sign are invalid per    
	  http://stackoverflow.com/questions/10431689/what-are-these-strange-environment-variables"
	| environmentStrings nextString |

	environmentStrings := self environmentStrings.
	[ 
	nextString := environmentStrings fromCString.
	nextString ifEmpty: [ ^ self ].
	nextString first = $=
		ifFalse: [ self keysAndValuesDo: aBlock withAssociationString: nextString ].
	environmentStrings := environmentStrings + nextString size + 1 ] repeat
]

{ #category : #private }
Win32Environment >> removeEnvironmentVariable: nameString [

	 ^ self ffiCall: #( int SetEnvironmentVariableW ( Win32WideString nameString, 0 ) )
]

{ #category : #accessing }
Win32Environment >> removeKey: aKey [
	"The primitive on Windows currently uses the ascii version of the Windows API.
	In such chase try to get value of the environment variable using FFI."

	| return |
	return := self removeEnvironmentVariable: aKey asWin32WideString.

	"From MSDN: If the function fails, the return value is zero."
	return = 0 ifTrue: [ 
		self error: 'An error occurred while removing environment variable ', aKey asString ].
]

{ #category : #private }
Win32Environment >> setEnv: nameString value: valueString [
	"This method calls the the platform specific set environment routine"

	^ self
		ffiCall: #(int SetEnvironmentVariableA #(String nameString , String valueString))
		module: #Kernel32
]

{ #category : #private }
Win32Environment >> setEnvironmentVariable: nameString value: valueString [

	 ^ self ffiCall: #( int SetEnvironmentVariableW ( Win32WideString nameString, Win32WideString valueString ) )
]
