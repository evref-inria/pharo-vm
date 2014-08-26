/* Automatically generated by
	CCodeGenerator VMMaker.oscog-eem.865 uuid: 4efffc12-280e-4060-b741-9066fb3fc970
 */


/*** Function Prototypes ***/


#if !PRODUCTION && defined(__GNUC__) && !defined(NoDbgRegParms)
# define NoDbgRegParms __attribute__ ((regparm (0)))
#endif

#if !defined(NoDbgRegParms)
# define NoDbgRegParms /*empty*/
#endif



#if defined(__GNUC__) && !defined(NeverInline)
# define NeverInline __attribute__ ((noinline))
#endif

#if !defined(NeverInline)
# define NeverInline /*empty*/
#endif

sqInt abortOffset(void);
void addCogMethodsToHeapMap(void);
sqInt bytecodePCForstartBcpcin(sqInt mcpc, sqInt startbcpc, CogBlockMethod *cogMethod);
void callCogCodePopReceiver(void);
void callCogCodePopReceiverAndClassRegs(void);
sqInt ceCPICMissreceiver(CogMethod *cPIC, sqInt receiver);
sqInt ceSICMiss(sqInt receiver);
void checkAssertsEnabledInCogit(void);
sqInt checkIntegrityOfObjectReferencesInCode(sqInt fullGCFlag);
char * codeEntryFor(char *address);
char * codeEntryNameFor(char *address);
sqInt cogCodeBase(void);
sqInt cogCodeConstituents(void);
void cogitPostGCAction(sqInt gcMode);
sqInt cogMethodDoesntLookKosher(CogMethod *cogMethod);
CogMethod * cogMNUPICSelectormethodOperandnumArgs(sqInt selector, sqInt methodOperand, sqInt numArgs);
CogMethod * cogselector(sqInt aMethodObj, sqInt aSelectorOop);
void compactCogCompiledCode(void);
void enterCogCodePopReceiver(void);
CogBlockMethod * findMethodForStartBcpcinHomeMethod(sqInt startbcpc, CogMethod *cogMethod);
void freeUnmarkedMachineCode(void);
void initializeCodeZoneFromupTo(sqInt startAddress, sqInt endAddress);
sqInt isPCWithinMethodZone(char *address);
sqInt isSendReturnPC(sqInt retpc);
void linkSendAtintooffsetreceiver(sqInt callSiteReturnAddress, CogMethod *sendingMethod, CogMethod *targetMethod, sqInt theEntryOffset, sqInt receiver);
void mapObjectReferencesInMachineCode(sqInt gcMode);
void markAndTraceMachineCodeOfMarkedMethods(void);
void markAndTraceObjectsOrFreeMachineCode(sqInt inFullGC);
void markMethodAndReferents(CogBlockMethod *aCogMethod);
usqInt maxCogMethodAddress(void);
usqInt mcPCForBackwardBranchstartBcpcin(sqInt bcpc, sqInt startbcpc, CogBlockMethod *cogMethod);
sqInt minCogMethodAddress(void);
sqInt mnuOffset(void);
sqInt patchToOpenPICFornumArgsreceiver(sqInt selector, sqInt numArgs, sqInt receiver);
sqInt pcisWithinMethod(char *address, CogMethod *cogMethod);
void printCogMethodFor(void *address);
void printTrampolineTable(void);
sqInt recordPrimTraceFunc(void);
void setBreakMethod(sqInt anObj);
void setPostCompileHook(void (*aFunction)(CogMethod *, void *));
void setSelectorOfto(CogMethod *cogMethod, sqInt aSelectorOop);
sqInt traceLinkedSendOffset(void);
void unlinkAllSends(void);
void unlinkSendsOfisMNUSelector(sqInt selector, sqInt isMNUSelector);
void unlinkSendsToFree(void);
void unlinkSendsToandFreeIf(sqInt targetMethodObject, sqInt freeIfTrue);
void addAllToYoungReferrers(void);
CogMethod * methodFor(void *address);
sqInt numMethodsOfType(sqInt cogMethodType);
void printCogMethods(void);
void printCogMethodsOfType(sqInt cmType);
void printCogMethodsWithMethod(sqInt methodOop);
void printCogMethodsWithPrimitive(sqInt primIdx);
void printCogMethodsWithSelector(sqInt selectorOop);
void printCogYoungReferrers(void);
void printOpenPICList(void);
char * whereIsMaybeCodeThing(sqInt anOop);
sqInt numRegArgs(void);
sqInt genQuickReturnConst(void);
sqInt genQuickReturnInstVar(void);
sqInt genQuickReturnSelf(void);
void recordCallOffsetInof(CogMethod *cogMethod, void *callLabelArg);
void rewritePrimInvocationInto(CogMethod *cogMethod, void (*primFunctionPointer)(void));
void voidCogCompiledCode(void);
void callCogCodePopReceiverArg0Regs(void);
void callCogCodePopReceiverArg1Arg0Regs(void);


/*** Global Variables ***/
sqInt blockNoContextSwitchOffset;
sqInt breakPC;
void * CFramePointer;
void * CStackPointer;
sqInt ceBaseFrameReturnTrampoline;
void (*ceCall0ArgsPIC)(void);
void (*ceCall1ArgsPIC)(void);
void (*ceCall2ArgsPIC)(void);
void (*ceCallCogCodePopReceiverAndClassRegs)(void);
void (*ceCallCogCodePopReceiverArg0Regs)(void);
void (*ceCallCogCodePopReceiverArg1Arg0Regs)(void);
void (*ceCallCogCodePopReceiverReg)(void);
sqInt ceCannotResumeTrampoline;
void (*ceCaptureCStackPointers)(void);
sqInt ceCheckForInterruptTrampoline;
void (*ceEnterCogCodePopReceiverReg)(void);
unsigned long (*ceGetSP)(void);
sqInt ceReturnToInterpreterTrampoline;
unsigned long (*ceTryLockVMOwner)(void);
void (*ceUnlockVMOwner)(void);
sqInt cFramePointerInUse;
sqInt cmEntryOffset;
sqInt cmNoCheckEntryOffset;
unsigned long debugPrimCallStackOffset;
sqInt missOffset;
void (*realCECallCogCodePopReceiverAndClassRegs)(void);
void (*realCECallCogCodePopReceiverArg0Regs)(void);
void (*realCECallCogCodePopReceiverArg1Arg0Regs)(void);
void (*realCECallCogCodePopReceiverReg)(void);
void (*realCEEnterCogCodePopReceiverReg)(void);
int traceFlags ;
sqInt traceStores;


/*** Macros ***/
#define blockAlignment(self) 8
#define breakOnImplicitReceiver() (traceFlags & 64)
#define ceBaseFrameReturnPC() ceBaseFrameReturnTrampoline
#define ceCannotResumePC() ((usqInt)ceCannotResumeTrampoline)
#define ceReturnToInterpreterPC() ((usqInt)ceReturnToInterpreterTrampoline)
#define compileSendTrace() (traceFlags & 2)
#define dynSuperEntryOffset() cmDynSuperEntryOffset
#define entryOffset() cmEntryOffset
#define getCFramePointer() CFramePointer
#define getCStackPointer() CStackPointer
#define interpretOffset() missOffset
#define noCheckEntryOffset() cmNoCheckEntryOffset
#define noContextSwitchBlockEntryOffset() blockNoContextSwitchOffset
#define printOnTrace() (traceFlags & 1)
#define recordBlockTrace() (traceFlags & 4)
#define recordEventTrace() (traceFlags & 16)
#define recordOverflowTrace() (traceFlags & 32)
#define recordPrimTrace() (traceFlags & 8)
#define recordSendTrace() (traceFlags & 2)
#define setCFramePointer(theFP) (CFramePointer = (void *)(theFP))
#define setCStackPointer(theSP) (CStackPointer = (void *)(theSP))
#define tryLockVMOwner() (ceTryLockVMOwner() != 0)
#define unlockVMOwner() ceUnlockVMOwner()

