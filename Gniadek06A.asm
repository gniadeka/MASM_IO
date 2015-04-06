TITLE Designing Low Level I/O Procedures(Gniadek06A.asm)



COMMENT !
; Author: Andrew Gniadek
; OSU Email : gniadeka@onid.oregonstate.edu
; Course / Project ID : CS271 - 400
; Assignment Number : 6A
; Assignment Due Date : 3 / 15 / 2015
; Date Last Modified : 3 / 02 / 2015
; Description: This program takes in 10 unsigned integers as characters and converts them to actual integers.  
; It calculates the sum and average of those numbers.  This program utitlizes low level I/O procedures to 
; change charcters into integers
; 
!

INCLUDE Irvine32.inc

;symbolic constants
MAX = 12
D_LOW = 48
D_HIGH = 57
ARRAY_SIZE = 12
REGISTER_MAX_INT = 4294967295



;MACROS

mDisplayString MACRO newBuffer

	push		edx
	mov		edx, newBuffer
	call	WriteString
	pop		edx

ENDM

mGetString MACRO buffer, byteCount, userPrompt

	push		edx
	push		ecx
	push		eax
	mDisplayString userPrompt
	mov		edx, buffer
	mov		ecx, ARRAY_SIZE 
	call	ReadString
	mov		byteCount, eax
	pop		edx
	pop		ecx
	pop		eax
ENDM

M_TEN EQU DWORD PTR[ebp-4]
DEC_STOR EQU DWORD PTR[ebp-4]
AL_STOR EQU DWORD PTR[ebp-8]
X_STOR EQU DWORD PTR[ebp-12]
BYTE_COUNT_STOR EQU DWORD PTR [ebp-16]
INPUT_STOR EQU DWORD PTR[ebp-20]
GEN_STOR EQU DWORD PTR [ebp-24]
LOAD_COUNT EQU DWORD PTR [ebp-28]


.data

;welcome prompt to the user
welcomePrompt	BYTE "PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures", 0dh, 0ah, "Programmed by Andrew Gniadek", 0dh, 0ah, 0

;provides the user with instructions on the function of the program
instructPrompt	BYTE "Please provide 10 unsigned decimal integers.", 0dh, 0ah
	     	BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0dh,0ah
		BYTE "After you have finished inputting the raw numbers, I will display a list of integers, "
		BYTE "their sum, and their average value.", 0dh,0ah
	     	BYTE 0

;asks the user for an unsigned number
genPrompt	BYTE "Please enter an unsigned number: ", 20h, 0

;notifies the user that the input was invalid
badInput	BYTE "ERROR: You did not enter an unsigned number or the number was too big",20h,20h,0

;the title that prints before telling the user what numbers were entered
enteredTitle	BYTE "You entered the following numbers: ",20h, 0dh,0ah,0

;the title string for the median
sumTitle	BYTE "The sum of these numbers is",20h, 0

;the title string for the sorted list
averageTitle	BYTE "The average is: ",20h,0

;the array that will hold the ten integers
array		DWORD MAX DUP(?)

;buffer for use as the input buffer
inputBuffer	BYTE MAX DUP(0), 0

;the variable to store the byte count
byteCounter	DWORD ?

;comma delimiter
commaDelimit BYTE ", ", 0

;says goodbye to the user
goodbyeUser	BYTE "Thanks for playing!!",0dh,0ah,0dh,0ah,"Goodbye!",0dh,0ah,0

;byte array used with XLAT to convert digits to strings
myTable BYTE "0123456789ABCDEF"

;num of stack variables
myStack DWORD 5

;num of locals
myLocals DWORD 6

;num of saved registers
myRegisters DWORD 6

;stores the sum of the array of 10 integers
progSum DWORD ?

;stores the average of the array of 10 integers
progAverage DWORD ?



.code
main PROC



;introduction
	call	Introduction

;Reads in all the values of the user in order
;to retrieve 10 valid integers
	

	push	OFFSET inputBuffer
	push	OFFSET array
	push	OFFSET byteCounter
	push	OFFSET genPrompt
	push	OFFSET badInput
	call	ReadVal

;This procedure sums up the array and stores
;the sum in a DWORD called progSum using
;reference parameters on the stack frame
	push	OFFSET array
	push	OFFSET progSum
	call	ArraySum

;This procedure calculates the average (mean)
;of the array of ten integers
	push	OFFSET progSum
	push	OFFSET progAverage
	call	ArrayAverage

;adds a line between the user input and the printing
	call	CrLf
;print the 10 numbers to the user
	push	OFFSET enteredTitle
	push	OFFSET array
	push	OFFSET commaDelimit
	call	PrintNumsToUser

	call	CrLf

	push	OFFSET sumTitle
	call	PrintTitle


;prints the sum to the user
	
	push	OFFSET myTable
	push	OFFSET inputBuffer
	push	OFFSET progSum
	call	WriteVal

	call	CrLf
;prints the average title
	push	OFFSET averageTitle
	call	PrintTitle

;prints the average to the user
	push	OFFSET myTable
	push	OFFSET inputBuffer
	push 	OFFSET progAverage
	call	WriteVal
	

	call	CrLf
	call	CrLf

COMMENT!
	

;Writes all the stored 10 decimals to the console
;as strings
;This takes the array of integers and the input
;buffer as reference parameters
	push	OFFSET myTable
	push	OFFSET inputBuffer
	push	OFFSET array
	call	WriteVal


!

;farewell to the user
	call	Farewell



exit; exit to operating system
main ENDP


;***************
PrintTitle PROC
;This procedure prints the title passed as a reference
;to the user using the macro
;No return value
;***************

	pushad
	enter 0,0

	mDisplayString [ebp+40]


	leave
	popad
	ret



PrintTitle ENDP


;***************
PrintNumsToUser PROC
;This procedure prints the 10 numbers to the user
;separated by commas
;***************


	pushad
	enter 4,0

	mDisplayString [ebp+48]

	mov		esi, [ebp+44]
	mov		ecx, 10

PrintTenNums:
	mov		eax, [esi]
	call	WriteDec
	cmp		ecx, 1
	je	NoPrint
	mDisplayString [ebp+40]
	add	esi,4
	loop	PrintTenNums

NoPrint:


	

	leave
	popad
	ret
PrintNumsToUser ENDP

;***************
ArrayAverage PROC
;This procedure calculates the average of the array
;If the numbers are not evenly divisble by ten,
;the average is rounded down
;***************
	
	pushad
	enter 4,0
	;local variable used in DIV operation
	;for the total number of numbers
	mov		M_TEN, 10

	;the sum to calculate the average
	mov		ebx, [ebp+44]
	mov		edi, [ebp+40]
	mov		eax, [ebx]


	;clears the edx for the DIV instruction
	xor		edx,edx

	;DIV instruction
	div		M_TEN
	
	;assign the average
	mov		[edi], eax	
	
	
	
	

	leave
	popad
	ret

ArrayAverage ENDP

;***************
ArraySum PROC
;This procedure sums up the integers in the given array
;The result is stored in the reference parameter
;progSum
;***************

	
	pushad
	enter 0,0

	;the reference parameter of the sum
	mov		eax, 0

	;the amount of integers
	mov		ecx, 10
	mov		edi, [ebp+40]

	;the array address
	mov		ebx, [ebp+44]

	;sum the elements of the array
AddElements:
	add		eax, [ebx]
	add		ebx,4
	loop	AddElements
	
	;store the sum in the progSum variable
	mov		[edi], eax
		


	leave
	popad

	ret


ArraySum ENDP

;***************
WriteVal PROC uses eax ebx esi edx edi ecx
;This procedure goes through the array
;of decimal integers, it calls subprocedures
;to calculate the sum and average and prints
;these to the console
;MACROS USED: displayString
;All registers are saved
;CITATION: This procedure is based on the Irvine Library
;WriteDec procedure with modifications to include
;macros.  Irvine32.asm Accessed:3/7/2015
;***************

	enter 4,0	


	;set up local variable for use with
	;division below
	mov		M_TEN, 10

	;Initial set up for printing a string from
	;a decimal
	mov		ecx, 0
	mov		edi, [ebp+36]
	
	;sets up the byte array table for use
	;in converting to ascii
	mov		ebx, [ebp+40]
	;This instruction is setting the edi to point
	;at the last element in the byte array for the
	;input
	add		edi, (MAX - 1)
	
	;the number to print
	mov		edx, [ebp+32]
	mov		eax, [edx]
	
	;reverse direction flag
	std

NextDigit:
	
	xor		edx,edx
	div	M_TEN
	xchg		eax,edx

	;switch digit to ascii
	xlat

	;stores the value in the al
	;in the edi
	stosb

	xchg		eax,edx

	inc		ecx
	;is the quotient zero
	or		eax,eax
	jnz	NextDigit
	
	;prints out the value
	inc		edi
	
	mDisplayString edi

	leave
	ret



WriteVal ENDP

;***************
ReadVal PROC uses eax ebx esi edx edi ecx
;This procedure checks whether the users
;entered a valid unsigned integer.  It
;goes byte by byte and changes valid character strings
;into numeric form
;No preconditions
;No return parameters; it just modifies the reference parameter
;to the array

	;sets up the stack frame
	enter 28,0
	mov		M_TEN, 10
	mov		X_STOR, 0
	mov		eax, [ebp+48]
	mov		INPUT_STOR, eax 
	xor		eax,eax
	mov		eax, [ebp+40]
	mov		BYTE_COUNT_STOR, eax
	xor		eax,eax
	mov		eax, [ebp+36]
	mov		GEN_STOR, eax
	xor		eax,eax
	mov		LOAD_COUNT, 0
	; sets the direction forward
	cld
; copies the reference parameter into the esi
; because the esi register is the source index


	;sets the destination index as the same as the
	;source index

	;set the source as the input buffer
	mov		esi, [ebp+48]

	;set the desintation as the dword array
	mov		edi, [ebp+44]


	;set the outer loop as 10 for all 
	;ten numbers
	mov		ecx, 10

Begin:
	xor		eax,eax
	push		ecx
ResetVars:
	mov		x_STOR, 0
	mov		AL_STOR, 0
	;calls the mGetString macro
GetNewString:
	mGetString  INPUT_STOR, BYTE_COUNT_STOR, GEN_STOR
	mov		ecx, BYTE_COUNT_STOR
	cmp		ecx, 0
	je	QuitLoop
	cmp		ecx, 11
	jae	QuitLoop
	
;main loop that determines the integer value
;from the string input
ByteLoop:

	xor		eax,eax
	;load a byte of the string into AL
	lodsb
	inc	LOAD_COUNT
	cmp		eax, D_LOW
	jge	CheckTwo
	jmp	QuitLoop
CheckTwo:
	cmp		eax, D_HIGH
	jle	ValidNum
	jmp	QuitLoop
NextDword:
	mov		[edi], eax
	add		edi, 4
	mov		LOAD_COUNT, 0
;revert to initial part of input buffer
	sub		esi, BYTE_COUNT_STOR
	pop		ecx
	loop	Begin
	jmp	LeaveProcedure	

;tells the user of the error and returns 
;to the top of the loop
QuitLoop:
	mDisplayString [ebp+32]
	call	CrLf
	xor		ebx,ebx
	sub		esi, LOAD_COUNT
	mov		LOAD_COUNT, 0
	mov		ecx, BYTE_COUNT_STOR
	xor		eax,eax
	mov		ebx, 0
	jmp	ResetVars
ValidNum:
	sub		eax, D_LOW
	mov		AL_STOR,eax
	xor		eax,eax
	mov		eax, X_STOR
	mul		M_TEN
	add		eax, AL_STOR
	mov		X_STOR, eax
	loop	ByteLoop		

	;quits the loop if the number is too large for
	;a 32 bit register
	jc      QuitLoop
	jmp	NextDword

LeaveProcedure:	;clears the stack frame
	leave
	ret


ReadVal ENDP


;***************
Farewell PROC uses eax edx
;This procedure tells the user that the result
;are good and then says goodbye to the user
;***************

	;calls carriage return to space
	;the valedictory from the prime
	;numbers
	call	CrLf


	;Prints the second part of the valedictory
	mov		edx, OFFSET goodByeUser
	call	WriteString
	
	ret	



Farewell ENDP




;***************
Introduction PROC uses edx
;This procedure prints the title information 
;of the program to the user
;***************


COMMENT !
Welcome prompt
!

; This is the program title output
	mov		edx, OFFSET welcomePrompt
	call 	WriteString
	call 	CrLf

; This clears the edx register for use
	xor		edx, edx


; This clears the line prior to printing
;the instructions
	call 	CrLf

	
	;prints the instructions to the user
	
	mov		edx, OFFSET instructPrompt
	call	WriteString


	call	CrLf
	

	ret

Introduction ENDP

;***************
PrepareDiv PROC
;This procedure clears the edx and eax for use in
;DIV instruction operations
;***************

	xor		edx,edx
	xor		eax,eax
	ret


PrepareDiv ENDP


END main
