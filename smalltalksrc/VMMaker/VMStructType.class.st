"
I am an absract superclass for classes which map to simple structs in C,  Right now I merely serve to organize all the struct types.  I would like to arrange that generated assignment accessors answer their argument to correspond with field assignment in C, but createInstVarAccessors is implemented by the browser not by ClassDescription.
"
Class {
	#name : 'VMStructType',
	#superclass : 'SlangStructType',
	#category : 'VMMaker-Support',
	#package : 'VMMaker',
	#tag : 'Support'
}

{ #category : 'accessing class hierarchy' }
VMStructType class >> addSubclass: aSubclass [
	self voidStructTypeCache.
	^super addSubclass: aSubclass
]

{ #category : 'simulation only' }
VMStructType class >> alignedByteSizeOf: objectSymbolOrClass forClient: aVMClass [
	^objectSymbolOrClass byteSizeForSimulator: aVMClass
]

{ #category : 'code generation' }
VMStructType class >> changedAccesorsForSurrogate: surrogateClass bytesPerWord: bytesPerWord [
	"Answer the changed accessor methods for the fields of the receiver and the alignedByteSize class method."

	"{CogBlockMethod changedAccesorsForSurrogate: CogBlockMethodSurrogate32 bytesPerWord: 4.
	 CogMethod changedAccesorsForSurrogate: CogMethodSurrogate32 bytesPerWord: 4.
	 CogBlockMethod changedAccesorsForSurrogate: CogBlockMethodSurrogate64 bytesPerWord: 8.
	 CogMethod changedAccesorsForSurrogate: CogMethodSurrogate64 bytesPerWord: 8}"

	^Dictionary withAll: ((self fieldAccessorSourceFor: surrogateClass bytesPerWord: bytesPerWord) associationsSelect:
		[:a| a value ~= a key sourceString])
]

{ #category : 'code generation' }
VMStructType class >> checkGenerateSurrogate: surrogateClass bytesPerWord: bytesPerWord [
	"Check the accessor methods for the fields of the receiver and if necessary install new
	 or updated versions in the surrogate class alpng with the alignedByteSize class method."

	"CogBlockMethod checkGenerateSurrogate: CogBlockMethodSurrogate32 bytesPerWord: 4.
	 CogMethod checkGenerateSurrogate: CogMethodSurrogate32 bytesPerWord: 4.
	 CogBlockMethod checkGenerateSurrogate: CogBlockMethodSurrogate64 bytesPerWord: 8.
	 CogMethod checkGenerateSurrogate: CogMethodSurrogate64 bytesPerWord: 8"
	| accessors oldBytesPerWord |
	oldBytesPerWord := VMMakerConfiguration bytesPerWord.
	accessors := [self fieldAccessorSourceFor: surrogateClass bytesPerWord: (VMMakerConfiguration bytesPerWord:  bytesPerWord)]
					ensure: [VMMakerConfiguration bytesPerWord: oldBytesPerWord].
	accessors keysAndValuesDo:
		[:mr :source|
		source ~= mr sourceString ifTrue:
			[mr actualClass compile: source classified: #accessing]]

	"Dictionary withAll: ((self fieldAccessorSourceFor: surrogateClass bytesPerWord: bytesPerWord) associationsSelect:
		[:a| a value ~= a key sourceString])"
]

{ #category : 'accessing' }
VMStructType class >> constantClass [
	
	^ VMClass constantClass
]

{ #category : 'code generation' }
VMStructType class >> fieldAccessorSourceFor: surrogateClass bytesPerWord: bytesPerWord [
	"Answer a Dictionary of MethodReference to source for the accessors of the inst vars of the
	 receiver and the alignedByteSize class method in surrogateClass with the given word size."

	"{CogBlockMethod fieldAccessorSourceFor: CogBlockMethodSurrogate32 bytesPerWord: 4.
	 CogMethod fieldAccessorSourceFor: CogMethodSurrogate32 bytesPerWord: 4.
	 CogBlockMethod fieldAccessorSourceFor: CogBlockMethodSurrogate64 bytesPerWord: 8.
	 CogMethod fieldAccessorSourceFor: CogMethodSurrogate64 bytesPerWord: 8}"
	| methods bitPosition alignedByteSize currentOffset |
	methods := Dictionary new.
	bitPosition := 0.
	(self fieldAccessorsForBytesPerWord: bytesPerWord) do:
		[:spec|
		"reset the bitPosition if the offset expression changes."
		currentOffset ~= (self offsetForInstVar: spec first) ifTrue:
			[bitPosition := 0.
			 currentOffset := self offsetForInstVar: spec first].
		"If the accessor is already defined in a superclass don't redefine it in the subclass.
		 We assume it is correctly defined in the superclass."
		(spec first ~= #unused
		 and: [(surrogateClass whichClassIncludesSelector: spec first asSymbol)
				ifNil: [true]
				ifNotNil: [:implementingClass|
						self assert: (implementingClass inheritsFrom: Object).
						implementingClass == surrogateClass]]) ifTrue:
			[methods
				at: (MethodReference class: surrogateClass selector: spec first asSymbol)
					put: (self getter: spec first
							 bitPosition: bitPosition
							 bitWidth: spec second
							 type: (spec at: 3 ifAbsent: []));
				at: (MethodReference class: surrogateClass selector: (spec first, ':') asSymbol)
					put: (self setter: spec first
							 bitPosition: bitPosition
							 bitWidth: spec second
							 type: (spec at: 3 ifAbsent: []))].
		bitPosition := bitPosition + spec second].
	alignedByteSize := (self roundUpBitPosition: bitPosition toWordBoundary: bytesPerWord) / 8.
	self assert: alignedByteSize isInteger.
	methods
		at: (MethodReference class: surrogateClass class selector: #alignedByteSize)
			put: #alignedByteSize
				, (String with: Character cr with: Character tab with: $^)
				, alignedByteSize printString,
				(currentOffset ifNil: [''] ifNotNil: [' + self ', currentOffset]).
	^methods
]

{ #category : 'code generation' }
VMStructType class >> fieldAccessorsForBytesPerWord: bytesPerWord [
	| fieldSpecs |
	fieldSpecs := OrderedCollection new.
	self instVarNamesAndTypesForTranslationDo:
		[:ivn :typeTuple| | index replacement |
		(index := typeTuple indexOf: #BytesPerWord ifAbsent: 0) > 0
			ifTrue:
				[(typeTuple at: index + 1) = bytesPerWord ifTrue:
					[replacement := typeTuple copyReplaceFrom: index to: index + 1 with: #().
					 replacement size = 1 ifTrue:
						[replacement := replacement first].
					fieldSpecs add: { ivn. replacement }]]
			ifFalse:
				[fieldSpecs add: { ivn. typeTuple }]].
	^fieldSpecs collect:
		[:tuple|
			[:ivn :typeTuple|
			{ ('*unused*' match: ivn) ifTrue: [#unused] ifFalse: [ivn].
			  (typeTuple isArray and: ['unsigned' = typeTuple first])
				ifTrue:
					[Integer readFrom: (typeTuple last readStream skipTo: $:; skipSeparators)]
				ifFalse:
					[typeTuple
						caseOf: {
								[#char]				->	[8].
								[#'unsigned char']	->	[8].
								[#short]			->	[16].
								[#'unsigned short']	->	[16].
								[#int]				->	[32].
								[#'unsigned int']	->	[32] }
						otherwise: [bytesPerWord * 8]].
			typeTuple isArray
				ifTrue:
					[(typeTuple size >= 3 and: [typeTuple second = #Boolean]) ifTrue:
						[#Boolean]]
				ifFalse:
					[typeTuple last = $* ifTrue:
						[(typeTuple beginsWith: 'struct _') "remove struct tag if any"
							ifTrue: [(typeTuple allButFirst: 8) asSymbol]
							ifFalse: [typeTuple]]] }] valueWithArguments: tuple]

	"#(4 8) collect: [:bpw| (CogBlockMethod fieldAccessorsForBytesPerWord: bpw) asArray]"
	"#(4 8) collect: [:bpw| (CogMethod fieldAccessorsForBytesPerWord: bpw) asArray]"
]

{ #category : 'translation' }
VMStructType class >> filteredInstVarNames [
	"Eliminate the obvious simulation-only inst vars"
	^super filteredInstVarNames reject:
		[:n|
		Cogit isNonArgumentImplicitReceiverVariableName: n]
]

{ #category : 'code generation' }
VMStructType class >> getter: getter bitPosition: bitPosition bitWidth: bitWidth type: typeOrNil [
	^String streamContents:
		[:s| | startByte endByte alignedPowerOf2 shift |
		startByte := bitPosition // 8.
		endByte := bitPosition + bitWidth - 1 // 8.
		shift := bitPosition \\ 8.
		alignedPowerOf2 := (#(8 16 32 64) includes: bitWidth) and: [shift = 0].
		s nextPutAll: getter; crtab: 1.
		(typeOrNil notNil and: [typeOrNil last = $*]) ifTrue:
			[s nextPutAll: '| v |'; crtab: 1].
		s nextPut: $^.
		typeOrNil ifNotNil:
			[s nextPut: $(.
			 typeOrNil last = $* ifTrue:
				[s nextPutAll: 'v := ']].
		alignedPowerOf2 ifFalse:
			[s nextPut: $(].
		shift ~= 0 ifTrue:
			[s nextPut: $(].
		s nextPutAll: 'memory unsigned';
		   nextPutAll: (#('Byte' 'Short' 'Long32' 'Long32')
							at: endByte - startByte + 1
							ifAbsent: ['Long64']);
		  nextPutAll: 'At: address + '; print: startByte.
		(self offsetForInstVar: getter) ifNotNil:
			[:offsetExpr| s nextPutAll: ' + '; nextPutAll: offsetExpr].
		shift ~= 0 ifTrue:
			[s nextPutAll: ') bitShift: -'; print: shift].
		alignedPowerOf2 ifFalse:
			[s nextPutAll: ') bitAnd: '; nextPutAll: ((1 << bitWidth) - 1) hex].
		typeOrNil ifNotNil:
			[s nextPutAll: ') ~= 0'.
			typeOrNil last = $* ifTrue:
				[s nextPutAll: ' ifTrue:';
					crtab: 2;
					nextPutAll: '[cogit cCoerceSimple: v to: ';
					store: typeOrNil;
					nextPut: $]]]]
]

{ #category : 'translation' }
VMStructType class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."
	^#void
]

{ #category : 'accessing' }
VMStructType class >> initializationOptions [
	
	^ VMClass initializationOptions 
]

{ #category : 'translation' }
VMStructType class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a struct of this type."

	self subclassResponsibility
]

{ #category : 'accessing' }
VMStructType class >> interpreterClass [
	
	^ VMClass interpreterClass 
]

{ #category : 'accessing class hierarchy' }
VMStructType class >> isAbstract [
	^self == VMStructType
]

{ #category : 'translation' }
VMStructType class >> isNonArgumentImplicitReceiverVariableName: aString [
	^Cogit isNonArgumentImplicitReceiverVariableName: aString
]

{ #category : 'accessing' }
VMStructType class >> objectMemoryClass [
	
	^ VMClass objectMemoryClass
]

{ #category : 'code generation' }
VMStructType class >> offsetForInstVar: instVarName [
	"Hack to offset accesses to variables by certain values."
	^nil
]

{ #category : 'accessing class hierarchy' }
VMStructType class >> removeSubclass: aSubclass [
	self voidStructTypeCache.
	^super removeSubclass: aSubclass
]

{ #category : 'class name' }
VMStructType class >> rename: aString [
	self voidStructTypeCache.
	^super rename: aString
]

{ #category : 'code generation' }
VMStructType class >> roundUpBitPosition: bitPosition toWordBoundary: bytesPerWord [
	^bitPosition + 7 // 8 + bytesPerWord - 1 // bytesPerWord * bytesPerWord * 8
]

{ #category : 'code generation' }
VMStructType class >> setter: getter bitPosition: bitPosition bitWidth: bitWidth type: typeOrNil [
	^String streamContents:
		[:s| | startByte endByte shift alignedPowerOf2 accessor mask expr |
		startByte := bitPosition // 8.
		endByte := bitPosition + bitWidth - 1 // 8.
		shift := bitPosition \\ 8.
		alignedPowerOf2 := (#(8 16 32 64) includes: bitWidth) and: [shift = 0].
		accessor := 'unsigned'
					, (#('Byte' 'Short' 'Long32' 'Long32')
							at: endByte - startByte + 1
							ifAbsent: ['Long64'])
					, 'At: address + '.
		(self offsetForInstVar: getter) ifNotNil:
			[:offsetExpr| accessor := accessor, offsetExpr, ' + '].
		mask := #(16rFF 16rFFFF 16rFFFFFFFF 16rFFFFFFFF)
						at: endByte - startByte + 1
						ifAbsent: [(2 ** 64) - 1].
		s nextPutAll: getter; nextPutAll: ': aValue'.
		(typeOrNil notNil or: [alignedPowerOf2]) ifFalse:
			[s crtab: 1; nextPutAll: 'self assert: (aValue between: 0 and: '; nextPutAll:  ((1 << bitWidth) - 1) hex; nextPutAll: ').'].
		s crtab: 1.
		alignedPowerOf2 ifTrue:
			[s nextPut: $^].
		s nextPutAll: 'memory';
		  crtab: 2; nextPutAll: accessor; print: startByte.
		s crtab: 2; nextPutAll: 'put: '.
		typeOrNil ifNotNil:
			[s nextPut: $(].
		alignedPowerOf2 ifFalse:
			[s nextPutAll: '((memory '; nextPutAll: accessor; print: startByte;
			    nextPutAll: ') bitAnd: '; nextPutAll: (mask - ((1 << bitWidth - 1) << shift)) hex;
			    nextPutAll: ') + '].
		expr := typeOrNil caseOf: {
						[nil] -> ['aValue'].
						[#Boolean] -> ['(aValue ifTrue: [1] ifFalse: [0])'] }
					otherwise: ['(aValue ifNotNil: [aValue asUnsignedInteger] ifNil: [0])'].
		shift = 0
			ifTrue:
				[s nextPutAll: expr]
			ifFalse:
				[s nextPut: $(; nextPutAll: expr; nextPutAll: ' bitShift: '; print: shift; nextPut: $)].
		typeOrNil notNil ifTrue:
			[s nextPut: $)].
		alignedPowerOf2 ifFalse:
			[s nextPut: $.; crtab: 1; nextPutAll: '^aValue']]
]

{ #category : 'accessors' }
VMStructType class >> settersReturnValue [
	"Override to get the browser to generate setters that return the
	 value set, which matches C semantics for field assignments."
	^true
]

{ #category : 'translation' }
VMStructType class >> shouldBeGenerated [

	^ true
]

{ #category : 'accessing' }
VMStructType class >> timeStamp [
	
	^ VMClass timeStamp
]

{ #category : 'translation' }
VMStructType class >> typedef [
	^String streamContents: [:s| self printTypedefOn: s]
]

{ #category : 'debug support' }
VMStructType >> logError: aMessage [
	
	<doNotGenerate>
	self logError: aMessage withArgs: #()
]

{ #category : 'printing' }
VMStructType >> printOn: aStream [
	"A hook to allow subclasses to print their state if useful."
	<doNotGenerate>
	super printOn: aStream.
	self printStateOn: aStream
]

{ #category : 'printing' }
VMStructType >> printStateOn: aStream [
	"A hook to allow subclasses to print their state if useful."
	<doNotGenerate>
	^self
]
