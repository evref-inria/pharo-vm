Class {
	#name : 'MockSlangStructTypeWithFakeAccessors',
	#superclass : 'SlangStructType',
	#instVars : [
		'fake'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'accessing - instances and variables' }
MockSlangStructTypeWithFakeAccessors class >> allInstVarNames [

	^ #( field )
]

{ #category : 'translation' }
MockSlangStructTypeWithFakeAccessors class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :ivn | aBinaryBlock value: ivn value: #sqInt ]
]

{ #category : 'translation' }
MockSlangStructTypeWithFakeAccessors class >> isAccessor: aSelector [

	^ self allInstVarNames includes: (aSelector copyWithout: $:)
]

{ #category : 'accessing' }
MockSlangStructTypeWithFakeAccessors >> field [

	^ fake at: 1
]

{ #category : 'accessing' }
MockSlangStructTypeWithFakeAccessors >> field: anObject [

	fake at: 1 put: anObject
]
