Class {
	#name : 'VMTestMockInterpreter',
	#superclass : 'StackInterpreterSimulatorLSB',
	#instVars : [
		'interpreteBlock',
		'allocatedElements'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'memory testing' }
VMTestMockInterpreter >> allocateParameters: anInteger using: allocationBlock [
	
	| allocated |
	allocated := super allocateParameters: anInteger using: allocationBlock.
	allocated ifNil: [ ^ nil ].
	
	allocatedElements add: allocated.
	^ allocated
]

{ #category : 'memory testing' }
VMTestMockInterpreter >> allocatedElements [
	
	^ allocatedElements 
]

{ #category : 'initialization' }
VMTestMockInterpreter >> basicInitialize [

	super basicInitialize.
	allocatedElements := Set new
]

{ #category : 'accessing' }
VMTestMockInterpreter >> enterSmalltalkExecutiveImplementation [ 

	interpreteBlock value
]

{ #category : 'initialization' }
VMTestMockInterpreter >> free: aPointer [

	allocatedElements remove: aPointer.
	^ super free: aPointer
]

{ #category : 'accessing' }
VMTestMockInterpreter >> interpreteBlock [
	^ interpreteBlock
]

{ #category : 'accessing' }
VMTestMockInterpreter >> interpreteBlock: anObject [
	interpreteBlock := anObject
]

{ #category : 'initialization' }
VMTestMockInterpreter >> malloc: aSize [

	^ allocatedElements add: (super malloc: aSize)
]
