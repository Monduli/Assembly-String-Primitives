TITLE Portfolio Assignment: String Primatives and Macros (Proj6_glendond.asm)

; Author: Dan Glendon
; Last Modified: 3/13/2021
; OSU email address: glendond@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: 3/14/2021
; Description: Prompts the user for 10 signed decimal integers. Verifies valid inputs.
; Calculates the sum and average of the input integers.
; ReadVal converts an input string to an integer, and WriteVal converts an integer to a string.


INCLUDE Irvine32.inc

; (insert macro definitions here)

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Retrieves a user-input string from the keyboard.
;
; Preconditions: None
;
; Receives:
; prompt = address of prompt that displays to the user what is to be entered
; memOutput = address to write the input string to
; count = desired maximum size of input string
; bytesRead = the number of bytes read by ReadString
;
; returns: memOutput = input string, bytesRead = number of bytes read by ReadString
; ---------------------------------------------------------------------------------
mGetString MACRO prompt, memOutput, count, bytesRead
	PUSH	EDX
	PUSH	EAX
	PUSH	ECX

	mDisplayString prompt

	MOV		ECX, count
	MOV		EDX, memOutput
	CALL	ReadString
	MOV		bytesRead, EAX

	POP		ECX
	POP		EAX
	POP		EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints the given string.
;
; Preconditions: string must be an OFFSET
;
; Receives:
; string = the offset of the string to be printed
;
; returns: None
; ---------------------------------------------------------------------------------
mDisplayString MACRO string
	PUSH	EDX

	MOV		EDX, string
	CALL	WriteString
	
	POP		EDX
ENDM

; Constants
; stringCount - the maximum size for the mGetString macro, being the largest number to be held in a 32 bit register
STRINGCOUNT = 30
; ARRAYSIZE - the number of numbers we want from the user
ARRAYSIZE = 10
; MAXNUM = the maximum number that fits in a 32 bit register
MAXNUM = 2147483647

.data

	; Variables
	intro		BYTE	"PORTFOLIO ASSIGNMENT: Designing low-level I/O procedures, programmed by Dan Glendon",0
	instruct1	BYTE	"Please provide 10 signed decimal integers.",0
	instruct2	BYTE	"Each number needs to be small enough to fit in a 32 bit register.",0
	instruct3	BYTE	"After you input the raw numbers, I will display them as a list, their sum, and their average.",0
	prompt		BYTE	"Please enter a signed number: ",0
	stringSum	BYTE	"The sum of the values is: ",0
	stringAvg	BYTE	"The average value is: ",0
	reprompt	BYTE	"Please try again: ",0
	error		BYTE	"ERROR: This is not a signed number, or it is too large.",0
	entered		BYTE	"You entered the following numbers: ",0
	memOutput	DWORD	0
	upCount		BYTE	0
	number		SDWORD	0
	numberList	SDWORD	ARRAYSIZE DUP(0)
	nLSize		DWORD	SIZEOF numberList
	numType		DWORD	TYPE numberList
	sum			SDWORD	?
	sumLength	DWORD	1
	sumSize		DWORD	LENGTHOF sum
	average		DWORD	?
	bytesRead	DWORD	?
	numberLen	DWORD	LENGTHOF number
	newString	DWORD	9 DUP(0)
	midString	DWORD	9 DUP(0)
	avg			SDWORD	?
	comma		BYTE	", "

.code
main PROC

	;frame for introduction
	PUSH	OFFSET intro
	PUSH	OFFSET instruct1
	PUSH	OFFSET instruct2
	PUSH	OFFSET instruct3
	CALL	introduction

	;frame for ReadVal
	MOV		ECX, 10
	MOV		EDI, OFFSET numberList
_ReadVal:
	MOV		memOutput, 0
	PUSH	OFFSET comma
	PUSH	MAXNUM
	PUSH	OFFSET upCount
	PUSH	OFFSET reprompt
	PUSH	OFFSET error
	PUSH	EDI
	PUSH	OFFSET bytesRead
	PUSH	OFFSET STRINGCOUNT
	PUSH	OFFSET memOutput
	PUSH	OFFSET prompt
	CALL	ReadVal

	; increment EDI then loop
	ADD		EDI, numType
	LOOP	_ReadVal
	CALL	Crlf

	; display "these are what you entered" string
	MOV		EDX, OFFSET entered
	mDisplayString EDX

	;frame for WriteVal
	MOV		ECX, 10
	MOV		ESI, OFFSET numberList

_writeLoop:
	PUSH	SIZEOF newString
	PUSH	OFFSET midString
	PUSH	SIZEOF midString
	MOV		EBX, [ESI]
	MOV		number, EBX
	PUSH	OFFSET number
	PUSH	LENGTHOF number
	PUSH	OFFSET newString
	CALL	WriteVal
	ADD		ESI, TYPE numberList
	CMP		ECX, 1
	JE		_endWL
	MOV		EDX, OFFSET comma
	mDisplayString EDX
_endWL:
	LOOP	_writeLoop
	CALL	Crlf

	; calculate the sum of the integer list
	MOV		ECX, 10
	MOV		EAX, 0
	MOV		ESI, OFFSET numberList
_sumLoop:
	MOV		EBX, [ESI]
	ADD		EAX, EBX
	ADD		ESI, TYPE numberList
	LOOP	_sumLoop
	MOV		sum, EAX

	; display "the sum is:"
	MOV		EDX, OFFSET stringSum
	mDisplayString EDX

	;Write the sum
	PUSH	SIZEOF newString
	PUSH	OFFSET midString
	PUSH	SIZEOF midString
	PUSH	OFFSET sum
	PUSH	OFFSET sumLength
	PUSH	OFFSET newString
	CALL	WriteVal

	; get the average value of the integer list
	MOV		EAX, sum
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	MOV		avg, EAX

	CALL	Crlf
	MOV		EDX, OFFSET stringAvg
	mDisplayString EDX

	;Write the average
	PUSH	SIZEOF newString
	PUSH	OFFSET midString
	PUSH	SIZEOF midString
	PUSH	OFFSET avg
	PUSH	OFFSET sumLength
	PUSH	OFFSET newString
	CALL	WriteVal


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Writes out the strings for the introduction and instructions.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	All are references to strings:
;	[ebp+20] = intro
;	[ebp+16] = instruct1
;	[ebp+12] = instruct2
;	[ebp+8] = instruct3
;
; returns: None
; ---------------------------------------------------------------------------------
introduction PROC

	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+20]
	CALL	Crlf
	CALL	Crlf

	mDisplayString [EBP+16]
	CALL	Crlf

	mDisplayString [EBP+12]
	CALL	Crlf

	mDisplayString [EBP+8]
	CALL	Crlf
	CALL	Crlf
	
	POP		EBP
	RET		20
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Invokes the mGetString macro to get user input in the form of a string of digits.
; Then, converts the ascii digits to their integer representation.
; Resulting numbers are stored in the given OFFSET.
;
; Preconditions: Stack is set up as indicated in "Receives" below
;
; Postconditions: None, all registers are pushed and popped at the beginning of the procedure
;
; Receives:
;	[ebp+44] = comma (for array formatting)
;	[ebp+40] = maximum input number
;	[ebp+36] = upward count, for numberList
;	[ebp+32] = OFFSET, post-error prompt (for mGetString error)
;	[ebp+28] = OFFSET, error text
;	[ebp+24] = OFFSET, the offset to write the number to
;	[ebp+20] = OFFSET, bytesRead	(for mGetString)
;	[ebp+16] = OFFSET, count		(for mGetString)
;	[ebp+12] = OFFSET, memOutput	(for mGetString)
;	[ebp+8]	 = OFFSET, prompt		(for mGetString)
;
; returns: input number (memOutput) is transferred to the OFFSET indicated by [EBP+24] as an integer
; ---------------------------------------------------------------------------------
ReadVal PROC

	PUSH	EBP
	MOV		EBP, ESP

	PUSHAD

	MOV		EDX, 0
	MOV		EAX, 0
	MOV		EBX, 0


_get_string:
	mGetString [ebp+8],[ebp+12],[ebp+16],[ebp+20]

_start_error: ; where the error starts from after re-prompting

	; ebp+12 = start of number string
	; ebp+24 = location to write int to
	; move bytesRead into loop counter for validation (ebp+20)
	MOV		ECX, [ebp+20]
	MOV		EDI, [ebp+24]
	MOV		ESI, [ebp+12]
	; check for number length
	CMP		ECX, [ebp+40]
	JG		_error

_verify:
	;verify string is valid
	CLD
	LODSB

	; check for + and then check for -
	CMP		AL, 45	
	JE		_minus
	CMP		AL, 43
	JE		_plus

	; check for ascii numbers
	SUB		AL, 48
	CMP		AL, 9
	JG		_error
	CMP		AL, 0
	JL		_error

	; add to combined total (DL), then multiply EDX (DL) by 10 to make accurate digit placement
	ADD		DL, AL
	CMP		ECX, 1
	JE		_continueLoop
	IMUL	EDX, 10
_continueLoop:
	LOOP	_verify

	; move sum into EAX
	MOV		EAX, EDX
	CMP		EBX, 0
	JLE		_last_stop
	; if EBX = 1, then subtract the number twice from itself to get its negative
	MOV		EBX, EAX
	SUB		EAX, EBX
	SUB		EAX, EBX

_last_stop:
	; transfer completed integer to "number" OFFSET
	MOV		[EDI], EAX
	JMP		_transfer

	; if the first "value" is a plus or minus (meaning EDX hasn't been set yet),
	; set EBX to 0 (pos) or 1 (neg) for later
	; if EDX > 0, then the +/- is not in the first slot, and is invalid
_plus:
	CMP		EDX, 0
	JNE		_error
	MOV		EBX, -1
	CMP		ECX, 1
	JE		_error
	JMP		_continueLoop

_minus:
	CMP		EDX, 0
	JNE		_error
	MOV		EBX, 1
	CMP		ECX, 1
	JE		_error
	JMP		_continueLoop

_error:
	mDisplayString [ebp+28]
	CALL	Crlf
	MOV		EDX, 0
	MOV		EBX, 0

	; in the example, there is a different string shown on post-error loops
	mGetString [ebp+32],[ebp+12],[ebp+16],[ebp+20]
	JMP		_start_error

_transfer:
	
	POPAD
	POP		EBP
	RET		40
ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Takes an array of numbers and converts them to ASCII string representations
; Then, prints them.
;
; Preconditions: Stack is set up as indicated in "Receives" below
;
; Postconditions: None, all registers are pushed and popped at the beginning of the procedure
;
; Receives:
;	[EBP+28]	= SIZEOF newString
;	[EBP+24]	= middle string, before flipping
;	[EBP+20]	= SIZEOF mid string
;	[EBP+16]	= OFFSET, current number
;	[EBP+12]	= LENGTHOF current number
;	[EBP+8]		= new string
;
; returns: [EBP+8] and [EBP+24] contain string versions of [EBP+16]
; ---------------------------------------------------------------------------------
WriteVal PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	CLD
	MOV		EDI, [EBP+8]
	MOV		AL, 0
	MOV		ECX, [EBP+20]
	REP		STOSB

	MOV		EDI, [EBP+24]
	MOV		AL, 0
	MOV		ECX, [EBP+28]
	REP		STOSB

	MOV		ESI, [EBP+16]
	MOV		EDI, [EBP+24]
	MOV		EAX, [ESI]
	MOV		EBX, 0
	CMP		EAX, 0
	JGE		_preConvertLoop
	MOV		EBX, -1
	IMUL	EBX
	MOV		EBX, 1
	PUSH	EBX
	MOV		EBX, 0
	JMP		_convertLoop

_preConvertLoop:
	PUSH	EBX

_convertLoop:
	MOV		EBX, 10
	CDQ
	IDIV	EBX

	ADD		EDX, 48
	MOV		EBX, 1
	PUSH	EAX
	MOV		EAX, EDX
	ADD		ECX, 1
	STOSB
	POP		EAX

	CMP		EAX, 0
	JNE		_convertLoop

	; flipping it around
	MOV		ESI, EDI
	DEC		ESI
	MOV		EDI, [EBP+8]
	POP		EBX
	CMP		EBX, 0
	JE		_flip
	MOV		AL, 45
	STOSB
_flip:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_flip

_display:
	mDisplayString [EBP+8] 

	POPAD
	POP		EBP
	RET		24
WriteVal ENDP

END main
