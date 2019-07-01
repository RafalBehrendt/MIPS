.data
	
	buffer: .asciiz ""
	
	provFirstWord: .asciiz "Provide first number: "
	provSecondWord: .asciiz "\nProvide second number: "
	
	menuExp: .asciiz "\nChoose operation:\n"
	addExp: .asciiz "1. Add numbers\n"
	subExp: .asciiz "2. Substract numbers\n"
	mulExp: .asciiz "3. Multiply numbers\n"
	divExp: .asciiz "4. Divide numbers\n"
	NWDExp: .asciiz "5. Find greates common divisor\n"
	exitExp: .asciiz "0. Exit program\n"
	
	newLine: .asciiz "\n"
	
	negativeSymbol: .asciiz "-"
	
	currentPointer: .word 0
		
	TableOfPointers: .space 16
	wordsContainer: .space 0
	
	
.macro add_number_manually(%idOfNumber)

	addi $t7, $zero, 0
	
	lw $t9, currentPointer
	
	addingNumber:
	
        li $v0,8
        la $a0, buffer
        li $a1, 2 
        syscall
        
        lbu $t0, 0($a0)
        addi $t0, $t0, -48
        
        bltz $t0, endOfAddingNumber
        bgt $t0, 9, endOfAddingNumber
        
        bnez, $t0, numberAccepted
        
        beqz $t7, addingNumber
        
        numberAccepted:
        
        addi $t7, $zero, 1
        sw $t0, wordsContainer($t9)
        
	addi $t9, $t9, 4
	
	j addingNumber
        
        endOfAddingNumber:
        
        bne $t0, -38, throwError
        
        beqz $t7, addingNumber
        
        addi %idOfNumber, %idOfNumber, 1
        mul %idOfNumber, %idOfNumber, 4
        
        sw $t9, TableOfPointers(%idOfNumber)
        
        sw $t9, currentPointer
        
        j success
        
        throwError:
        
        addi $a0, $v0, 0
        li $v0, 4
        syscall
        
        success:
         	
.end_macro
	
	
.macro getNumber(%idOfNumber)

	addi $t0, $zero, 0
	
	addi $s0, $zero, 4
	
	mul $s0, $s0, %idOfNumber
	
	addi $s1, $s0, 4
	
	lw $s0, TableOfPointers($s0)
	lw $s1, TableOfPointers($s1)
	
	writeNumberLoop:
	
	lw $t1, wordsContainer($s0)
	
	bnez $t1, writeNumber
	
	beqz $t0, skipNumber
	
	writeNumber:
	
	addi $t0, $zero, 1
	
	addi $a0, $t1, 0
	li $v0, 1
	syscall
	
	skipNumber:
	
	addi $s0, $s0, 4
	
	bne $s0, $s1, writeNumberLoop
	
.end_macro

.macro add_numbers(%id1, %id2)

	addi $t8, $zero, 0

	mul $t0, %id1, 4
	mul $t1, %id2, 4

	lw $s5, TableOfPointers($t0)
	lw $s6, TableOfPointers($t1)

	addi $t0, $t0, 4
	addi $t1, $t1, 4

	lw $s0, TableOfPointers($t0)
	lw $s1, TableOfPointers($t1)
	lw $s2, TableOfPointers($t1)

	addi $s0, $s0, -4
	addi $s1, $s1, -4

AddingLoop:

	lw $t3, wordsContainer($s0)
	lw $t4, wordsContainer($s1)

LoadedNumbers:

	add $t9, $t3, $t4
	add $t9, $t9, $t8
	addi $t8, $zero, 0

	blt $t9, 10, restSaved

	subi $t9, $t9, 10
	addi $t8, $t8, 1
	
restSaved:

	sw $t9, wordsContainer($s2)
	addi $s2, $s2, 4

	beq $s0, $s5, lastElementOfNumber1

	addi $s0, $s0, -4

	bne $s1, $s6, Number2Continues

	addi $t4, $zero, 0
	lw $t3, wordsContainer($s0)

	j LoadedNumbers

Number2Continues:

	addi $s1, $s1, -4

	j AddingLoop

lastElementOfNumber1:

	beq $s1, $s6, endOfAdding

	addi $s1, $s1, -4

	addi $t3, $zero, 0
	lw $t4, wordsContainer($s1)

	j LoadedNumbers

endOfAdding:

	blez $t8, noRest

	sw $t8, wordsContainer($s2)
	addi $s2, $s2, 4

noRest:

	addi $t5, %id2, 2
	mul $t5, $t5, 4
	sw $s2, TableOfPointers($t5)

	addi $s2, $s2, -4

	addi $t0, $zero, 8
	lw $t0, TableOfPointers($t0)

swappingLoop:

	lw $t1, wordsContainer($t0)
	lw $t2, wordsContainer($s2)
	
	sw $t2, wordsContainer($t0)
	sw $t1, wordsContainer($s2)

	addi $t0, $t0, 4
	addi $s2, $s2, -4

	blt $t0, $s2, swappingLoop

	getNumber(2)

.end_macro

.macro findBigger(%id1, %id2)

	mul $t0, %id1, 4
	mul $t1, %id2, 4
	
	addi $t2, %id2, 1
	mul $t2, $t2, 4
	
	lw $s0, TableOfPointers($t0)
	lw $s1, TableOfPointers($t1)
	lw $s2, TableOfPointers($t2)
	
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	
	sub $t9, $s2, $s1
	
	bgt $s1, $t9, firstNumberBigger
	blt $s1, $t9, secondNumberBigger
	
	comparingLoop:
	
	lw $t3, wordsContainer($s0)
	lw $t4, wordsContainer($s1)
	
	bgt $t3, $t4, firstNumberBigger
	blt $t3, $t4, secondNumberBigger
	
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	
	ble $s0, $t9, comparingLoop
	
	addi $s4, $zero, -1
	
	j endComparison
	
	firstNumberBigger:
	
	lw $s0, TableOfPointers($t0)
	lw $s1, TableOfPointers($t1)
	
	addi $s0, $s0, -4
	addi $s1, $s1, -4
	
	j endComparison
	
	secondNumberBigger:
	
	lw $s0, TableOfPointers($t1)
	lw $s1, TableOfPointers($t0)
	
	addi $s0, $s0, -4
	addi $s1, $s1, -4
	
	la $a0, negativeSymbol
	li $v0, 4
	syscall
	
	endComparison:

.end_macro

.macro sub_numbers(%id1, %id2)

	add $t5, $zero, %id1
	add $t6, $zero, %id2
	
	addi $s4, $zero, 0
	
	findBigger($t5, $t6) #stores last address of bigger number in s0 and smaller number in s1 or -1 in s4 if numbers are equal
	
	bne $s4, -1, numbersNotEqual
	
	addi $a0, $zero, 0
	li $v0, 1
	syscall
	
	j menu
	
	numbersNotEqual:

	addi $t8, $zero, 8
	
	lw $s2, TableOfPointers($t8)
	addi $t8, $t8, -4
	lw $s6, TableOfPointers($t8)
	addi $t8, $zero, 0
	lw $s5, TableOfPointers($t8)

SubLoop:

	lw $t3, wordsContainer($s0)
	lw $t4, wordsContainer($s1)

SubLoadedNumbers:

	sub $t9, $t3, $t4
	sub $t9, $t9, $t8
	addi $t8, $zero, 0
	
	bgez $t9, SubRestSaved

	addi $t9, $t9, 10
	addi $t8, $t8, 1
	
SubRestSaved:

	sw $t9, wordsContainer($s2)
	addi $s2, $s2, 4

	beq $s0, $s5, lastElementOfBiggerNumber
	beq $s0, $s6, lastElementOfBiggerNumber

	addi $s0, $s0, -4

	j SubNumber2Continues
	
fixing:

	addi $t4, $zero, 0
	lw $t3, wordsContainer($s0)

	j SubLoadedNumbers

SubNumber2Continues:

	beq $s1, $s6, fixing
	beq $s1, $s5, fixing

	addi $s1, $s1, -4

	j SubLoop

lastElementOfBiggerNumber:

	beq $s1, $s6, endOfSub
	beq $s1, $s5, endOfSub
	
	addi $s1, $s1, -4

	addi $t3, $zero, 0
	lw $t4, wordsContainer($s1)

	j SubLoadedNumbers

endOfSub:

	addi $t5, $zero, 12
	sw $s2, TableOfPointers($t5)

	addi $s2, $s2, -4

	addi $t0, $zero, 8
	lw $t0, TableOfPointers($t0)

SubSwappingLoop:

	bge $t0, $s2, SubEnd

	lw $t1, wordsContainer($t0)
	lw $t2, wordsContainer($s2)
	
	sw $t2, wordsContainer($t0)
	sw $t1, wordsContainer($s2)

	addi $t0, $t0, 4
	addi $s2, $s2, -4

	j SubSwappingLoop
	
SubEnd:

	getNumber(2)

.end_macro
	
.text

sw $zero, TableOfPointers($zero)

addi $t8, $zero, 0

la $a0, provFirstWord
li $v0, 4
syscall

add_number_manually($t8)
addi $t8, $zero, 1

la $a0, provSecondWord
li $v0, 4
syscall

add_number_manually($t8)


menu:

la $a0, menuExp
li $v0, 4
syscall

la $a0, addExp
li $v0, 4
syscall

la $a0, subExp
li $v0, 4
syscall

#la $a0, mulExp
#li $v0, 4
#syscall

#la $a0, divExp
#li $v0, 4
#syscall

#la $a0, NWDExp
#li $v0, 4
#syscall

la $a0, exitExp
li $v0, 4
syscall

li $v0, 5
syscall

beq $v0, 1, Add
beq $v0, 2, Sub
#beq $v0, 3, Mul
#beq $v0, 4, Div
#beq $v0, 5, NWD
bnez $v0, menu

li $v0, 10
syscall

Add:

addi $t6, $zero, 0
addi $t7, $zero, 1

add_numbers($t6, $t7)

j menu

Sub:

addi $t6, $zero, 0
addi $t7, $zero, 1

sub_numbers($t6, $t7)

j menu

.kdata

OVERFLOW_EXCEPTION: 	.asciiz "\n===>      Arithmetic overflow       <===\n\n" 
UNHANDLED_EXCEPTION:	.asciiz "\n===>      Unhandled exception       <===\n\n"
ADDRESS_ERROR_EX:	.asciiz "\n===>      Input contains invalid characters       <===\n\n"
SYSCALL_EXCEPTION:	.asciiz "\n===>      Syscall Exception       <===\n\n"
TRAP:	.asciiz "\n===>      Trap       <===\n\n"

.ktext 0x80000180

mfc0 $k0, $13   
andi $k1, $k0, 0x00007c  
srl  $k1, $k1, 2

beq $k1, 12, __overflow_exception
beq $k1, 4, __Address_Error_exception
beq $k1, 5, __Address_Error_exception
beq $k1, 8, __Syscall_Exception
beq $k1, 13, __Trap
	
la $a0, UNHANDLED_EXCEPTION
li $v0, 4
syscall
 
li $v0, 10
syscall
	
__overflow_exception:
	
la $a0, OVERFLOW_EXCEPTION
li $v0, 4
syscall
 
li $v0, 10
syscall

__Address_Error_exception:

la $a0, ADDRESS_ERROR_EX
li $v0, 4
syscall
 
li $v0, 10
syscall

__Syscall_Exception:

la $a0, SYSCALL_EXCEPTION
li $v0, 4
syscall

li $v0, 10
syscall

__Trap:

la $a0, TRAP
li $v0, 4
syscall
 
li $v0, 10
syscall


