Class {
	#name : 'MockSlangStructTypeWithWrongField',
	#superclass : 'SlangStructType',
	#instVars : [
		'field'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'translation' }
MockSlangStructTypeWithWrongField class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self instVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: #( #sqInt ) ]
]

{ #category : 'accessing' }
MockSlangStructTypeWithWrongField >> field [

	^ field
]

{ #category : 'accessing' }
MockSlangStructTypeWithWrongField >> field: anObject [

	field := anObject
]
