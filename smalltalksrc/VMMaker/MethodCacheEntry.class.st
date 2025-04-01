Class {
	#name : 'MethodCacheEntry',
	#superclass : 'VMStructType',
	#instVars : [
		'methodCache',
		'offset'
	],
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}

{ #category : 'translation' }
MethodCacheEntry class >> allInstVarNames [

	^ #( selector classTag entryMethod primitiveFunction )
]

{ #category : 'translation' }
MethodCacheEntry class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn
				 caseOf: { ([ 'primitiveFunction' ] -> [ #sqIntptr_t ]) }
				 otherwise: [ #sqInt ]) ]
]

{ #category : 'translation' }
MethodCacheEntry class >> isAccessor: aSelector [

	^ self allInstVarNames includes: aSelector
]

{ #category : 'asd' }
MethodCacheEntry >> classTag: aClassTag [

	<doNotGenerate>
	methodCache at: offset + 2 put: aClassTag
]

{ #category : 'accessing' }
MethodCacheEntry >> method: aMethod [

	<doNotGenerate>
	methodCache at: offset + 3 put: aMethod
]

{ #category : 'accesing' }
MethodCacheEntry >> methodCache: aMethodCache [

	methodCache := aMethodCache
]

{ #category : 'accessing' }
MethodCacheEntry >> offset: anOffset [

	offset := anOffset
]

{ #category : 'asd' }
MethodCacheEntry >> primitiveFunction: aPrimitiveFunction [

	<doNotGenerate>
	methodCache
		at: offset + 4
		put: (self cCoerce: aPrimitiveFunction to: #sqIntptr_t)
]

{ #category : 'accessing' }
MethodCacheEntry >> selector: aSelector [

	<doNotGenerate>
	methodCache at: offset + 1 put: aSelector
]
