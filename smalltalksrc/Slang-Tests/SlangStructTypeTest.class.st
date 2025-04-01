Class {
	#name : 'SlangStructTypeTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'tests' }
SlangStructTypeTest >> testGenerateStructTypeDef [

	self assert: MethodCacheEntry typedef equals: 'typedef struct {
	sqInt	selector;
	sqInt	classTag;
	sqInt	entryMethod;
	sqIntptr_t	primitiveFunction;
 } MethodCacheEntry;
'
]

{ #category : 'tests' }
SlangStructTypeTest >> testGenerateStructTypeDefWithFields [

	self
		assert: MockSlangStructTypeWithFields typedef
		equals: 'typedef struct {
	usqInt		array [8];
	unsigned		bitField : 2;
	char *explicitType;
	sqInt	defaultType;
 } MockSlangStructTypeWithFields;
'
]

{ #category : 'tests' }
SlangStructTypeTest >> testGenerateStructTypeDefWithRedefinedName [

	self
		assert: MockEmptyVMStructWithRedefinedStructName typedef
		equals: 'typedef struct {
 } RedefinedStruct;

#define MockEmptyVMStructWithRedefinedStructName RedefinedStruct
'
]

{ #category : 'tests' }
SlangStructTypeTest >> testGenerateStructTypeDefWithWrongField [

	[
	MockSlangStructTypeWithWrongField typedef.
	self fail ]
		on: Error
		do: [ :e |
			self
				assert: e messageText
				equals: 'Type declaration of field ''field'' is wrong' ]
]

{ #category : 'tests' }
SlangStructTypeTest >> testStructByCopyTypeAccessors [

	| tMethod code |
	ccg addClass: MockSlangStructTypeWithFields.
	ccg addClass: SLBasicTestDeclarationClass.

	tMethod := ccg methodNamed: #methodAccessingStructCopyType:.
	tMethod prepareMethodIn: ccg.
	tMethod recordDeclarationsIn: ccg.

	code := self translate: tMethod.
	self
		assert: code
		equals:
			'/* SLBasicTestDeclarationClass>>#methodAccessingStructCopyType: */
static sqInt
methodAccessingStructCopyType(MockSlangStructTypeWithFields aStruct)
{
	(aStruct.bitField = 0);
	return (aStruct.bitField);
}
'
]

{ #category : 'tests' }
SlangStructTypeTest >> testStructPointerTypeAccessors [

	| tMethod code |
	ccg addClass: MockSlangStructTypeWithFields.
	ccg addClass: SLBasicTestDeclarationClass.

	tMethod := ccg methodNamed: #methodAccessingStructPointerType:.
	tMethod prepareMethodIn: ccg.
	tMethod recordDeclarationsIn: ccg.

	code := self translate: tMethod.
	self
		assert: code
		equals:
			'/* SLBasicTestDeclarationClass>>#methodAccessingStructPointerType: */
static sqInt
methodAccessingStructPointerType(MockSlangStructTypeWithFields *aStruct)
{
	(aStruct->bitField = 0);
	return (aStruct->bitField);
}
'
]

{ #category : 'tests' }
SlangStructTypeTest >> testStructPointerTypeWithFakeAccessor [

	| tMethod code |
	ccg addClass: MockSlangStructTypeWithFakeAccessors.
	ccg addClass: SLBasicTestDeclarationClass.

	self assert: MockSlangStructTypeWithFakeAccessors typedef equals: 'typedef struct {
	sqInt	field;
 } MockSlangStructTypeWithFakeAccessors;
'.

	tMethod := ccg methodNamed: #methodAccessingStructPointerTypeWithFakeAccessor:.
	tMethod prepareMethodIn: ccg.
	tMethod recordDeclarationsIn: ccg.

	code := self translate: tMethod.
	self
		assert: code
		equals:
			'/* SLBasicTestDeclarationClass>>#methodAccessingStructPointerTypeWithFakeAccessor: */
static sqInt
methodAccessingStructPointerTypeWithFakeAccessor(MockSlangStructTypeWithFakeAccessors *aStruct)
{
	(aStruct->field = 0);
	return (aStruct->field);
}
'
]
