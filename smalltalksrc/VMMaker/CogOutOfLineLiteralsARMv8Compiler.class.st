Class {
	#name : 'CogOutOfLineLiteralsARMv8Compiler',
	#superclass : 'CogARMv8Compiler',
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'accessing class hierarchy' }
CogOutOfLineLiteralsARMv8Compiler class >> literalsManagerClass [
	^OutOfLineLiteralsManager
]

{ #category : 'accessing' }
CogOutOfLineLiteralsARMv8Compiler >> cmpC32RTempByteSize [
	^8
]

{ #category : 'generate machine code - concretize' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeLiteral [
	"Generate an out-of-line literal.  Copy the value and any annotation from the stand-in in the literals manager."
	| literalAsInstruction literal twoComplement |
	literalAsInstruction := cogit cCoerceSimple: (operands at: 0) to: #'AbstractInstruction *'.
	literal := (self isAnInstruction: literalAsInstruction)
				ifTrue: [literalAsInstruction address]
				ifFalse: [self cCode: [literalAsInstruction asUnsignedInteger]
							inSmalltalk: [literalAsInstruction]].
	self assert: (dependent notNil and: [dependent opcode = Literal]).
	dependent annotation ifNotNil:
		[self assert: annotation isNil.
		 annotation := dependent annotation].
	dependent address ifNotNil: [self assert: dependent address = address].
	dependent address: address.

	twoComplement := literal < 0
		ifTrue: [ 16rFFFFFFFFFFFFFFFF - literal abs + 1 ]
		ifFalse: [ literal ].

	self machineCodeAt: 0 put: (twoComplement bitAnd: 16rFFFFFFFF).
	self machineCodeAt: 4 put: (twoComplement >> 32).
	machineCodeSize := 8
]

{ #category : 'generate machine code - concretize' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeMoveC32R [
	"Will get inlined into concretizeAt: switch."
	<var: #quickConstant type: #sqInt>
	<returnTypeC: #void>
	<inline: true>
	| quickConstant |
	
	quickConstant := operands at: 0.
	quickConstant < 0 ifTrue: [ 
		self shiftable16bitImmediate: quickConstant negated - 1
			ifTrue: [ :shift :value |
					self machineCodeAt: 0 put: (self
						movSize: 1
						destinationRegister: (operands at: 1)
						negatedImm: value
						shift: shift).
				^ machineCodeSize := 4 ]
			ifFalse: [ 
			self loadCwInto: (operands at: 1).
			^ machineCodeSize := 4 ]].

	self shiftable16bitImmediate: quickConstant
		ifTrue: [ :shift :value |
				self machineCodeAt: 0 put: (self
					movSize: 1
					destinationRegister: (operands at: 1)
					imm: value
					shift: shift).
			^ machineCodeSize := 4 ]
		ifFalse: [ 
			self loadCwInto: (operands at: 1).
			^ machineCodeSize := 4 ]
]

{ #category : 'generate machine code - concretize' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeMoveMbrR [
	"Will get inlined into concretizeAt: switch."

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset destReg |
	offset := operands at: 0.
	srcReg := operands at: 1.
	destReg := operands at: 2.

	self
		is9BitValue: offset
		ifTrue: [ :immediate9bitTwoComplementValue |
			self
				machineCodeAt: 0
				put: (self ldurbSize: 1 baseRegister: srcReg signedOffset: immediate9bitTwoComplementValue destinationRegister: destReg).
			^ machineCodeSize := 4 ]
		ifFalse: [
			self loadRelativeLiteralIn: ConcreteIPReg.
			self
				machineCodeAt: 4
				put: (self ldrbSourceRegister: srcReg offsetRegister: ConcreteIPReg destinationRegister: destReg).

			^ machineCodeSize := 8 ].
	^ 0	"to keep Slang happy"
]

{ #category : 'as yet unclassified' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeMovePatcheableC32R [
	
	self loadRelativeLiteralIn: (operands at: 1).
	^ machineCodeSize := 4
]

{ #category : 'generate machine code - concretize' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeMoveRM32r [
	"Will get inlined into concretizeAt: switch."

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg |

	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	self
		is9BitValue: offset
		ifTrue: [ :value |
			self
				machineCodeAt: 0
				put:(self
					sturSize: 0 "32 bits"
 					baseRegister: baseReg
					signedOffset: offset
					destinationRegister: srcReg).
			^ machineCodeSize := 4 ]
		ifFalse: [
			self
				shiftable16bitImmediate: offset
				ifTrue: [ :shift :value | 
					self assert: shift = 0.
					self
						machineCodeAt: 0
						put: (self movSize: 1 destinationRegister: ConcreteIPReg imm: value shift: shift).
					self
						machineCodeAt: 4
						put: (self strSize: 0 "32 bits" baseRegister: baseReg offsetRegister: ConcreteIPReg extension: 2r011 "LSL" shift: 0 "no LSL" storedRegister: srcReg).
					^ machineCodeSize := 8  ]
				ifFalse: [ 
						self loadRelativeLiteralIn: ConcreteIPReg.
					self
						machineCodeAt: 4
						put: (self strSize: 0 "32 bits" baseRegister: baseReg offsetRegister: ConcreteIPReg extension: 2r011 "LSL" shift: 0 "no LSL" storedRegister: srcReg).
					^ machineCodeSize := 8 ]].
	^ 0	"to keep Slang happy"
]

{ #category : 'generate machine code - concretize' }
CogOutOfLineLiteralsARMv8Compiler >> concretizeMoveRMwr [
	"Will get inlined into concretizeAt: switch."

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg |

	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	self
		is9BitValue: offset
		ifTrue: [ :value |
			self
				machineCodeAt: 0
				put:(self
					sturSize: 1
					baseRegister: baseReg
					signedOffset: offset
					destinationRegister: srcReg).
			^ machineCodeSize := 4 ]
		ifFalse: [
			self
				shiftable16bitImmediate: offset
				ifTrue: [ :shift :value | 
					self assert: shift = 0.
					self
						machineCodeAt: 0
						put: (self movSize: 1 destinationRegister: ConcreteIPReg imm: value shift: shift).
					self
						machineCodeAt: 4
						put: (self strSize: 1 baseRegister: baseReg offsetRegister: ConcreteIPReg extension: 2r011 "LSL" shift: 0 "no LSL" storedRegister: srcReg).
					^ machineCodeSize := 8  ]
				ifFalse: [ 
						self loadRelativeLiteralIn: ConcreteIPReg.
					self
						machineCodeAt: 4
						put: (self strSize: 1 baseRegister: baseReg offsetRegister: ConcreteIPReg extension: 2r011 "LSL" shift: 0 "no LSL" storedRegister: srcReg).
					^ machineCodeSize := 8 ]].
	^ 0	"to keep Slang happy"
]

{ #category : 'accessing' }
CogOutOfLineLiteralsARMv8Compiler >> getDefaultCogCodeSize [
	"Return the default number of bytes to allocate for native code at startup.
	 The actual value can be set via vmParameterAt: and/or a preference in the ini file."
	<inline: true>
	^1024 * 1280
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> inlineCacheTagAt: callSiteReturnAddress [
	<inline: true>
	^objectMemory unsignedLongAt: (self pcRelativeAddressAt: (callSiteReturnAddress - 8) asUnsignedInteger)
]

{ #category : 'testing' }
CogOutOfLineLiteralsARMv8Compiler >> isPCDependent [
	"Answer if the receiver is a pc-dependent instruction.  With out-of-line literals any instruction
	 that refers to a literal depends on the address of the literal, so add them in addition to the jumps."
	^self isJump
	  or: [opcode = AlignmentNops
	  or: [opcode ~= Literal and: [dependent notNil and: [dependent opcode = Literal]]]]
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> isSharable [
	"Hack:  To know if a literal should be unique (not shared) mark the second operand."
	<inline: true>
	self assert: opcode = Literal.
	^operands at: 1
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> literalBeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress."
	^objectMemory unsignedLong64At: (self pcRelativeAddressAt:
		((self instructionIsLDR: (self instructionBeforeAddress: followingAddress))
			ifTrue: [self instructionAddressBefore: followingAddress]
			ifFalse: [ self instructionAddressBefore: followingAddress - 4]))
]

{ #category : 'accessing' }
CogOutOfLineLiteralsARMv8Compiler >> literalLoadInstructionBytes [
	"Answer the size of a literal load instruction (which does not include the size of the literal).
	 With out-of-line literals this is always a single LDR instruction that refers to the literal."
	<inline: true>
	^4
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> literalOpcodeIndex [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	^(operands at: 2) asInteger
]

{ #category : 'accessing' }
CogOutOfLineLiteralsARMv8Compiler >> loadLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code. On ARM this is a single instruction pc-relative register load - unless we have made a mistake and not turned on the out of line literals manager"
	^4
]

{ #category : 'literals' }
CogOutOfLineLiteralsARMv8Compiler >> loadRelativeLiteralIn: destReg [

	<inline: true>

	self assert: dependent opcode = Literal.
	self assert: (cogit addressIsInCurrentCompilation: dependent address).
	self assert: (dependent address - (address + 8)) abs < (1 << 12).
	self machineCodeAt: 0 put: (self
			 ldrSize: 1
			 programCounterRelativeOffset: dependent address - address
			 destinationRegister: destReg) "64 bits"
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> mapEntryAddress [
	"Typically map entries apply to the end of an instruction, for two reasons:
	  a)	to cope with literals embedded in variable-length instructions, since, e.g.
		on x86, the literal typically comes at the end of the instruction.
	  b)	in-line cache detection is based on return addresses, which are typically
		to the instruction following a call.
	 But with out-of-line literals it is more convenient to annotate the literal itself."
	<inline: true>
	^opcode = Literal
		ifTrue: [address]
		ifFalse: [address + machineCodeSize]
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> moveCw: constant intoR: destReg [
	"Emit a load of aWord into destReg.  Answer the number of bytes of machine code generated.
	 Literals are stored out-of-line; emit a LDR with the relevant offset."
	 <var: 'constant' type: #usqInt>
	<inline: true>
	self loadRelativeLiteralIn: destReg.
	^machineCodeSize := 4
]

{ #category : 'compile abstract instructions' }
CogOutOfLineLiteralsARMv8Compiler >> outOfLineLiteralOpcodeLimit [
	"The maximum offset in a LDR is (1<<12)-1, or (1<<10)-1 instructions.
	 Be conservative.  The issue is that one abstract instruction can emit
	 multiple hardware instructions so we assume a 2 to 1 worst case of
	 hardware instructions to abstract opcodes.."
	^1 << (12 "12-bit offset field"
			- 3 "8 bytes per literal, so 2^3?"
			- 1 "2 hardware instructions to 1 abstract opcode") - 1
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> pcRelativeAddressAt: instrAddress [
	"Extract the address of the LDR (literal) instruction at address
	
	c.f. C6.2.132
	"
	
	| inst offset |

	inst := objectMemory uint32AtPointer: instrAddress.
	offset := inst >> 5 bitAnd: 16r7ffff.
	^instrAddress + (((offset allMask: (1 << 18))
							ifTrue: [offset negated]
							ifFalse: [offset]) * 4 "because LDR includes the imm / 4")
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> relocateMethodReferenceBeforeAddress: pc by: delta [
	"If possible we generate the method address using pc-relative addressing.
	 If so we don't need to relocate it in code.  So check if pc-relative code was
	 generated, and if not, adjust a load literal.  There are two cases, a push
	 or a register load.  If a push, then there is a register load, but in the instruction
	 before."
	| pcPrecedingLoad reference litAddr |
	pcPrecedingLoad := (self instructionIsPush: (self instructionBeforeAddress: pc))
							ifTrue: [pc - 4]
							ifFalse: [pc].
	"If the load is not done via pc-relative addressing we have to relocate."
	(self isPCRelativeValueLoad: (self instructionBeforeAddress: pcPrecedingLoad)) ifFalse:
		[litAddr := self pcRelativeAddressAt: pcPrecedingLoad.
		 reference := objectMemory long64At: litAddr.
		 objectMemory long64At: litAddr put: reference + delta - 4]
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> rewriteFullTransferAt: callSiteReturnAddress target: callTargetAddress expectedInstruction: expectedInstruction [
	"Rewrite a CallFull or JumpFull instruction to transfer to a different target.
	 This variant is used to rewrite cached primitive calls where we load the target address into ip
	and use the 'bx ip' or 'blx ip' instruction for the actual jump or call.
	Answer the extent
	 of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	self assert: (self instructionBeforeAddress: callSiteReturnAddress) = expectedInstruction.
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: callTargetAddress.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^0
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> rewriteInlineCacheAt: callSiteReturnAddress tag: cacheTag target: callTargetAddress [
	"Rewrite an inline cache to call a different target for a new tag.  This variant is used
	 to link unlinked sends in ceSend:to:numArgs: et al.  Answer the extent of the code
	 change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| call callDistance |
	callTargetAddress >= cogit minCallAddress ifFalse:
		[self error: 'linking callsite to invalid address'].
	callDistance := (callTargetAddress - (callSiteReturnAddress - 4 "return offset")).
	self assert: (self isInImmediateJumpRange: callDistance). "we don't support long call updates here"
	call := self bl: callDistance.
	objectMemory
		uint32AtPointer: (self instructionAddressBefore: callSiteReturnAddress ) put: call;
		unsignedLong64At: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag signedIntToLong64.
	self assert: (self inlineCacheTagAt: callSiteReturnAddress) = cacheTag  signedIntToLong64.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^4
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> rewriteInlineCacheTag: cacheTag at: callSiteReturnAddress [
	"Rewrite an inline cache with a new tag.  This variant is used
	 by the garbage collector."
	<inline: true>
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> setLiteralOpcodeIndex: index [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	operands at: 2 put: index
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> sizePCDependentInstructionAt: eventualAbsoluteAddress [
	"Size a jump and set its address.  The target may be another instruction
	 or an absolute address.  On entry the address inst var holds our virtual
	 address. On exit address is set to eventualAbsoluteAddress, which is
	 where this instruction will be output.  The span of a jump to a following
	 instruction is therefore between that instruction's address and this
	 instruction's address ((which are both still their virtual addresses), but the
	 span of a jump to a preceding instruction or to an absolute address is
	 between that instruction's address (which by now is its eventual absolute
	 address) or absolute address and eventualAbsoluteAddress.

	 ARM is simple; the 26-bit call/jump range means no short jumps.  This
	 routine only has to determine the targets of jumps, not determine sizes.

	 This version also deals with out-of-line literals.  If this is the real literal,
	 update the stand-in in literalsManager with the address (because instructions
	 referring to the literal are referring to the stand-in).  If this is annotated with
	 IsObjectReference transfer the annotation to the stand-in, whence it will be
	 transferred to the real literal, simplifying update of literals."

	opcode = AlignmentNops ifTrue:
		[| alignment |
		 address := eventualAbsoluteAddress.
		 alignment := operands at: 0.
		 ^machineCodeSize := (eventualAbsoluteAddress + (alignment - 1) bitAnd: alignment negated)
							   - eventualAbsoluteAddress].
	self assert: (self isJump or: [opcode = Call or: [opcode = CallFull
				or: [dependent notNil and: [dependent opcode = Literal]]]]).
	self isJump ifTrue: [self resolveJumpTarget].
	address := eventualAbsoluteAddress.
	(dependent notNil and: [dependent opcode = Literal]) ifTrue:
		[opcode = Literal ifTrue:
			[dependent address: address].
		 annotation = cogit getIsObjectReference ifTrue:
			[dependent annotation: annotation.
			 annotation := nil]].
	^machineCodeSize := maxSize
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsARMv8Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal in the instruction immediately preceding followingAddress."

	objectMemory
		unsignedLongAt: (self pcRelativeAddressAt:
					((self instructionIsLDR: (self instructionBeforeAddress: followingAddress))
						ifTrue: [self instructionAddressBefore: followingAddress]
						ifFalse: [self instructionAddressBefore: followingAddress - 4]))
		put: literal
]

{ #category : 'generate machine code - support' }
CogOutOfLineLiteralsARMv8Compiler >> updateLabel: labelInstruction [
	opcode ~= Literal ifTrue:
		[super updateLabel: labelInstruction]
]

{ #category : 'testing' }
CogOutOfLineLiteralsARMv8Compiler >> usesOutOfLineLiteral [
	"Answer if the receiver uses an out-of-line literal.  Needs only
	 to work for the opcodes created with gen:literal:operand: et al."

	<var: #offset type: 'sqInt'>
	| offset |
	opcode
		caseOf: {
				([ CallFull ] -> [ ^ true ]).
				([ JumpFull ] -> [ ^ true ]).
				"Arithmetic"
				([ AddCqR ] -> [
				 | constant |
				 constant := operands at: 0.
				 ^ (constant abs bitAnd: 16rfff) ~= constant abs ]).
				([ AndCqR ] -> [
				 ^ self
					   encodeLogicalImmediate: (operands at: 0)
					   registerSize: 64
					   ifPossible: [ :value | false ]
					   ifNotPossible: [ true ] ]).
				([ AndCqRR ] -> [
				 ^ self
					   encodeLogicalImmediate: (operands at: 0)
					   registerSize: 64
					   ifPossible: [ :value | false ]
					   ifNotPossible: [ true ] ]).
				([ CmpCqR ] -> [
				 ((operands at: 0) abs bitAnd: 16rFFF) = (operands at: 0) abs
					 ifTrue: [ ^ false ].
				 ((operands at: 0) abs << 12 >> 12 bitAnd: 16rFFF)
				 = (operands at: 0) abs ifTrue: [ ^ false ].
				 ^ true ]).
				([ CmpC32R ] -> [
				 ^ self
					   rotateable8bitSignedImmediate: (operands at: 0)
					   ifTrue: [ :r :i :n | false ]
					   ifFalse: [ true ] ]).
				([ OrCqR ] -> [
				 ^ self
					   encodeLogicalImmediate: (operands at: 0)
					   registerSize: 64
					   ifPossible: [ :v | false ]
					   ifNotPossible: [ true ] ]).

				([ SubCqR ] -> [
				 | constant |
				 constant := operands at: 0.
				 ^ (constant bitAnd: 16rfff) ~= constant ]).
				([ TstCqR ] -> [
				 ^ self
					   encodeLogicalImmediate: (operands at: 0)
					   registerSize: 64
					   ifPossible: [ :v | false ]
					   ifNotPossible: [ true ] ]).
				([ XorCqR ] -> [
				 ^ self
					   rotateable8bitBitwiseImmediate: (operands at: 0)
					   ifTrue: [ :r :i :n | false ]
					   ifFalse: [ true ] ]).
				([ AddCwR ] -> [ ^ true ]).
				([ AndCwR ] -> [ ^ true ]).
				([ CmpCwR ] -> [ ^ true ]).
				([ OrCwR ] -> [ ^ true ]).
				([ SubCwR ] -> [ ^ true ]).
				([ XorCwR ] -> [ ^ true ]).
				([ LoadEffectiveAddressMwrR ] -> [
				 ^ self
					   rotateable8bitImmediate: (operands at: 0)
					   ifTrue: [ :r :i | false ]
					   ifFalse: [ true ] ]).
				"Data Movement"
				([ MoveCqR ] -> [
				 | quickConstant |
				 quickConstant := operands at: 0.
				 ^ (quickConstant < 0 and: [
					    (self isShiftable16bitImmediate: quickConstant negated - 1)
						    not ]) or: [
					   (self isShiftable16bitImmediate: quickConstant) not ] ]).
				([ MoveC32R ] -> [
				 | quickConstant |
				 quickConstant := operands at: 0.
				 ^ (quickConstant < 0 and: [
					    (self isShiftable16bitImmediate: quickConstant negated - 1)
						    not ]) or: [
					   (self isShiftable16bitImmediate: quickConstant) not ] ]).

				([ MoveCwR ]
				 -> [ ^ (self inCurrentCompilation: (operands at: 0)) not ]).
				([ MoveAwR ] -> [
				 ^ (self isAddressRelativeToVarBase: (operands at: 0))
					   ifTrue: [ false ]
					   ifFalse: [ true ] ]).
				([ MoveRAw ] -> [
				 ^ (self isAddressRelativeToVarBase: (operands at: 1))
					   ifTrue: [ false ]
					   ifFalse: [ true ] ]).
				([ MoveAbR ] -> [
				 ^ (self isAddressRelativeToVarBase: (operands at: 0))
					   ifTrue: [ false ]
					   ifFalse: [ true ] ]).
				([ MoveRAb ] -> [
				 ^ (self isAddressRelativeToVarBase: (operands at: 1))
					   ifTrue: [ false ]
					   ifFalse: [ true ] ]).


				([ MoveRM32r ] -> [
				 self
					 is9BitValue: (operands at: 1)
					 ifTrue: [ :value | ^ false ]
					 ifFalse: [
						 self
							 shiftable16bitImmediate: (operands at: 1)
							 ifTrue: [ :value :shift | ^ false ]
							 ifFalse: [ ^ true ] ] ]).

				([ MoveRMwr ] -> [
				 self
					 is9BitValue: (operands at: 1)
					 ifTrue: [ :value | ^ false ]
					 ifFalse: [
						 self
							 shiftable16bitImmediate: (operands at: 1)
							 ifTrue: [ :value :shift | ^ false ]
							 ifFalse: [ ^ true ] ] ]).

				([ MoveRsM32r ] -> [
				 ^ self
					   is12BitValue: (operands at: 1)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveRdM64r ] -> [
				 ^ self
					   is12BitValue: (operands at: 1)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveMbrR ] -> [
				 ^ self
					   is9BitValue: (operands at: 0)
					   ifTrue: [ :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveRMbr ] -> [
				 ^ self
					   is12BitValue: (operands at: 1)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveRM8r ] -> [
				 ^ self
					   is12BitValue: (operands at: 1)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveM16rR ] -> [
				 ^ self
					   rotateable8bitImmediate: (operands at: 0)
					   ifTrue: [ :r :i | false ]
					   ifFalse: [ true ] ]).
				([ MoveRM16r ] -> [
				 ^ self
					   is12BitValue: (operands at: 1)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveM32rRs ] -> [
				 ^ self
					   is12BitValue: (operands at: 0)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).
				([ MoveM64rRd ] -> [
				 ^ self
					   is12BitValue: (operands at: 0)
					   ifTrue: [ :s :v | false ]
					   ifFalse: [ true ] ]).

				([ MoveM32rR ] -> [
				 offset := operands at: 0.
				 (offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ])
					 ifTrue: [ ^ false ]
					 ifFalse: [
						 self
							 is9BitValue: offset
							 ifTrue: [ :v | ^ false ]
							 ifFalse: [ ^ true ] ] ]).

				([ MoveMwrR ] -> [
				 offset := operands at: 0.
				 (offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ])
					 ifTrue: [ ^ false ]
					 ifFalse: [
						 self
							 is9BitValue: offset
							 ifTrue: [ :v | ^ false ]
							 ifFalse: [ ^ true ] ] ]).

				([ PushCw ]
				 -> [ ^ (self inCurrentCompilation: (operands at: 0)) not ]).
				([ PushCq ] -> [
				 ^ self
					   shiftable16bitImmediate: (operands at: 0)
					   ifTrue: [ :r :i | false ]
					   ifFalse: [ true ] ]).
				([ PrefetchAw ] -> [
				 ^ (self isAddressRelativeToVarBase: (operands at: 0))
					   ifTrue: [ false ]
					   ifFalse: [ true ] ]).

				"Patcheable instruction. Moves a literal. Uses out of line literal."
				([ MovePatcheableC32R ] -> [ ^ true ]) }
		otherwise: [ self error: 'We should not be here!!!' ].
	^ false "to keep C compiler quiet"
]
