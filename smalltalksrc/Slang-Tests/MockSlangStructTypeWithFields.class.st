Class {
	#name : 'MockSlangStructTypeWithFields',
	#superclass : 'SlangStructType',
	#instVars : [
		'array',
		'bitField',
		'explicitType',
		'defaultType'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'translation' }
MockSlangStructTypeWithFields class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self instVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn
				 caseOf: {
						 ([ 'array' ] -> [ { #usqInt. '[8]' } ]).
						 ([ 'bitField' ] -> [ #( unsigned ' : 2' ) ]).
						 ([ 'explicitType' ] -> [ 'char *' ]) }
				 otherwise: [ #sqInt ]) ]
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> array [

	^ array
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> array: anObject [

	array := anObject
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> bitField [

	^ bitField
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> bitField: anObject [

	bitField := anObject
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> defaultType [

	^ defaultType
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> defaultType: anObject [

	defaultType := anObject
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> explicitType [

	^ explicitType
]

{ #category : 'as yet unclassified' }
MockSlangStructTypeWithFields >> explicitType: anObject [

	explicitType := anObject
]
