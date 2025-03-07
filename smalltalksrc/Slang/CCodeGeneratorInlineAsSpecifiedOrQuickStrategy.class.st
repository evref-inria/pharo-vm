Class {
	#name : 'CCodeGeneratorInlineAsSpecifiedOrQuickStrategy',
	#superclass : 'CCodeGeneratorInlineAsSpecifiedStrategy',
	#category : 'Slang-CodeGeneration',
	#package : 'Slang',
	#tag : 'CodeGeneration'
}

{ #category : 'testing' }
CCodeGeneratorInlineAsSpecifiedOrQuickStrategy >> isQuickCompiledMethod: aCompiledMethod [

	^aCompiledMethod isQuick
	 or: [(#(pushConstant: pushLiteralVariable:) includes: (aCompiledMethod abstractBytecodeMessageAt: aCompiledMethod initialPC) selector)
		and: [(aCompiledMethod abstractBytecodeMessageAt: (InstructionStream on: aCompiledMethod) followingPc) selector == #methodReturnTop]]
]

{ #category : 'asserting' }
CCodeGeneratorInlineAsSpecifiedOrQuickStrategy >> shouldInlineMethod: aMethod [

	^ (super shouldInlineMethod: aMethod)
		or: [ self isQuickCompiledMethod: aMethod compiledMethod ]
]
