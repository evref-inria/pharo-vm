Class {
	#name : 'VMJitFFISameThreadCalloutTest',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#instVars : [
		'jitCompilerClass'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'helpers' }
VMJitFFISameThreadCalloutTest >> callCogMethod: callingMethod receiver: receiver arguments: args returnAddress: returnAddress [

	cogit processor setFramePointer: interpreter framePointer stackPointer: interpreter stackPointer.

	^ super callCogMethod: callingMethod receiver: receiver arguments: args returnAddress: returnAddress

]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> jitCompilerClass [

	^ jitCompilerClass ifNil: [ jitCompilerClass := super jitCompilerClass ]
]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> jitCompilerClass: aValue [

	jitCompilerClass := aValue
]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> setUp [

	super setUp.
	
	self setUpTrampolines.
	self setUpCogMethodEntry.
	self createBaseFrame.
	
	interpreter libFFI: LibFFI new.
	interpreter libFFI interpreter: interpreter.
	
	self createExternalAddressClass.


]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit methodAbortTrampolines at: 0 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 1 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 2 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 3 put: cogit ceMethodAbortTrampoline.
	
	cogit picMissTrampolines at: 0 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 1 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 2 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 3 put: cogit ceCPICMissTrampoline.

	cogit picAbortTrampolines at: 0 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 1 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 2 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 3 put: cogit cePICAbortTrampoline.
	
	cogit ceStoreCheckTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceStoreCheckTrampoline).
	cogit objectRepresentation setAllStoreTrampolinesWith: (self compileTrampoline: [ cogit RetN: 0 ] named: #ceStoreTrampoline).
	
	cogit generateSameThreadCalloutTrampolines
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionCallsExternalFunction [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ called := true ] 
		withArgumentTypes: {} 
		withReturnType: interpreter libFFI void.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionChangesStack [

	| compiledMethod cogMethod tfExternalFunction changedStack anExternalAddress |

	changedStack := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [ 
										changedStack := (machineSimulator stackPointerRegisterValue bitAnd: 16rFFFFFF00) = (cogit getCStackPointer bitAnd: 16rFFFFFF00).
										0 ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI void.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: changedStack.

]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionPopsCorrectlyAndReturnsTheResult [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ :a :b | a + b ] 
		withArgumentTypes: {interpreter libFFI sint64. interpreter libFFI sint64} 
		withReturnType: interpreter libFFI sint64.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory integerObjectOf: 13);
		                  literalAt: 2 put: (memory integerObjectOf: 4);
		                  literalAt: 3 put: memory nilObject; "Class binding"
		                  bytecodes: #[ 
											33		"Push literal 1"
											34		"Push literal 2"
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 17).

]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionReturnsCorrectValue [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ 17 ] 
		withArgumentTypes: {} 
		withReturnType: interpreter libFFI sint64.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 17).

]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testJITCompilesCallToTrampolineByDefault [

	| compiledMethod cogMethod tfExternalFunction |
	tfExternalFunction := self
		                      createExternalFunctionFor: [  ]
		                      withArgumentTypes: {  }
		                      withReturnType: interpreter libFFI void.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: memory nilObject
		arguments: {  }
		returnAddress: cogit ceSameThreadCalloutTrampoline.

	self
		assert: machineSimulator pc
		equals: cogit ceSameThreadCalloutTrampoline.
	self
		assert: machineSimulator sendNumberOfArgumentsRegisterValue
		equals: 0
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidChangesStack [

	| compiledMethod cogMethod tfExternalFunction changedStack anExternalAddress |

	changedStack := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										changedStack := (machineSimulator stackPointerRegisterValue bitAnd: 16rFFFFFF00) = (cogit getCStackPointer bitAnd: 16rFFFFFF00).
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: changedStack.

]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithExternalAddressAsParameter [

	| compiledMethod cogMethod tfExternalFunction called receivedArgument anExternalAddress |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: 17
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithNilAsParameter [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: 0
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithOopAsParameter [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: aByteArray;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: aByteArray + BaseHeaderSize 
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithSmallIntegerAsParameter [

	| compiledMethod cogMethod tfExternalFunction called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory integerObjectOf: 17);
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: 17
]

{ #category : 'tests' }
VMJitFFISameThreadCalloutTest >> testPopingIntoTemporaryReturnValueWorkCorrectly [

	| compiledMethod cogMethod tfExternalFunction called anExternalAddress |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [ called:= true. 32 ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI sint64.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
						   numberOfTemporaries: 1;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											230 0 "SameThreadCallout Literal0"
											208 "PopInto Temp 0"
											64	 "Push Temp 0"
											92  "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 32).
	self assert: called.

]
