Class {
	#name : 'UnicornX64Simulator',
	#superclass : 'UnicornSimulator',
	#category : 'VMMakerTests-Unicorn',
	#package : 'VMMakerTests',
	#tag : 'Unicorn'
}

{ #category : 'registers' }
UnicornX64Simulator >> arg0Register [
	
	^ UcX86Registers rdi
]

{ #category : 'registers' }
UnicornX64Simulator >> arg1Register [
	
	^ UcX86Registers rsi
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> baseRegister [

	^ UcX86Registers rbx
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> cResultRegister [
	
	^ UcX86Registers rax
]

{ #category : 'registers' }
UnicornX64Simulator >> carg0Register [
	
	"Assume SysV"
	^ UcX86Registers rdi
]

{ #category : 'registers' }
UnicornX64Simulator >> carg1Register [
	
	"Assume SysV"
	^ UcX86Registers rsi
]

{ #category : 'registers' }
UnicornX64Simulator >> carg2Register [
	
	"Assume SysV"
	^ UcX86Registers rdx
]

{ #category : 'registers' }
UnicornX64Simulator >> carg3Register [

	"Assume SysV"
	^ UcX86Registers rcx
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> classRegister [
	
	^ UcX86Registers rcx
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> createUnicorn [

	^ Unicorn x8664
]

{ #category : 'disassembling' }
UnicornX64Simulator >> disassembler [
	
	^ LLVMDisassembler amd64
]

{ #category : 'registers' }
UnicornX64Simulator >> doublePrecisionFloatingPointRegister0 [

	^ UcX86Registers xmm0
]

{ #category : 'registers' }
UnicornX64Simulator >> doublePrecisionFloatingPointRegister1 [

	^ UcX86Registers xmm1
]

{ #category : 'registers' }
UnicornX64Simulator >> doublePrecisionFloatingPointRegister2 [

	^ UcX86Registers xmm2
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> extractDestinationRegisterFromAssembly: aLLVMInstruction [ 
	
	| registerName |
	registerName := (aLLVMInstruction assemblyCodeString substrings: ',') last trimBoth.
	(registerName beginsWith: '%')
		ifTrue: [ registerName := registerName allButFirst ].
	^ registerName
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> framePointerRegister [
	
	^ UcX86Registers rbp
]

{ #category : 'accessing' }
UnicornX64Simulator >> getReturnAddress [
	
	^ self peekAddress 
]

{ #category : 'testing' }
UnicornX64Simulator >> hasLinkRegister [

	^ false
]

{ #category : 'initialization' }
UnicornX64Simulator >> initializeRegisterAliases [

	registerAliases
		at: #rcx put: #classRegister;
		at: #rdx put: #receiverRegister;
		at: #r9 put: #sendNumberOfArgumentsRegister;
		at: #rbx put: #baseRegister;
		at: #rbp put: #framePointerRegister
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> instructionPointerRegister [
	
	^ UcX86Registers rip
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> integerRegisterState [
	
	^ #()
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> postCallArgumentsNumArgs: numArgs in: aMemory [
	"Answer an argument vector of the requested size after a Win64 or SysV
	 ABI call.  On X64 this simply means accessing register arguments.
	 For compatibility with Cog/Slang we answer unsigned values."
	
	self assert: numArgs <= 4.
	
	^((CogX64Compiler isSysV
				ifTrue: [#(rdi rsi rdx rcx r8 r9)]
				ifFalse: [#(rcx rdx r8 r9)]) copyFrom: 1 to: numArgs) collect:
		[:getter|
		self perform: getter]
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> r10 [

	^ self readRegister: UcX86Registers r10
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r10: anInteger [ 
	
	^ self writeRegister: UcX86Registers r10 value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> r11 [

	^ self readRegister: UcX86Registers r11
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r11: anInteger [ 
	
	^ self writeRegister: UcX86Registers r11 value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> r12 [

	^ self readRegister: UcX86Registers r12
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r12: anInteger [ 
	
	^ self writeRegister: UcX86Registers r12 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r13: anInteger [ 
	
	self writeRegister: UcX86Registers r13 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r14: anInteger [ 
	
	self writeRegister: UcX86Registers r14 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r15: anInteger [ 
	
	self writeRegister: UcX86Registers r15 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r1: anInteger [ 
	
	^ self writeRegister: UcX86Registers r1 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r2: anInteger [ 
	
	^ self writeRegister: UcX86Registers r2 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r3: anInteger [ 
	
	^ self writeRegister: UcX86Registers r3 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r4: anInteger [ 
	
	^ self writeRegister: UcX86Registers r4 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r5: anInteger [ 
	
	^ self writeRegister: UcX86Registers r5 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r6: anInteger [ 
	
	^ self writeRegister: UcX86Registers r6 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r7: anInteger [ 
	
	^ self writeRegister: UcX86Registers r7 value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> r8 [

	^ self readRegister: UcX86Registers r8
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r8: anInteger [ 
	
	^ self writeRegister: UcX86Registers r8 value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> r9 [

	^ self readRegister: UcX86Registers r9
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r9: anInteger [ 
	
	^ self writeRegister: UcX86Registers r9 value: anInteger
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> r9b: anInteger [ 

	self writeRegister: UcX86Registers r9b value: anInteger 
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rax [

	^ self readRegister: UcX86Registers rax
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> rax: anInteger [ 
	
	self writeRegister: UcX86Registers rax value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rbp [

	^ self readRegister: UcX86Registers rbp
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rbp: anInteger [ 

	^ self writeRegister: UcX86Registers rbp value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rbx [

	^ self readRegister: UcX86Registers rbx
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rbx: aValue [

	^ self writeRegister: UcX86Registers rbx value: aValue
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rcx [

	^ self readRegister: UcX86Registers rcx
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rcx: anInteger [ 

	^ self writeRegister: UcX86Registers rcx value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rdi [

	^ self readRegister: UcX86Registers rdi
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> rdi: anInteger [ 
	
	self writeRegister: UcX86Registers rdi value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rdx [

	^ self readRegister: UcX86Registers rdx
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rdx: anInteger [ 

	^ self writeRegister: UcX86Registers rdx value: anInteger
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> receiverRegister [
	
	^ UcX86Registers rdx
]

{ #category : 'accessing' }
UnicornX64Simulator >> registerList [
	
	^ #(rip rax rbx rcx rdx rsp rbp r8 r9 r10 r11 r12 rsi rdi)
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> retpcIn: aSpurSimulatedMemory [ 

	^ memory long64At: self rbp + 8	

]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rip [

	^ self readRegister: UcX86Registers rip
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> rip: anInteger [ 
	
	self writeRegister: UcX86Registers rip value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rsi [

	^ self readRegister: UcX86Registers rsi
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> rsi: anInteger [ 
	
	self writeRegister: UcX86Registers rsi value: anInteger
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rsp [

	^ self readRegister: UcX86Registers rsp
]

{ #category : 'phisical-registers' }
UnicornX64Simulator >> rsp: anInteger [ 
	
	^ self writeRegister: UcX86Registers rsp value: anInteger
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> sendNumberOfArgumentsRegister [
	
	^ UcX86Registers r9
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> simulateJumpCallOf: address memory: aMemory [
	"Simulate a frame-building jump call of address (i.e. do not push the return pc
	 as this has already been done).  Build a frame since
	a) this is used for calls into the run-time which are unlikely to be leaf-calls, and
	b) stack alignment needs to be realistic for assert checking for platforms such as Mac OS X"

	"From the System V ABI:
	 3.2.2 The Stack Frame
	 ...	The end of the input argument area shall be aligned on a 16 (32, if __m256 is
		passed on stack) byte boundary. In other words, the value (%rsp + 8) is always
		a multiple of 16 (32) when control is transferred to the function entry point."


	self pushWord: self rbp.
	self rbp: self rsp.

	self rip: address
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> simulateLeafCallOf: address nextpc: nextpc memory: aMemory [

	self pushWord: nextpc.
	self rip: address
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> simulateReturnIn: aMemory [

	self rbp: (self popWord).
	self rip: (self popWord)
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> smashCallerSavedRegistersWithValuesFrom: base by: step in: aMemory [
	| volatileRegisters |
	CogX64Compiler isSysV
		ifTrue:
			[volatileRegisters := #(rax: rcx: rdx: rsi: rdi: r8: r9: r10: r11:)]
		ifFalse: "We should also save the registers to the shadow parameter space."
			[volatileRegisters := #(rax: rcx: rdx: r8: r9: r10: r11:).
			 #(rcx rdx r8 r9) withIndexDo:
				[:getter :index|
				 aMemory
					unsignedLong64At: self rbp + 9 + (index * 8) "skip saved fp and retpc; aMemory is 1-relative"
					put: (self perform: getter)]].
	volatileRegisters withIndexDo:
		[:setter :index|
		self perform: setter with: index - 1 * step + base]
]

{ #category : 'as yet unclassified' }
UnicornX64Simulator >> smashRegisterAccessors [

	^#(rax: rbx: rcx: rdx: rsi: rdi: r8: r9: r10: r11: r12: r13: r14: r15:)
]

{ #category : 'virtual-registers' }
UnicornX64Simulator >> stackPointerRegister [

	^ UcX86Registers rsp
]

{ #category : 'registers' }
UnicornX64Simulator >> temporaryRegister [
	
	"Both in System V and Windows"
	^ UcX86Registers rax
]

{ #category : 'accessing' }
UnicornX64Simulator >> vectorRegister0Value [

	^ simulator readRegisterId: UcX86Registers xmm0 size:  16
]

{ #category : 'accessing' }
UnicornX64Simulator >> wordSize [
	
	^ 8
]

{ #category : 'accessing - registers' }
UnicornX64Simulator >> xmm0 [
	
	^ simulator readRegisterId: UcX86Registers xmm0 size: 16
]

{ #category : 'accessing' }
UnicornX64Simulator >> xmm1 [
	
	^ simulator readRegisterId: UcX86Registers xmm1 size: 16
]

{ #category : 'registers' }
UnicornX64Simulator >> xmm2 [
	
	^ simulator readRegisterId: UcX86Registers xmm2 size: 16
]
