Class {
	#name : 'SLBasicTestDeclarationClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'translation' }
SLBasicTestDeclarationClass class >> typeForSelf [

	^#implicit
]

{ #category : 'tests' }
SLBasicTestDeclarationClass >> methodAccessingStructCopyType: aStruct [

	<var: #aStruct type: #'MockSlangStructTypeWithFields'>
	
	aStruct bitField: 0.
	^ aStruct bitField
]

{ #category : 'tests' }
SLBasicTestDeclarationClass >> methodAccessingStructPointerType: aStruct [

	<var: #aStruct type: #'MockSlangStructTypeWithFields *'>
	
	aStruct bitField: 0.
	^ aStruct bitField
]

{ #category : 'tests' }
SLBasicTestDeclarationClass >> methodAccessingStructPointerTypeWithFakeAccessor: aStruct [

	<var: #aStruct type: #'MockSlangStructTypeWithFakeAccessors *'>
	
	aStruct field: 0.
	^ aStruct field
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithBlockLocalDeclaration [

	"var does not exist"
	<var: 'var' type: 'toto'>
	[ | var | 1+2 ] value
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithLocal [

	| var |
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithLocalWithDeclaration [

	<var: 'var' type: 'toto'>
	| var |
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithNonExistingLocalDeclaration [

	"var does not exist"
	<var: 'var' type: 'toto'>
]
